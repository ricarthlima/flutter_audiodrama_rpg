import 'dart:convert';

import 'package:flutter/foundation.dart';

class CampaignTurnOrder {
  bool isTurnActive;
  int turn;
  int sheetTurn;
  List<SheetTurnOrder> listSheetOrders;

  CampaignTurnOrder({
    required this.isTurnActive,
    required this.turn,
    required this.sheetTurn,
    required this.listSheetOrders,
  });

  CampaignTurnOrder copyWith({
    bool? isTurnActive,
    int? turn,
    int? sheetTurn,
    List<SheetTurnOrder>? listSheetOrders,
  }) {
    return CampaignTurnOrder(
      isTurnActive: isTurnActive ?? this.isTurnActive,
      turn: turn ?? this.turn,
      sheetTurn: sheetTurn ?? this.sheetTurn,
      listSheetOrders: listSheetOrders ?? this.listSheetOrders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isTurnActive': isTurnActive,
      'turn': turn,
      'sheetTurn': sheetTurn,
      'listSheetOrders': listSheetOrders.map((x) => x.toMap()).toList(),
    };
  }

  factory CampaignTurnOrder.fromMap(Map<String, dynamic> map) {
    return CampaignTurnOrder(
      isTurnActive: map['isTurnActive'] ?? false,
      turn: map['turn']?.toInt() ?? 0,
      sheetTurn: map['sheetTurn']?.toInt() ?? 0,
      listSheetOrders: List<SheetTurnOrder>.from(
        map['listSheetOrders']?.map((x) => SheetTurnOrder.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CampaignTurnOrder.fromJson(String source) =>
      CampaignTurnOrder.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CampaignTurnOrder(isTurnActive: $isTurnActive, turn: $turn, sheetTurn: $sheetTurn, listSheetOrders: $listSheetOrders)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CampaignTurnOrder &&
        other.isTurnActive == isTurnActive &&
        other.turn == turn &&
        other.sheetTurn == sheetTurn &&
        listEquals(other.listSheetOrders, listSheetOrders);
  }

  @override
  int get hashCode {
    return isTurnActive.hashCode ^
        turn.hashCode ^
        sheetTurn.hashCode ^
        listSheetOrders.hashCode;
  }
}

class SheetTurnOrder {
  String sheetId;
  int orderValue;
  bool isVisible;

  SheetTurnOrder({
    required this.sheetId,
    required this.orderValue,
    required this.isVisible,
  });

  SheetTurnOrder copyWith({String? sheetId, int? orderValue, bool? isVisible}) {
    return SheetTurnOrder(
      sheetId: sheetId ?? this.sheetId,
      orderValue: orderValue ?? this.orderValue,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sheetId': sheetId,
      'orderValue': orderValue,
      'isVisible': isVisible,
    };
  }

  factory SheetTurnOrder.fromMap(Map<String, dynamic> map) {
    return SheetTurnOrder(
      sheetId: map['sheetId'] ?? '',
      orderValue: map['orderValue']?.toInt() ?? 0,
      isVisible: map['isVisible'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory SheetTurnOrder.fromJson(String source) =>
      SheetTurnOrder.fromMap(json.decode(source));

  @override
  String toString() =>
      'SheetTurnOrder(sheetId: $sheetId, orderValue: $orderValue, isVisible: $isVisible)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SheetTurnOrder &&
        other.sheetId == sheetId &&
        other.orderValue == orderValue &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode =>
      sheetId.hashCode ^ orderValue.hashCode ^ isVisible.hashCode;
}
