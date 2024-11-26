class Revenue {
  final int totalRevenue;
  final int totalPending;
  final int totalCanceled;

  Revenue({
    required this.totalRevenue,
    required this.totalPending,
    required this.totalCanceled,
  });

  factory Revenue.fromMap(String key, Map<String, dynamic> map) {
    return Revenue(
      totalRevenue: map['totalRevenue'] ?? 0,
      totalPending: map['totalPending'] ?? 0,
      totalCanceled: map['totalCanceled'] ?? 0,
    );
  }
}
