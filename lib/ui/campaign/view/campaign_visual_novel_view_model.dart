import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';

class CampaignVisualNovelViewModel extends ChangeNotifier {
  List<CampaignVisual> listLeftActive = _getTestListLeft();
  List<CampaignVisual> listRightActive = _getTestListRight();
  CampaignVisual? backgroundActive = _getTestBackground();

  List<CampaignVisual> listVisuals = [];

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

  removeFromLeft() {
    listLeftActive.removeLast();
    notifyListeners();
  }

  removeFromRight() {
    listRightActive.removeAt(0);
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
}

CampaignVisual _getTestBackground() {
  return CampaignVisual(
    name: "",
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
          name: "",
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
          name: "",
          imageUrl: e,
          isBackground: false,
        ),
      )
      .toList();
}
