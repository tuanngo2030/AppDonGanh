class BankCard {
  final int id;
  final String name;
  final int bankId;
  final int? type; // Để cho phép type có thể là null
  final String? completeTime; // Để cho phép completeTime có thể là null
  final String bankName;
  final String bankShortName;
  final int priority;
  final String bankLogo;

  BankCard({
    required this.id,
    required this.name,
    required this.bankId,
    this.type, // Không bắt buộc
    this.completeTime, // Không bắt buộc
    required this.bankName,
    required this.bankShortName,
    required this.priority,
    required this.bankLogo,
  });

  factory BankCard.fromJson(Map<String, dynamic> json) {
    return BankCard(
      id: json['id'],
      name: json['name'] ?? '', 
      bankId: json['bank_id'],
      type: json['type'] != null ? json['type'] : null, // Gán giá trị null nếu không có
      completeTime: json['complete_time'], // Có thể là null
      bankName: json['bank_name'] ?? '',
      bankShortName: json['bank_short_name'] ?? '',
      priority: json['priority'] != null ? json['priority'] : 0, // Gán giá trị mặc định nếu null
      bankLogo: json['bank_logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bank_id': bankId,
      'type': type,
      'complete_time': completeTime,
      'bank_name': bankName,
      'bank_short_name': bankShortName,
      'priority': priority,
      'bank_logo': bankLogo,
    };
  }
}
class PaymentResponse {
  final int code;
  final List<String> message;
  final int count;
  final List<BankCard> data;

  PaymentResponse({
    required this.code,
    required this.message,
    required this.count,
    required this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      code: json['code'],
      message: List<String>.from(json['message']),
      count: json['count'],
      data: (json['data'] as List)
          .map((item) => BankCard.fromJson(item))
          .toList(),
    );
  }
}
