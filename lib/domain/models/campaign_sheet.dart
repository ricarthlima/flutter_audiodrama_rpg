import 'dart:convert';

class CampaignSheet {
  String userId;
  String campaignId;
  String sheetId;
  CampaignSheet({
    required this.userId,
    required this.campaignId,
    required this.sheetId,
  });

  CampaignSheet copyWith({
    String? userId,
    String? campaignId,
    String? sheetId,
  }) {
    return CampaignSheet(
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      sheetId: sheetId ?? this.sheetId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'campaignId': campaignId,
      'sheetId': sheetId,
    };
  }

  factory CampaignSheet.fromMap(Map<String, dynamic> map) {
    return CampaignSheet(
      userId: map['userId'] as String,
      campaignId: map['campaignId'] as String,
      sheetId: map['sheetId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignSheet.fromJson(String source) =>
      CampaignSheet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CampaignSheet(userId: $userId, campaignId: $campaignId, sheetId: $sheetId)';

  @override
  bool operator ==(covariant CampaignSheet other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.campaignId == campaignId &&
        other.sheetId == sheetId;
  }

  @override
  int get hashCode => userId.hashCode ^ campaignId.hashCode ^ sheetId.hashCode;
}
