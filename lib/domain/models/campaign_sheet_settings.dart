import 'dart:convert';

import 'package:flutter/foundation.dart';

class CampaignSheetSettings {
  List<String> listActiveWorkIds;
  List<String> listActiveModuleIds;

  CampaignSheetSettings({
    required this.listActiveWorkIds,
    required this.listActiveModuleIds,
  });

  CampaignSheetSettings copyWith({
    List<String>? listActiveWorkIds,
    List<String>? listActiveModuleIds,
  }) {
    return CampaignSheetSettings(
      listActiveWorkIds: listActiveWorkIds ?? this.listActiveWorkIds,
      listActiveModuleIds: listActiveModuleIds ?? this.listActiveModuleIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listActiveWorkIds': listActiveWorkIds,
      'listActiveModuleIds': listActiveModuleIds,
    };
  }

  factory CampaignSheetSettings.fromMap(Map<String, dynamic> map) {
    return CampaignSheetSettings(
      listActiveWorkIds: map['listActiveWorkIds'] != null
          ? List<String>.from(map['listActiveWorkIds'])
          : [],
      listActiveModuleIds: map['listActiveModuleIds'] != null
          ? List<String>.from(map['listActiveModuleIds'])
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignSheetSettings.fromJson(String source) =>
      CampaignSheetSettings.fromMap(json.decode(source));

  @override
  String toString() =>
      'CampaignSheetSettings(listActiveWorkIds: $listActiveWorkIds, listActiveModuleIds: $listActiveModuleIds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CampaignSheetSettings &&
        listEquals(other.listActiveWorkIds, listActiveWorkIds) &&
        listEquals(other.listActiveModuleIds, listActiveModuleIds);
  }

  @override
  int get hashCode => listActiveWorkIds.hashCode ^ listActiveModuleIds.hashCode;
}
