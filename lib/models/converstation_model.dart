import 'package:don_ganh_app/models/user_model.dart';

class Conversation {
  final String id; // Corresponds to "_id"
  final NguoiDung senderId; // Corresponds to "sender_id"
  final NguoiDung receiverId; // Corresponds to "receiver_id"
  final List<String> messageIds; // List of message IDs as strings
  final DateTime createdAt; // Corresponds to "createdAt"
  final DateTime updatedAt; // Corresponds to "updatedAt"
  final int v; // Corresponds to "__v"

  Conversation({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.messageIds,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  // Factory constructor to create a Conversation object from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'], // Matches "_id" in the JSON
      senderId: NguoiDung.fromJson(json['sender_id']) , // Matches "sender_id" in the JSON
      receiverId: NguoiDung.fromJson(json['receiver_id']), // Matches "receiver_id" in the JSON
      messageIds: List<String>.from(json['messages']), // Convert message IDs to List<String>
      createdAt: DateTime.parse(json['createdAt']), // Parse "createdAt" as DateTime
      updatedAt: DateTime.parse(json['updatedAt']), // Parse "updatedAt" as DateTime
      v: json['__v'], // Matches "__v" in the JSON
    );
  }

  // Method to convert Conversation object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Use "_id" to match the JSON field
      'sender_id': senderId.toJson(), // Matches "sender_id" in the JSON
      'receiver_id': receiverId.toJson(), // Matches "receiver_id" in the JSON
      'messages': messageIds, // Convert message IDs back to list of strings
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to ISO string
      'updatedAt': updatedAt.toIso8601String(), // Convert DateTime to ISO string
      '__v': v, // Matches "__v" in the JSON
    };
  }
}
