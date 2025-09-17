import 'dart:convert';

class SheetCustomCount {
  String id;
  String name;
  String description;
  int count;

  SheetCustomCount({
    required this.id,
    required this.name,
    required this.description,
    required this.count,
  });

  SheetCustomCount copyWith({
    String? id,
    String? name,
    String? description,
    int? count,
  }) {
    return SheetCustomCount(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'count': count};
  }

  factory SheetCustomCount.fromMap(Map<String, dynamic> map) {
    return SheetCustomCount(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      count: map['count']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SheetCustomCount.fromJson(String source) =>
      SheetCustomCount.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SheetCustomCount(id: $id, name: $name, description: $description, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SheetCustomCount &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.count == count;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode ^ count.hashCode;
  }
}
