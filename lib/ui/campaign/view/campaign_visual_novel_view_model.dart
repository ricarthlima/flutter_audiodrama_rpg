import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_visual_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_vm_model.dart';

class CampaignVisualNovelViewModel extends ChangeNotifier {
  CampaignVisualDataModel data = CampaignVisualDataModel.empty();

  String campaignId;
  CampaignVisualNovelViewModel({required this.campaignId});

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

  Future<void> onSave() async {
    await CampaignVisualService.instance.onSave(
      campaignId: campaignId,
      data: data,
    );
  }

  Future<void> onRemove() async {
    await CampaignVisualService.instance.onRemoveAll(campaignId: campaignId);
  }

  Future<void> onPopulate(String url) async {
    Map<String, List<String>> mapLists =
        await CampaignVisualService.instance.populateFromGitHub(
      campaignId: campaignId,
      repoUrl: url,
    );

    data.listBackgrounds = mapLists["backgrounds"]!
        .map(
          (e) => CampaignVisual.fromUrl(
            url: e,
            type: CampaignVisualType.background,
          ),
        )
        .toList();

    data.listPortraits = mapLists["portraits"]!
        .map(
          (e) => CampaignVisual.fromUrl(
            url: e,
            type: CampaignVisualType.background,
          ),
        )
        .toList();

    data.listAmbiences = mapLists["ambiences"]!
        .map(
          (e) => CampaignVisual.fromUrl(
            url: e,
            type: CampaignVisualType.ambience,
          ),
        )
        .toList();

    data.listMusics = mapLists["musics"]!
        .map(
          (e) => CampaignVisual.fromUrl(
            url: e,
            type: CampaignVisualType.music,
          ),
        )
        .toList();

    data.listSfxs = mapLists["sfxs"]!
        .map(
          (e) => CampaignVisual.fromUrl(
            url: e,
            type: CampaignVisualType.sfx,
          ),
        )
        .toList();

    data.listObjects = mapLists["objects"]!
        .map(
          (e) => CampaignVisual.fromUrl(
            url: e,
            type: CampaignVisualType.objects,
          ),
        )
        .toList();

    await onSave();

    notifyListeners();
  }

  addToLeft(CampaignVisual campaignVisual) {
    data.listLeftActive.add(campaignVisual);
    notifyListeners();
  }

  addToRight(CampaignVisual campaignVisual) {
    data.listRightActive.insert(0, campaignVisual);
    notifyListeners();
  }

  clearFromLeft() {
    data.listLeftActive.clear();
    notifyListeners();
  }

  clearFromRight() {
    data.listRightActive.clear();
    notifyListeners();
  }

  clearAll() {
    data.listLeftActive.clear();
    data.listRightActive.clear();
    data.backgroundActive = null;
  }

  replaceBackground(CampaignVisual campaignVisual) {
    data.backgroundActive = campaignVisual;
    notifyListeners();
  }

  bool isVisualInList({required bool isRight, required CampaignVisual visual}) {
    if (isRight) {
      return data.listRightActive.contains(visual);
    }

    return data.listLeftActive.contains(visual);
  }

  void toggleVisual({required bool isRight, required CampaignVisual visual}) {
    if (isRight) {
      if (data.listRightActive.contains(visual)) {
        data.listRightActive.remove(visual);
      } else {
        addToRight(visual);
      }
    } else {
      if (data.listLeftActive.contains(visual)) {
        data.listLeftActive.remove(visual);
      } else {
        addToLeft(visual);
      }
    }

    onSave();
    notifyListeners();
  }

  toggleBackground(CampaignVisual visualBG) {
    if (data.backgroundActive == visualBG) {
      data.backgroundActive = null;
    } else {
      data.backgroundActive = visualBG;
    }

    if (_isClearLeft) {
      data.listLeftActive.clear();
    }

    if (_isClearRight) {
      data.listRightActive.clear();
    }

    onSave();
    notifyListeners();
  }

  toggleObject(CampaignVisual visualObject) {
    int index = data.listObjects.indexOf(visualObject);
    visualObject.isEnable = !visualObject.isEnable;
    data.listObjects[index] = visualObject;

    onSave();
    notifyListeners();
  }

  bool get isEmpty {
    return data.listBackgrounds.isEmpty &&
        data.listPortraits.isEmpty &&
        data.listMusics.isEmpty &&
        data.listObjects.isEmpty &&
        data.listAmbiences.isEmpty &&
        data.listSfxs.isEmpty;
  }
}

// CampaignVisual _getTestBackground() {
//   return CampaignVisual(
//       name: "Floresta-${Random().nextInt(9999)}",
//       url:
//           "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/floresta.jpg",
//       type: CampaignVisualType.background);
// }

// List<CampaignVisual> _getTestListLeft() {
//   return [
//     "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/Erin.png",
//     "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/Gaspar_Portrait.png",
//   ]
//       .map(
//         (e) => CampaignVisual(
//           name: e.split("/").last.split(".").first,
//           url: e,
//           type: CampaignVisualType.portrait,
//         ),
//       )
//       .toList();
// }

// List<CampaignVisual> _getTestListRight() {
//   return [
//     "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/sombra-portrait.png",
//     "https://raw.githubusercontent.com/ricarthlima/public_image_repo_test/refs/heads/main/viper-portrait.png",
//   ]
//       .map(
//         (e) => CampaignVisual(
//             name: e.split("/").last.split(".").first,
//             url: e,
//             type: CampaignVisualType.portrait),
//       )
//       .toList();
// }

// List<CampaignVisual> _getTestListAll() {
//   return _getTestListLeft() + _getTestListRight();
// }
