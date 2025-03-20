// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';

class Campaign {
  String id;
  List<String> listIdOwners;
  List<String> listIdPlayers;
  String enterCode;
  DateTime createdAt;
  DateTime updatedAt;

  String? name;
  String? imageBannerUrl;
  String? description;
  DateTime? nextSession;

  List<CampaignAchievement> listAchievements;

  Campaign({
    required this.id,
    required this.listIdOwners,
    required this.listIdPlayers,
    required this.enterCode,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.imageBannerUrl,
    this.description,
    this.nextSession,
    required this.listAchievements,
  });

  Campaign copyWith({
    String? id,
    List<String>? listIdOwners,
    List<String>? listIdPlayers,
    String? enterCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? imageBannerUrl,
    String? description,
    DateTime? nextSession,
    List<CampaignAchievement>? listAchievements,
  }) {
    return Campaign(
      id: id ?? this.id,
      listIdOwners: listIdOwners ?? this.listIdOwners,
      listIdPlayers: listIdPlayers ?? this.listIdPlayers,
      enterCode: enterCode ?? this.enterCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      imageBannerUrl: imageBannerUrl ?? this.imageBannerUrl,
      description: description ?? this.description,
      nextSession: nextSession ?? this.nextSession,
      listAchievements: listAchievements ?? this.listAchievements,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'listIdOwners': listIdOwners,
      'listIdPlayers': listIdPlayers,
      'enterCode': enterCode,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'name': name,
      'imageBannerUrl': imageBannerUrl,
      'description': description,
      'nextSession': nextSession?.toString(),
      'listAchievements': listAchievements.map((e) => e.toMap()).toList(),
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as String,
      listIdOwners: List<String>.from((map['listIdOwners'] as List<dynamic>)),
      listIdPlayers: List<String>.from((map['listIdPlayers'] as List<dynamic>)),
      enterCode: map['enterCode'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      name: map['name'] != null ? map['name'] as String : null,
      imageBannerUrl: map['imageBannerUrl'] != null
          ? map['imageBannerUrl'] as String
          : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      nextSession: map['nextSession'] != null
          ? DateTime.parse(map['nextSession'])
          : null,
      listAchievements: (map["listAchievements"] != null)
          ? List<CampaignAchievement>.from(
              (map['listAchievements'] as List<dynamic>)
                  .map<CampaignAchievement>(
                (x) => CampaignAchievement.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Campaign.fromJson(String source) =>
      Campaign.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Campaign(id: $id, listIdOwners: $listIdOwners, listIdPlayers: $listIdPlayers, enterCode: $enterCode, createdAt: $createdAt, updatedAt: $updatedAt, name: $name, imageBannerUrl: $imageBannerUrl, description: $description, nextSession: $nextSession)';
  }

  @override
  bool operator ==(covariant Campaign other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        listEquals(other.listIdOwners, listIdOwners) &&
        listEquals(other.listIdPlayers, listIdPlayers) &&
        other.enterCode == enterCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.name == name &&
        other.imageBannerUrl == imageBannerUrl &&
        other.description == description &&
        other.nextSession == nextSession &&
        other.listAchievements == listAchievements;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listIdOwners.hashCode ^
        listIdPlayers.hashCode ^
        enterCode.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        name.hashCode ^
        imageBannerUrl.hashCode ^
        description.hashCode ^
        nextSession.hashCode ^
        listAchievements.hashCode;
  }
}
