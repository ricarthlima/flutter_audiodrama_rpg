// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ActionTemplate {
  String id;
  String name;
  String description;
  bool isFree;
  bool isResisted;
  bool isPreparation;
  bool isReaction;
  ActionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.isFree,
    required this.isResisted,
    required this.isPreparation,
    required this.isReaction,
  });

  ActionTemplate copyWith({
    String? id,
    String? name,
    String? description,
    bool? isFree,
    bool? isResisted,
    bool? isPreparation,
    bool? isReaction,
  }) {
    return ActionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isFree: isFree ?? this.isFree,
      isResisted: isResisted ?? this.isResisted,
      isPreparation: isPreparation ?? this.isPreparation,
      isReaction: isReaction ?? this.isReaction,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'isFree': isFree,
      'isResisted': isResisted,
      'isPreparation': isPreparation,
      'isReaction': isReaction,
    };
  }

  factory ActionTemplate.fromMap(Map<String, dynamic> map) {
    return ActionTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      isFree: map['isFree'] as bool,
      isResisted: map['isResisted'] as bool,
      isPreparation: map['isPreparation'] as bool,
      isReaction: map['isReaction'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionTemplate.fromJson(String source) =>
      ActionTemplate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ActionTemplate(id: $id, name: $name, description: $description, isFree: $isFree, isResisted: $isResisted, isPreparation: $isPreparation, isReaction: $isReaction)';
  }

  @override
  bool operator ==(covariant ActionTemplate other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.isFree == isFree &&
        other.isResisted == isResisted &&
        other.isPreparation == isPreparation &&
        other.isReaction == isReaction;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        isFree.hashCode ^
        isResisted.hashCode ^
        isPreparation.hashCode ^
        isReaction.hashCode;
  }
}
