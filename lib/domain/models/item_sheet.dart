// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ItemSheet {
  String itemId;
  int uses;
  int amount;
  ItemSheet({required this.itemId, required this.uses, required this.amount});

  ItemSheet copyWith({String? itemId, int? uses, int? amount}) {
    return ItemSheet(
      itemId: itemId ?? this.itemId,
      uses: uses ?? this.uses,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'itemId': itemId, 'uses': uses, 'amount': amount};
  }

  factory ItemSheet.fromMap(Map<String, dynamic> map) {
    return ItemSheet(
      itemId: map['itemId'] as String,
      uses: map['uses'] as int,
      amount: map['amount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemSheet.fromJson(String source) =>
      ItemSheet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ItemSheet(itemId: $itemId, uses: $uses, amount: $amount)';

  @override
  bool operator ==(covariant ItemSheet other) {
    if (identical(this, other)) return true;

    return other.itemId == itemId &&
        other.uses == uses &&
        other.amount == amount;
  }

  @override
  int get hashCode => itemId.hashCode ^ uses.hashCode ^ amount.hashCode;
}
