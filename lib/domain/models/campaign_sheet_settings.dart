import 'dart:convert';

import 'package:flutter/foundation.dart';

class CampaignSheetSettings {
  List<String> listActiveWorkIds;
  List<String> listModuleIds;
  CampaignSheetSettings({
    required this.listActiveWorkIds,
    required this.listModuleIds,
  });

  CampaignSheetSettings copyWith({
    List<String>? listActiveWorkIds,
    List<String>? listModuleIds,
  }) {
    return CampaignSheetSettings(
      listActiveWorkIds: listActiveWorkIds ?? this.listActiveWorkIds,
      listModuleIds: listModuleIds ?? this.listModuleIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listActiveWorkIds': listActiveWorkIds,
      'listModuleIds': listModuleIds,
    };
  }

  factory CampaignSheetSettings.fromMap(Map<String, dynamic> map) {
    return CampaignSheetSettings(
      listActiveWorkIds: List<String>.from(map['listActiveWorkIds']),
      listModuleIds: List<String>.from(map['listModuleIds']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignSheetSettings.fromJson(String source) =>
      CampaignSheetSettings.fromMap(json.decode(source));

  @override
  String toString() =>
      'CampaignSheetSettings(listActiveWorkIds: $listActiveWorkIds, listModuleIds: $listModuleIds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CampaignSheetSettings &&
        listEquals(other.listActiveWorkIds, listActiveWorkIds) &&
        listEquals(other.listModuleIds, listModuleIds);
  }

  @override
  int get hashCode => listActiveWorkIds.hashCode ^ listModuleIds.hashCode;
}
