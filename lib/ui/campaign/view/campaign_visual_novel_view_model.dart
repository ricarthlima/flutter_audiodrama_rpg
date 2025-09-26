import 'package:flutter/foundation.dart';
import '../../../data/services/campaign_visual_service.dart';
import '../../../domain/models/campaign_visual.dart';
import '../../../domain/models/campaign_vm_model.dart';

enum PopulateType { github, server }

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

  bool _isClearZoomAndPan = true;
  bool get isClearZoomAndPan => _isClearZoomAndPan;
  set isClearZoomAndPan(bool value) {
    _isClearZoomAndPan = value;
    notifyListeners();
  }

  void onInitialize() {
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
    notifyListeners();
  }

  Future<void> onRemove() async {
    await CampaignVisualService.instance.onRemoveAll(campaignId: campaignId);
  }

  Future<void> onPopulate({
    required String url,
    required PopulateType type,
  }) async {
    Map<String, List<String>> mapLists = {};

    switch (type) {
      case PopulateType.github:
        mapLists = await CampaignVisualService.instance.populateFromGitHub(
          repoUrl: url,
        );
        break;
      case PopulateType.server:
        mapLists = await CampaignVisualService.instance.populateFromServer(
          baseUrl: url,
        );
    }

    data.baseUrl = url;

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
          (e) =>
              CampaignVisual.fromUrl(url: e, type: CampaignVisualType.ambience),
        )
        .toList();

    data.listMusics = mapLists["musics"]!
        .map(
          (e) => CampaignVisual.fromUrl(url: e, type: CampaignVisualType.music),
        )
        .toList();

    data.listSfxs = mapLists["sfxs"]!
        .map(
          (e) => CampaignVisual.fromUrl(url: e, type: CampaignVisualType.sfx),
        )
        .toList();

    data.listObjects = mapLists["objects"]!
        .map(
          (e) =>
              CampaignVisual.fromUrl(url: e, type: CampaignVisualType.objects),
        )
        .toList();

    await onSave();

    notifyListeners();
  }

  void addToLeft(CampaignVisual campaignVisual) {
    data.listLeftActive.add(campaignVisual);
    notifyListeners();
  }

  void addToRight(CampaignVisual campaignVisual) {
    data.listRightActive.insert(0, campaignVisual);
    notifyListeners();
  }

  void clearFromLeft() {
    data.listLeftActive.clear();
    notifyListeners();
  }

  void clearFromRight() {
    data.listRightActive.clear();
    notifyListeners();
  }

  void clearAll() {
    data.listLeftActive.clear();
    data.listRightActive.clear();
    data.backgroundActive = null;
  }

  void replaceBackground(CampaignVisual campaignVisual) {
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

  void toggleBackground(CampaignVisual visualBG) {
    if (data.backgroundActive == visualBG) {
      data.backgroundActive = null;
    } else {
      data.backgroundActive = visualBG;
      data.backgroundActive!.isEnable = true;
    }

    if (data.backgroundActive != null) {
      for (var vb in data.listBackgrounds) {
        if (vb.name == data.backgroundActive!.name) {
          vb.isEnable = true;
        } else {
          vb.isEnable = false;
        }
      }
    } else {
      for (var vb in data.listBackgrounds) {
        vb.isEnable = false;
      }
    }

    if (_isClearLeft) {
      data.listLeftActive.clear();
    }

    if (_isClearRight) {
      data.listRightActive.clear();
    }

    if (_isClearZoomAndPan) {
      data.allowPan = false;
      data.allowZoom = false;
    }

    notifyListeners();
    onSave();
  }

  void toggleObject(CampaignVisual visualObject) {
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

  void togglePan() {
    data.allowPan = !data.allowPan;
    notifyListeners();
    onSave();
  }

  void toggleZoom() {
    data.allowZoom = !data.allowZoom;
    notifyListeners();
    onSave();
  }
}
