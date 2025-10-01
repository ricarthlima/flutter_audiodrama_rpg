// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_rpg_audiodrama/_core/providers/audio_provider.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_sheet_settings.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_turn_order.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_vm_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_scenes.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/models/battle_map.dart';

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
  CampaignVisualDataModel visualData;

  AudioCampaign audioCampaign;

  CampaignSheetSettings campaignSheetSettings;

  CampaignScenes campaignScenes;

  String? activeBattleMapId;
  List<BattleMap> listBattleMaps;

  CampaignTurnOrder campaignTurnOrder;

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
    required this.visualData,
    required this.audioCampaign,
    required this.campaignSheetSettings,
    required this.campaignScenes,
    required this.activeBattleMapId,
    required this.listBattleMaps,
    required this.campaignTurnOrder,
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
    CampaignVisualDataModel? visualData,
    AudioCampaign? audioCampaign,
    CampaignSheetSettings? campaignSheetSettings,
    CampaignScenes? campaignScenes,
    String? activeBattleMapId,
    List<BattleMap>? listBattleMaps,
    CampaignTurnOrder? campaignTurnOrder,
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
      visualData: visualData ?? this.visualData,
      audioCampaign: audioCampaign ?? this.audioCampaign,
      campaignSheetSettings:
          campaignSheetSettings ?? this.campaignSheetSettings,
      campaignScenes: campaignScenes ?? this.campaignScenes,
      activeBattleMapId: activeBattleMapId ?? this.activeBattleMapId,
      listBattleMaps: listBattleMaps ?? this.listBattleMaps,
      campaignTurnOrder: campaignTurnOrder ?? this.campaignTurnOrder,
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
      'visualData': visualData.toMap(),
      'audioCampaign': audioCampaign.toMap(),
      'campaignSheetSettings': campaignSheetSettings.toMap(),
      'campaignScenes': campaignScenes.name,
      'activeBattleMapId': activeBattleMapId,
      'listBattleMaps': listBattleMaps.map((e) => e.toMap()).toList(),
      'campaignTurnOrder': campaignTurnOrder.toMap(),
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
      description: map['description'] != null
          ? map['description'] as String
          : null,
      nextSession: map['nextSession'] != null
          ? DateTime.parse(map['nextSession'])
          : null,
      listAchievements: (map["listAchievements"] != null)
          ? List<CampaignAchievement>.from(
              (map['listAchievements'] as List<dynamic>)
                  .map<CampaignAchievement>(
                    (x) =>
                        CampaignAchievement.fromMap(x as Map<String, dynamic>),
                  ),
            )
          : [],
      visualData: (map['visualData'] != null)
          ? CampaignVisualDataModel.fromMap(map['visualData'])
          : CampaignVisualDataModel.empty(),
      audioCampaign: (map['audioCampaign'] != null)
          ? AudioCampaign.fromMap(map["audioCampaign"])
          : AudioCampaign(),
      campaignSheetSettings: (map['campaignSheetSettings'] != null)
          ? CampaignSheetSettings.fromMap(map['campaignSheetSettings'])
          : CampaignSheetSettings(
              listActiveWorkIds: [],
              listActiveModuleIds: [],
              activePublicRolls: false,
              activeResisted: false,
            ),

      campaignScenes: (map['campaignScenes'] != null)
          ? CampaignScenes.values
                .where((e) => e.name == map['campaignScenes'])
                .first
          : CampaignScenes.visual,
      activeBattleMapId: (map['activeBattleMapId'] != null)
          ? map['activeBattleMapId'] as String
          : null,
      listBattleMaps: (map['listBattleMaps'] != null)
          ? (map['listBattleMaps'] as List<dynamic>)
                .map((e) => BattleMap.fromMap(e))
                .toList()
          : [],
      campaignTurnOrder: (map['campaignTurnOrder'] != null)
          ? CampaignTurnOrder.fromMap(map['campaignTurnOrder'])
          : CampaignTurnOrder(
              isTurnActive: false,
              turn: 0,
              sheetTurn: 0,
              listSheetOrders: [],
            ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Campaign.fromJson(String source) =>
      Campaign.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Campaign(id: $id, listIdOwners: $listIdOwners, listIdPlayers: $listIdPlayers, enterCode: $enterCode, createdAt: $createdAt, updatedAt: $updatedAt, name: $name, imageBannerUrl: $imageBannerUrl, description: $description, nextSession: $nextSession, listAchievements: $listAchievements, audioCampaign: $audioCampaign, activeBattleMapId: $activeBattleMapId, listBattleMaps: $listBattleMaps)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Campaign &&
        other.id == id &&
        listEquals(other.listIdOwners, listIdOwners) &&
        listEquals(other.listIdPlayers, listIdPlayers) &&
        other.enterCode == enterCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.name == name &&
        other.imageBannerUrl == imageBannerUrl &&
        other.description == description &&
        other.nextSession == nextSession &&
        listEquals(other.listAchievements, listAchievements) &&
        other.audioCampaign == audioCampaign &&
        other.activeBattleMapId == activeBattleMapId &&
        listEquals(other.listBattleMaps, listBattleMaps);
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
        listAchievements.hashCode ^
        audioCampaign.hashCode ^
        activeBattleMapId.hashCode ^
        listBattleMaps.hashCode;
  }
}
