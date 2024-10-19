class Message {
  final String id;
  final String text;
  final bool seen;
  final String msgByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.text,
    required this.seen,
    required this.msgByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tạo phương thức từ JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      text: json['text'],
      seen: json['seen'],
      msgByUserId: json['msgByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Tạo phương thức chuyển đổi ngược lại thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'seen': seen,
      'msgByUserId': msgByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}