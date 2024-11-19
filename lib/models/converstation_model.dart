import 'package:don_ganh_app/models/user_model.dart';

class Conversation {
  final String id; // Corresponds to "_id"
  final NguoiDung? senderId; // Corresponds to "sender_id" (nullable)
  final NguoiDung? receiverId; // Corresponds to "receiver_id" (nullable)
  final List<String> messageIds; // List of message IDs as strings
  final DateTime? createdAt; // Corresponds to "createdAt" (nullable)
  final DateTime? updatedAt; // Corresponds to "updatedAt" (nullable)
  final int? v; // Corresponds to "__v" (nullable)

  Conversation({
    required this.id,
    this.senderId,
    this.receiverId,
    required this.messageIds,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // Factory constructor to create a Conversation object from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] ?? '', // Matches "_id" in the JSON, default to empty string
      senderId: json['sender_id'] != null
          ? NguoiDung.fromJson(json['sender_id'])
          : null, // Matches "sender_id" in the JSON, nullable
      receiverId: json['receiver_id'] != null
          ? NguoiDung.fromJson(json['receiver_id'])
          : null, // Matches "receiver_id" in the JSON, nullable
      messageIds: json['messages'] != null
          ? List<String>.from(json['messages'])
          : [], // Convert message IDs to List<String>, default to empty list
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null, // Parse "createdAt" as DateTime, nullable
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null, // Parse "updatedAt" as DateTime, nullable
      v: json['__v'], // Matches "__v" in the JSON, nullable
    );
  }

  // Method to convert Conversation object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Use "_id" to match the JSON field
      'sender_id': senderId?.toJson(), // Matches "sender_id" in the JSON
      'receiver_id': receiverId?.toJson(), // Matches "receiver_id" in the JSON
      'messages': messageIds, // Convert message IDs back to list of strings
      'createdAt': createdAt?.toIso8601String(), // Convert DateTime to ISO string
      'updatedAt': updatedAt?.toIso8601String(), // Convert DateTime to ISO string
      '__v': v, // Matches "__v" in the JSON
    };
  }
}
