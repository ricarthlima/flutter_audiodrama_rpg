// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum CampaignChatType { message, roll, spell }

class CampaignChatMessage {
  String id;
  String userId;
  String message;
  DateTime createdAt;

  CampaignChatType type;
  String? whisperId;

  CampaignChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.type,
    this.whisperId,
  });

  CampaignChatMessage copyWith({
    String? id,
    String? userId,
    String? message,
    DateTime? createdAt,
    CampaignChatType? type,
    String? whisperId,
  }) {
    return CampaignChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      whisperId: whisperId ?? this.whisperId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type.name,
      'whisperId': whisperId,
    };
  }

  factory CampaignChatMessage.fromMap(Map<String, dynamic> map) {
    return CampaignChatMessage(
      id: map['id'] as String,
      userId: map['userId'] as String,
      message: map['message'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      type: map['type'] != null
          ? CampaignChatType.values.where((e) => e.name == map['type']).first
          : CampaignChatType.message,
      whisperId: map['whisperId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignChatMessage.fromJson(String source) =>
      CampaignChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampaignChatMessage(id: $id, userId: $userId, message: $message, createdAt: $createdAt, type: $type, whisperId: $whisperId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CampaignChatMessage &&
        other.id == id &&
        other.userId == userId &&
        other.message == message &&
        other.createdAt == createdAt &&
        other.type == type &&
        other.whisperId == whisperId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        message.hashCode ^
        createdAt.hashCode ^
        type.hashCode ^
        whisperId.hashCode;
  }
}
