import 'dart:math';

import 'package:flutter/material.dart';

import '../models/battle_map.dart';
import '../models/token.dart';

class BattleMapController extends ChangeNotifier {
  bool? isCampaignOwner;
  BattleMap? battleMap;

  void onInitialize({required BattleMap bm, required bool isOwner}) {
    isCampaignOwner = isOwner;
    battleMap = bm;
    notifyListeners();
  }

  void addToken({
    required Token token,
    required Point<double> point,
    required Offset size,
  }) {}

  void panToken({required Token token, required Point<double> point}) {}

  void resizeToken({required Token token, required Offset size}) {}

  void removeToken({required Token token}) {}
}
