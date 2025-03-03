// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Item {
  final String id;
  final String name;
  final double weight;
  final int price;
  final String description;
  final String mechanic;
  final bool isFinite;
  final int? maxUses;
  final List<String> listCategories;

  Item({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.description,
    required this.mechanic,
    required this.isFinite,
    this.maxUses,
    required this.listCategories,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'weight': weight,
      'price': price,
      'description': description,
      'mechanic': mechanic,
      'isFinite': isFinite,
      'maxUses': maxUses,
      'categories': listCategories,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      weight: map['weight'] as double,
      price: map['price'] as int,
      description: map['description'] as String,
      mechanic: map['mechanic'] as String,
      isFinite: map['isFinite'] as bool,
      maxUses: map['maxUses'] != null ? map['maxUses'] as int : null,
      listCategories: (map['categories'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);
}
