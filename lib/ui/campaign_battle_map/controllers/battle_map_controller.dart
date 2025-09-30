import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../domain/models/campaign.dart';
import '../../../domain/models/sheet_model.dart';
import '../../campaign/view/campaign_view_model.dart';
import '../models/battle_map.dart';
import '../models/token.dart';

class CampaignOwnerBattleMapProvider extends ChangeNotifier {
  CampaignProvider campaignProvider;

  CampaignOwnerBattleMapProvider({required this.campaignProvider});

  BattleMap? battleMap;
  TransformationController gridTrans = TransformationController();
  Campaign? get campaign => campaignProvider.campaign;
  bool get isActive => (campaign != null && battleMap != null)
      ? campaign!.activeBattleMapId == battleMap!.id
      : false;

  void onInitialize(BattleMap bm) {
    battleMap = bm;
    zoom = 1;
    notifyListeners();
  }

  void onUpdate(BattleMap bm) {
    battleMap = bm;
    scheduleSave();
  }

  Timer? schSaveTimer;
  void scheduleSave() {
    notifyListeners();
    if (schSaveTimer != null) {
      schSaveTimer!.cancel();
      schSaveTimer = null;
    }
    schSaveTimer = Timer(Duration(milliseconds: 500), () {
      onSave();
    });
  }

  void onSave() {
    if (campaignProvider.campaign != null && battleMap != null) {
      int index = campaignProvider.campaign!.listBattleMaps.indexWhere(
        (e) => e.id == battleMap!.id,
      );
      if (index != -1) {
        campaignProvider.campaign!.listBattleMaps[index] = battleMap!;
        campaignProvider.onSave();
      }
    }
  }

  void panToken({required Token token, required Point<double> point}) {}

  void resizeToken({required Token token, required Offset size}) {}

  void removeToken({required Token token}) {}

  double _zoom = 1;
  double get zoom => _zoom;
  set zoom(double value) {
    _zoom = value;
    gridTrans.value = Matrix4.identity()..scaleByVector3(Vector3.all(_zoom));
    notifyListeners();
  }

  void setZoom(Size childSize) {
    double zoom = _zoom;
    final Offset c = childSize.center(Offset.zero);

    gridTrans.value = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0.0, 1.0) // tz=0, tw=1
      ..scaleByVector3(Vector3(zoom, zoom, 1.0)) // escala uniforme em X/Y
      ..translateByDouble(-c.dx, -c.dy, 0.0, 1.0); // desfaz a translação
  }

  void addToken({
    required BattleMap battleMap,
    required Sheet sheet,
    required Point<double>
    position, // posição em unidades de grid (âncora no centro)
  }) {
    // Se já houver um token, mover.
    int indexSheet = battleMap.listTokens.indexWhere(
      (e) => e.sheetId == sheet.id,
    );

    bool isMultiple =
        sheet.booleans["MULTIPLE_TOKEN"] != null &&
        sheet.booleans["MULTIPLE_TOKEN"]!;

    if (indexSheet != -1) {
      return moveToken(
        battleMap: battleMap,
        position: position,
        token: battleMap.listTokens[indexSheet],
      );
    }

    String image = (sheet.listTokens.isNotEmpty)
        ? sheet.listTokens[sheet.indexToken]
        : (sheet.imageUrl != null)
        ? sheet.imageUrl!
        : "";

    Size sizeNorm = Size(1, 1);

    Token token = Token(
      id: const Uuid().v4(),
      battleMapId: battleMap.id,
      imageUrl: image,
      stickGrid: false,
      size: sizeNorm,
      position: Point<double>(position.x, position.y),
      rotationDeg: 0,
      zIndex: 0,
      isVisible: true,
      owners: <String>[sheet.ownerId],
      sheetId: !isMultiple ? sheet.id : null,
    );

    battleMap.listTokens.add(token);
    scheduleSave();
  }

  void moveToken({
    required BattleMap battleMap,
    required Point<double> position,
    required Token token,
  }) {
    int mapIndex = campaign!.listBattleMaps.indexWhere(
      (e) => e.id == battleMap.id,
    );
    if (mapIndex == -1) return;

    int tokenIndex = campaign!.listBattleMaps[mapIndex].listTokens.indexWhere(
      (e) => e.id == token.id,
    );
    if (tokenIndex == -1) return;

    Token updated = token.copyWith(position: position);

    campaign!.listBattleMaps[mapIndex].listTokens[tokenIndex] = updated;

    scheduleSave();
  }
}
