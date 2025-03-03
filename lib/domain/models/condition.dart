// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Condition {
  String id;
  String name;
  String description;
  int showingOrder;
  Condition({
    required this.id,
    required this.name,
    required this.description,
    required this.showingOrder,
  });

  Condition copyWith({
    String? id,
    String? name,
    String? description,
    int? showingOrder,
  }) {
    return Condition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      showingOrder: showingOrder ?? this.showingOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'showingOrder': showingOrder,
    };
  }

  factory Condition.fromMap(Map<String, dynamic> map) {
    return Condition(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      showingOrder: map['showingOrder'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Condition.fromJson(String source) =>
      Condition.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Condition(id: $id, name: $name, description: $description, showingOrder: $showingOrder)';
  }

  @override
  bool operator ==(covariant Condition other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.showingOrder == showingOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        showingOrder.hashCode;
  }
}
