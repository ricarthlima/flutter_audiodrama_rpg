// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CampaignChatMessage {
  String id;
  String userId;
  String message;
  DateTime createdAt;

  CampaignChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  CampaignChatMessage copyWith({
    String? id,
    String? userId,
    String? message,
    DateTime? createdAt,
  }) {
    return CampaignChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CampaignChatMessage.fromMap(Map<String, dynamic> map) {
    return CampaignChatMessage(
      id: map['id'] as String,
      userId: map['userId'] as String,
      message: map['message'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignChatMessage.fromJson(String source) =>
      CampaignChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampaignChatMessage(id: $id, userId: $userId, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant CampaignChatMessage other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.message == message &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        message.hashCode ^
        createdAt.hashCode;
  }
}
