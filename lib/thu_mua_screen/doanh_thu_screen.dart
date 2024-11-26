import 'dart:convert';
import 'package:don_ganh_app/models/doanh_thu_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<Map<String, Revenue>> getRevenue({
  required String fromDate,
  required String toDate,
  required String filter,
}) async {
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/doanhthu/GetDoanhThu?fromDate=$fromDate&toDate=$toDate&filter=$filter'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(
          key,
          Revenue.fromMap(key, value),
        ));
  } else {
    throw Exception('Failed to load revenue data');
  }
}

class DoanhThuScreen extends StatefulWidget {
  const DoanhThuScreen({super.key});

  @override
  State<DoanhThuScreen> createState() => _DoanhThuScreenState();
}

class _DoanhThuScreenState extends State<DoanhThuScreen> {
  String filter = 'thang';
  List<Revenue> revenueDataList = [];
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  void fetchRevenueData() async {
    try {
      final revenueData = await getRevenue(
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate),
        toDate: DateFormat('yyyy-MM-dd').format(toDate),
        filter: filter,
      );

      setState(() {
        revenueDataList = revenueData.values.toList();
      });
    } catch (e) {
      print('Error fetching revenue data: $e');
    }
  }

  Future<void> pickDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
    );

    if (pickedRange != null) {
      setState(() {
        fromDate = pickedRange.start;
        toDate = pickedRange.end;
      });

      fetchRevenueData();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRevenueData();
  }

  List<BarChartGroupData> get barChartGroupData => revenueDataList
      .asMap()
      .entries
      .map((entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalRevenue.toDouble(),
                color: Colors.greenAccent,
                width: 14,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade800],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              BarChartRodData(
                toY: entry.value.totalPending.toDouble(),
                color: Colors.orangeAccent,
                width: 14,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade800],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              BarChartRodData(
                toY: entry.value.totalCanceled.toDouble(),
                color: Colors.redAccent,
                width: 14,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade800],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
            barsSpace: 6,
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doanh Thu'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: filter,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          filter = newValue;
                        });

                        fetchRevenueData();
                      }
                    },
                    items: <String>['tuan', 'thang', 'nam']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: pickDateRange,
                  child: const Text('Chọn Ngày'),
                ),
              ],
            ),
          ),
          if (revenueDataList.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          interval: 100000,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < revenueDataList.length) {
                              return Text(
                                DateFormat('dd/MM').format(fromDate.add(Duration(days: index))),
                                style: const TextStyle(fontSize: 12),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.black12, width: 1),
                        left: BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    barGroups: barChartGroupData,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
