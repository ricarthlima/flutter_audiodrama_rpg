import 'dart:convert';

import 'package:flutter/foundation.dart';

class CampaignSheetSettings {
  List<String> listActiveWorkIds;
  List<String> listActiveModuleIds;

  bool activeResisted;
  bool activePublicRolls;

  CampaignSheetSettings({
    required this.listActiveWorkIds,
    required this.listActiveModuleIds,
    required this.activeResisted,
    required this.activePublicRolls,
  });

  CampaignSheetSettings copyWith({
    List<String>? listActiveWorkIds,
    List<String>? listActiveModuleIds,
    bool? activeResisted,
    bool? activePublicRolls,
  }) {
    return CampaignSheetSettings(
      listActiveWorkIds: listActiveWorkIds ?? this.listActiveWorkIds,
      listActiveModuleIds: listActiveModuleIds ?? this.listActiveModuleIds,
      activeResisted: activeResisted ?? this.activeResisted,
      activePublicRolls: activePublicRolls ?? this.activePublicRolls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listActiveWorkIds': listActiveWorkIds,
      'listActiveModuleIds': listActiveModuleIds,
      'activeResisted': activeResisted,
      'activePublicRolls': activePublicRolls,
    };
  }

  factory CampaignSheetSettings.fromMap(Map<String, dynamic> map) {
    return CampaignSheetSettings(
      listActiveWorkIds: List<String>.from(map['listActiveWorkIds']),
      listActiveModuleIds: List<String>.from(map['listActiveModuleIds']),
      activeResisted: map['activeResisted'] ?? false,
      activePublicRolls: map['activePublicRolls'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignSheetSettings.fromJson(String source) =>
      CampaignSheetSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CampaignSheetSettings(listActiveWorkIds: $listActiveWorkIds, listActiveModuleIds: $listActiveModuleIds, activeResisted: $activeResisted, activePublicRolls: $activePublicRolls)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CampaignSheetSettings &&
        listEquals(other.listActiveWorkIds, listActiveWorkIds) &&
        listEquals(other.listActiveModuleIds, listActiveModuleIds) &&
        other.activeResisted == activeResisted &&
        other.activePublicRolls == activePublicRolls;
  }

  @override
  int get hashCode {
    return listActiveWorkIds.hashCode ^
        listActiveModuleIds.hashCode ^
        activeResisted.hashCode ^
        activePublicRolls.hashCode;
  }
}
