// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class CampaignAchievement {
  String id;
  String title;
  String description;
  String? imageUrl;
  bool isHided;
  bool isDescriptionHided;
  bool isImageHided;
  List<String> listUsers;

  CampaignAchievement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.isHided,
    required this.isDescriptionHided,
    required this.isImageHided,
    required this.listUsers,
  });

  CampaignAchievement copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    bool? isHided,
    bool? isDescriptionHided,
    bool? isImageHided,
    List<String>? listUsers,
  }) {
    return CampaignAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isHided: isHided ?? this.isHided,
      isDescriptionHided: isDescriptionHided ?? this.isDescriptionHided,
      isImageHided: isImageHided ?? this.isImageHided,
      listUsers: listUsers ?? this.listUsers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'isHided': isHided,
      'isDescriptionHided': isDescriptionHided,
      'isImageHided': isImageHided,
      'listUsers': listUsers,
    };
  }

  factory CampaignAchievement.fromMap(Map<String, dynamic> map) {
    return CampaignAchievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      isHided: map['isHided'] as bool,
      isDescriptionHided: map['isDescriptionHided'] as bool,
      isImageHided: (map["isImageHided"] != null) ? map["isImageHided"] : false,
      listUsers: List<String>.from((map['listUsers'] as List<dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignAchievement.fromJson(String source) =>
      CampaignAchievement.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CampaignAchievement(id: $id, title: $title, description: $description, imageUrl: $imageUrl, isHided: $isHided, isDescriptionHided: $isDescriptionHided, listUsers: $listUsers)';
  }

  @override
  bool operator ==(covariant CampaignAchievement other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.isHided == isHided &&
        other.isDescriptionHided == isDescriptionHided &&
        other.isImageHided == isImageHided &&
        listEquals(other.listUsers, listUsers);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        isHided.hashCode ^
        isDescriptionHided.hashCode ^
        isImageHided.hashCode ^
        listUsers.hashCode;
  }
}
