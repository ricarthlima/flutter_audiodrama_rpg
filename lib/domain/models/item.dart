class Item {
  final String id;
  final String name;
  final double weight;
  final int price;
  final String description;
  final String mechanic;
  final bool isFinite;
  final int? maxUses;

  Item({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.description,
    required this.mechanic,
    required this.isFinite,
    this.maxUses,
  });

  factory Item.fromMap(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      price: json['price'],
      description: json['description'],
      mechanic: json['mechanic'],
      isFinite: json['isFinite'],
      maxUses: json.containsKey('maxUses') ? json['maxUses'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'price': price,
      'description': description,
      'mechanic': mechanic,
      'isFinite': isFinite,
      if (maxUses != null) 'maxUses': maxUses,
    };
  }
}
