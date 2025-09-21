import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'audio_provider.dart';
import '../../data/services/sheet_service.dart';
import '../../ui/campaign/view/campaign_view_model.dart';
import '../../ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/campaign_service.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/campaign.dart';
import '../../domain/models/campaign_sheet.dart';
import '../../domain/models/sheet_model.dart';

class UserProvider extends ChangeNotifier {
  List<Sheet> listSheets = [];
  List<Campaign> listCampaigns = [];
  List<Campaign> listCampaignsInvited = [];
  List<CampaignSheet> listCampaignsSheet = [];

  StreamSubscription? _streamSheets;
  StreamSubscription? _streamMyCampaigns;
  StreamSubscription? _streamInvitedCampaigns;
  StreamSubscription? _streamSheetsCampaigns;

  StreamSubscription? _streamCurrentCampaign;

  List<Campaign> get listAllCampaigns {
    return listCampaigns + listCampaignsInvited;
  }

  AppUser currentAppUser = AppUser(email: "", username: "", id: "");

  bool finishedLoading = false;

  Future<void> onInitialize() async {
    await onInitializeUser();

    await onInitializeSheets();

    await onInitializeCampaigns();

    await onInitializeOtherCampaigns();

    await onInitializeCampaignSheets();

    finishedLoading = true;

    notifyListeners();
  }

  Future<void> onInitializeUser() async {
    AppUser? appUser = await AuthService().getCurrentUserInfos();
    if (appUser != null) {
      currentAppUser = appUser;
      notifyListeners();
    }
  }

  Future<void> onInitializeCampaignSheets() async {
    listCampaignsSheet = await CampaignService.instance.getListCampaignSheet();
    _streamSheetsCampaigns = CampaignService.instance
        .getCampaignSheetStream()
        .listen((snapshot) {
          listCampaignsSheet = snapshot.docs
              .map((e) => CampaignSheet.fromMap(e.data()))
              .toList();
          notifyListeners();
        });
  }

  Future<void> onInitializeOtherCampaigns() async {
    listCampaignsInvited = await CampaignService.instance
        .getListInvitedCampaigns();
    _streamInvitedCampaigns = CampaignService.instance
        .getInvitedCampaignsStream()
        .listen((snapshot) {
          listCampaignsInvited = snapshot.docs
              .map((e) => Campaign.fromMap(e.data()))
              .toList();
          notifyListeners();
        });
  }

  Future<void> onInitializeCampaigns() async {
    listCampaigns = await CampaignService.instance.getListMyCampaigns();
    _streamMyCampaigns = CampaignService.instance.getMyCampaignsStream().listen(
      (snapshot) {
        listCampaigns = snapshot.docs
            .map((e) => Campaign.fromMap(e.data()))
            .toList();
        notifyListeners();
      },
    );
  }

  Future<void> onInitializeSheets() async {
    listSheets = await SheetService().getSheetsByUser();
    _streamSheets = SheetService().listenSheetsByUser().listen((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      listSheets = snapshot.docs.map((e) => Sheet.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  Future<void> onDispose() async {
    if (_streamSheets != null) {
      await _streamSheets!.cancel();
    }
    if (_streamMyCampaigns != null) {
      await _streamMyCampaigns!.cancel();
    }
    if (_streamInvitedCampaigns != null) {
      await _streamInvitedCampaigns!.cancel();
    }
    if (_streamSheetsCampaigns != null) {
      await _streamSheetsCampaigns!.cancel();
    }
  }

  Campaign? getCampaignBySheet(String sheetId) {
    var listCS = listCampaignsSheet.where((e) => e.sheetId == sheetId).toList();
    if (listCS.isNotEmpty) {
      var listC = listAllCampaigns.where((e) => e.id == listCS[0].campaignId);
      if (listC.isNotEmpty) {
        return listC.first;
      }
    }
    return null;
  }

  List<Sheet> getMySheetsByCampaign(String campaignId) {
    List<Sheet> listS = [];

    List<CampaignSheet> listCS = listCampaignsSheet
        .where((e) => e.campaignId == campaignId)
        .toList();

    for (CampaignSheet cs in listCS) {
      if (listSheets.where((e) => e.id == cs.sheetId).isNotEmpty) {
        listS.add(listSheets.where((e) => e.id == cs.sheetId).first);
      }
    }
    return listS;
  }

  Future<void> initializeCampaign({
    required BuildContext context,
    required String campaignId,
  }) async {
    await _streamCurrentCampaign?.cancel();

    final completer = Completer<void>();

    _streamCurrentCampaign = CampaignService.instance
        .getCampaignStreamById(campaignId)
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.exists) {
            if (snapshot.data() != null) {
              Campaign campaign = Campaign.fromMap(snapshot.data()!);
              if (context.mounted) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  context.read<CampaignProvider>().forceUpdateCampaign(
                    campaign,
                  );
                  context.read<CampaignProvider>().activatePresence();

                  context.read<CampaignVisualNovelViewModel>().campaignId =
                      campaignId;
                  context.read<CampaignVisualNovelViewModel>().data =
                      campaign.visualData;

                  if (context.read<CampaignProvider>().hasInteracted) {
                    playCampaignAudios(campaign, context);
                  }
                  completer.complete();
                });
              }
            }
          }
        });

    return completer.future;
  }

  void playCampaignAudios(Campaign campaign, BuildContext context) {
    if (campaign.audioCampaign.ambienceUrl != null) {
      context.read<AudioProvider>().setAndPlay(
        type: AudioProviderType.ambience,
        url: campaign.audioCampaign.ambienceUrl!,
        volume: campaign.audioCampaign.ambienceVolume ?? 1,
        timeStarted: campaign.audioCampaign.ambienceStarted ?? DateTime.now(),
      );
    } else {
      context.read<AudioProvider>().stop(AudioProviderType.ambience);
    }

    if (campaign.audioCampaign.musicUrl != null) {
      context.read<AudioProvider>().setAndPlay(
        type: AudioProviderType.music,
        url: campaign.audioCampaign.musicUrl!,
        volume: campaign.audioCampaign.musicVolume ?? 1,
        timeStarted: campaign.audioCampaign.musicStarted ?? DateTime.now(),
      );
    } else {
      context.read<AudioProvider>().stop(AudioProviderType.music);
    }

    if (campaign.audioCampaign.sfxUrl != null &&
        campaign.audioCampaign.sfxStarted != null &&
        campaign.audioCampaign.sfxStarted!.difference(DateTime.now()) <=
            Duration(seconds: 5)) {
      context.read<AudioProvider>().setAndPlay(
        type: AudioProviderType.sfx,
        url: campaign.audioCampaign.sfxUrl!,
        volume: campaign.audioCampaign.sfxVolume ?? 1,
        timeStarted: campaign.audioCampaign.sfxStarted,
      );
    } else {
      context.read<AudioProvider>().stop(AudioProviderType.sfx);
    }
  }

  Future<void> disposeCampaign() async {
    if (_streamCurrentCampaign != null) {
      await _streamCurrentCampaign!.cancel();
      _streamCurrentCampaign = null;
    }
  }

  List<Sheet> get listSheetsInCampaigns {
    if (!finishedLoading) return [];
    return listSheets.where((sheet) {
      return getCampaignBySheet(sheet.id) != null;
    }).toList();
  }

  List<Sheet> get listSheetsOutCampaigns {
    if (!finishedLoading) return [];
    return listSheets.where((sheet) {
      return getCampaignBySheet(sheet.id) == null;
    }).toList();
  }
}
