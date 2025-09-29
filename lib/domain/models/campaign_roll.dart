import 'dart:convert';

import 'roll_log.dart';

class CampaignRoll {
  String id;
  String userId;
  String campaignId;
  String sheetId;
  DateTime createdAt;
  RollLog rollLog;

  CampaignRoll({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.sheetId,
    required this.createdAt,
    required this.rollLog,
  });

  CampaignRoll copyWith({
    String? id,
    String? userId,
    String? campaignId,
    String? sheetId,
    DateTime? createdAt,
    RollLog? rollLog,
  }) {
    return CampaignRoll(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      sheetId: sheetId ?? this.sheetId,
      createdAt: createdAt ?? this.createdAt,
      rollLog: rollLog ?? this.rollLog,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'campaignId': campaignId,
      'sheetId': sheetId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'rollLog': rollLog.toMap(),
    };
  }

  factory CampaignRoll.fromMap(Map<String, dynamic> map) {
    return CampaignRoll(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      campaignId: map['campaignId'] ?? '',
      sheetId: map['sheetId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      rollLog: RollLog.fromMap(map['rollLog']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignRoll.fromJson(String source) =>
      CampaignRoll.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CampaignRoll(id: $id, userId: $userId, campaignId: $campaignId, sheetId: $sheetId, createdAt: $createdAt, rollLog: $rollLog)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CampaignRoll &&
        other.id == id &&
        other.userId == userId &&
        other.campaignId == campaignId &&
        other.sheetId == sheetId &&
        other.createdAt == createdAt &&
        other.rollLog == rollLog;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        campaignId.hashCode ^
        sheetId.hashCode ^
        createdAt.hashCode ^
        rollLog.hashCode;
  }
}
