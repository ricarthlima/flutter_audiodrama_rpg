import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';

class CampaignVisualNovelViewModel extends ChangeNotifier {
  List<CampaignVisual> listLeftActive = [];
  List<CampaignVisual> listRightActive = [];
  CampaignVisual? backgroundActive;

  List<CampaignVisual> listVisuals = _getTestListAll();
  List<CampaignVisual> listBackgrounds = [
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground(),
    _getTestBackground()
  ];

  double visualScale = 512;
  double distanceFactor = 0.60;

  bool _isClearLeft = false;
  bool get isClearLeft => _isClearLeft;
  set isClearLeft(bool value) {
    _isClearLeft = value;
    notifyListeners();
  }

  bool _isClearRight = false;
  bool get isClearRight => _isClearRight;
  set isClearRight(bool value) {
    _isClearRight = value;
    notifyListeners();
  }

  onInitialize() {
    // TODO: Criar serviço
    // TODO: Carregar todos
    // TODO: Capturar últimas informações
    // TODO: Subststituir
  }

  addToLeft(CampaignVisual campaignVisual) {
    listLeftActive.add(campaignVisual);
    notifyListeners();
  }

  addToRight(CampaignVisual campaignVisual) {
    listRightActive.insert(0, campaignVisual);
    notifyListeners();
  }

  clearFromLeft() {
    listLeftActive.clear();
    notifyListeners();
  }

  clearFromRight() {
    listRightActive.clear();
    notifyListeners();
  }

  clearAll() {
    listLeftActive.clear();
    listRightActive.clear();
    backgroundActive = null;
  }

  replaceBackground(CampaignVisual campaignVisual) {
    backgroundActive = campaignVisual;
    notifyListeners();
  }

  bool isVisualInList({required bool isRight, required CampaignVisual visual}) {
    if (isRight) {
      return listRightActive.contains(visual);
    }

    return listLeftActive.contains(visual);
  }

  void toggleVisual({required bool isRight, required CampaignVisual visual}) {
    if (isRight) {
      if (listRightActive.contains(visual)) {
        listRightActive.remove(visual);
      } else {
        addToRight(visual);
      }
    } else {
      if (listLeftActive.contains(visual)) {
        listLeftActive.remove(visual);
      } else {
        addToLeft(visual);
      }
    }

    onSave();
    notifyListeners();
  }

  toggleBackground(CampaignVisual visualBG) {
    if (backgroundActive == visualBG) {
      backgroundActive = null;
    } else {
      backgroundActive = visualBG;
    }
    notifyListeners();
  }

  void onSave() async {
    //TODO: Coisar
  }
}

CampaignVisual _getTestBackground() {
  return CampaignVisual(
    name: "Floresta-${Random().nextInt(9999)}",
    imageUrl:
        "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/floresta.jpg",
    isBackground: true,
  );
}

List<CampaignVisual> _getTestListLeft() {
  return [
    "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/Erin.png",
    "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/Gaspar_Portrait.png",
  ]
      .map(
        (e) => CampaignVisual(
          name: e.split("/").last.split(".").first,
          imageUrl: e,
          isBackground: false,
        ),
      )
      .toList();
}

List<CampaignVisual> _getTestListRight() {
  return [
    "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/sombra-portrait.png",
    "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/viper-portrait.png",
  ]
      .map(
        (e) => CampaignVisual(
          name: e.split("/").last.split(".").first,
          imageUrl: e,
          isBackground: false,
        ),
      )
      .toList();
}

List<CampaignVisual> _getTestListAll() {
  return _getTestListLeft() + _getTestListRight();
}
