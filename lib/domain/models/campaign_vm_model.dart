// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';

class CampaignVisualDataModel {
  CampaignVisualDataModel.empty();

  String baseUrl = "";

  List<CampaignVisual> listPortraits = [];
  List<CampaignVisual> listBackgrounds = [];
  List<CampaignVisual> listAmbiences = [];
  List<CampaignVisual> listMusics = [];
  List<CampaignVisual> listSfxs = [];
  List<CampaignVisual> listObjects = [];

  List<CampaignVisual> listLeftActive = [];
  List<CampaignVisual> listRightActive = [];
  CampaignVisual? backgroundActive;

  double visualScale = 512.1;
  double distanceFactor = 0.60;
  int transitionBackgroundDurationInMilliseconds = 1000;

  bool allowZoom = false;
  bool allowPan = false;

  CampaignVisualDataModel({
    required this.baseUrl,
    required this.listPortraits,
    required this.listBackgrounds,
    required this.listAmbiences,
    required this.listMusics,
    required this.listSfxs,
    required this.listLeftActive,
    required this.listRightActive,
    this.backgroundActive,
    required this.transitionBackgroundDurationInMilliseconds,
    required this.visualScale,
    required this.distanceFactor,
    required this.listObjects,
    this.allowPan = false,
    this.allowZoom = false,
  });

  CampaignVisualDataModel copyWith({
    String? baseUrl,
    List<CampaignVisual>? listPortraits,
    List<CampaignVisual>? listBackgrounds,
    List<CampaignVisual>? listAmbiences,
    List<CampaignVisual>? listMusics,
    List<CampaignVisual>? listSfxs,
    List<CampaignVisual>? listLeftActive,
    List<CampaignVisual>? listRightActive,
    CampaignVisual? backgroundActive,
    double? visualScale,
    double? distanceFactor,
    int? transitionBackgroundDurationInMilliseconds,
    List<CampaignVisual>? listObjects,
    bool? allowPan,
    bool? allowZoom,
  }) {
    return CampaignVisualDataModel(
      baseUrl: baseUrl ?? this.baseUrl,
      listPortraits: listPortraits ?? this.listPortraits,
      listBackgrounds: listBackgrounds ?? this.listBackgrounds,
      listAmbiences: listAmbiences ?? this.listAmbiences,
      listMusics: listMusics ?? this.listMusics,
      listSfxs: listSfxs ?? this.listSfxs,
      listLeftActive: listLeftActive ?? this.listLeftActive,
      listRightActive: listRightActive ?? this.listRightActive,
      backgroundActive: backgroundActive ?? this.backgroundActive,
      visualScale: visualScale ?? this.visualScale,
      distanceFactor: distanceFactor ?? this.distanceFactor,
      transitionBackgroundDurationInMilliseconds:
          transitionBackgroundDurationInMilliseconds ??
              this.transitionBackgroundDurationInMilliseconds,
      listObjects: listObjects ?? this.listObjects,
      allowPan: allowPan ?? this.allowPan,
      allowZoom: allowZoom ?? this.allowZoom,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'baseUrl': baseUrl,
      'listPortraits': listPortraits.map((x) => x.toMap()).toList(),
      'listBackgrounds': listBackgrounds.map((x) => x.toMap()).toList(),
      'listAmbiences': listAmbiences.map((x) => x.toMap()).toList(),
      'listMusics': listMusics.map((x) => x.toMap()).toList(),
      'listSfxs': listSfxs.map((x) => x.toMap()).toList(),
      'listLeftActive': listLeftActive.map((x) => x.toMap()).toList(),
      'listRightActive': listRightActive.map((x) => x.toMap()).toList(),
      'backgroundActive': backgroundActive?.toMap(),
      'visualScale': visualScale,
      'distanceFactor': distanceFactor,
      'listObjects': listObjects.map((x) => x.toMap()).toList(),
      'allowPan': allowPan,
      'allowZoom': allowZoom,
    };
  }

  factory CampaignVisualDataModel.fromMap(Map<String, dynamic> map) {
    return CampaignVisualDataModel(
      baseUrl: map['baseUrl'] ?? "",
      listPortraits: List<CampaignVisual>.from(
        (map['listPortraits'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listBackgrounds: List<CampaignVisual>.from(
        (map['listBackgrounds'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listAmbiences: List<CampaignVisual>.from(
        (map['listAmbiences'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listMusics: List<CampaignVisual>.from(
        (map['listMusics'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listSfxs: List<CampaignVisual>.from(
        (map['listSfxs'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listLeftActive: List<CampaignVisual>.from(
        (map['listLeftActive'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listRightActive: List<CampaignVisual>.from(
        (map['listRightActive'] as List<dynamic>).map(
          (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
        ),
      ),
      backgroundActive: map['backgroundActive'] != null
          ? CampaignVisual.fromMap(
              map['backgroundActive'] as Map<String, dynamic>)
          : null,
      visualScale: map['visualScale'] as double,
      distanceFactor: map['distanceFactor'] as double,
      transitionBackgroundDurationInMilliseconds:
          map['transitionBackgroundDurationInMilliseconds'] != null
              ? map['transitionBackgroundDurationInMilliseconds'] as int
              : 1000,
      listObjects: map['listObjects'] != null
          ? List<CampaignVisual>.from(
              (map['listObjects'] as List<dynamic>).map(
                (x) => CampaignVisual.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      allowPan: map['allowPan'] ?? false,
      allowZoom: map['allowZoom'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignVisualDataModel.fromJson(String source) =>
      CampaignVisualDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampaignVmModel(baseUrl: $baseUrl, listPortraits: $listPortraits, listBackgrounds: $listBackgrounds, listAmbiences: $listAmbiences, listMusics: $listMusics, listSfxs: $listSfxs, listLeftActive: $listLeftActive, listRightActive: $listRightActive, backgroundActive: $backgroundActive, visualScale: $visualScale, distanceFactor: $distanceFactor, allowPan: $allowPan, allowZoom: $allowZoom)';
  }

  @override
  bool operator ==(covariant CampaignVisualDataModel other) {
    if (identical(this, other)) return true;

    return baseUrl == other.baseUrl &&
        listEquals(other.listPortraits, listPortraits) &&
        listEquals(other.listBackgrounds, listBackgrounds) &&
        listEquals(other.listAmbiences, listAmbiences) &&
        listEquals(other.listMusics, listMusics) &&
        listEquals(other.listSfxs, listSfxs) &&
        listEquals(other.listLeftActive, listLeftActive) &&
        listEquals(other.listRightActive, listRightActive) &&
        other.backgroundActive == backgroundActive &&
        other.visualScale == visualScale &&
        other.distanceFactor == distanceFactor &&
        other.allowPan == allowPan &&
        other.allowZoom == allowZoom;
  }

  @override
  int get hashCode {
    return baseUrl.hashCode ^
        listPortraits.hashCode ^
        listBackgrounds.hashCode ^
        listAmbiences.hashCode ^
        listMusics.hashCode ^
        listSfxs.hashCode ^
        listLeftActive.hashCode ^
        listRightActive.hashCode ^
        backgroundActive.hashCode ^
        visualScale.hashCode ^
        distanceFactor.hashCode ^
        allowPan.hashCode ^
        allowZoom.hashCode;
  }
}
