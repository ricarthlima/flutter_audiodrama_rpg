import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../_core/providers/audio_provider.dart';
import '../../../data/services/campaign_roll_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../domain/models/campaign_roll.dart';
import '../../_core/constants/roll_type.dart';
import '../../_core/snackbars/snackbars.dart';
import '../../campaign/view/campaign_view_model.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/dto/spell.dart';
import '../../../domain/exceptions/general_exceptions.dart';
import '../../_core/utils/load_image.dart';
import '../helpers/sheet_subpages.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/action_template.dart';
import '../../../domain/models/roll_log.dart';
import '../components/roll_body_dialog.dart';
import 'sheet_view_model.dart';

abstract class SheetInteract {
  static Future<void> onRollBodyDice({
    required BuildContext context,
    required bool isSerious,
  }) {
    int roll = Random().nextInt(6) + 1;
    return showRollBodyDialog(
      context: context,
      roll: roll,
      isSerious: isSerious,
    );
  }

  static Future<void> onItemsButtonClicked(BuildContext context) async {
    context.read<SheetViewModel>().currentPage = SheetSubpages.items;
  }

  static Future<void> onMagicButtonClicked(BuildContext context) async {
    context.read<SheetViewModel>().currentPage = SheetSubpages.magic;
  }

  static Future<void> onNotesButtonClicked(BuildContext context) async {
    context.read<SheetViewModel>().currentPage = SheetSubpages.notes;
  }

  static Future<void> onStatisticsButtonClicked(BuildContext context) async {
    context.read<SheetViewModel>().currentPage = SheetSubpages.statistics;
  }

  static void onSettingsButtonClicked(BuildContext context) async {
    context.read<SheetViewModel>().currentPage = SheetSubpages.settings;
  }

  static Future<void> rollAction({
    required BuildContext context,
    required ActionTemplate action,
    required String groupId,
    required RollType rollType,
    Spell? spell,
    bool? rollInitiativeVisible,
  }) async {
    SheetViewModel sheetVM = context.read<SheetViewModel>();
    CampaignProvider campaignVM = context.read<CampaignProvider>();

    AudioProvider audioProvider = Provider.of<AudioProvider>(
      context,
      listen: false,
    );

    List<int> rolls = [];

    int newActionValue =
        sheetVM.getTrainLevelByAction(action.id) +
        (sheetVM.modValueGroup(groupId));

    if (newActionValue < 0) {
      newActionValue = 0;
    }

    if (newActionValue > 4) {
      newActionValue = 4;
    }

    if (context.read<SheetViewModel>().actionRepo.isOnlyFreeOrPreparation(
      action.id,
    )) {
      rolls.add(Random().nextInt(20) + 1);
    } else {
      if (newActionValue == 0 || newActionValue == 4) {
        rolls.add(Random().nextInt(20) + 1);
        rolls.add(Random().nextInt(20) + 1);
        rolls.add(Random().nextInt(20) + 1);
      } else if (newActionValue == 1 || newActionValue == 3) {
        rolls.add(Random().nextInt(20) + 1);
        rolls.add(Random().nextInt(20) + 1);
      } else if (newActionValue == 2) {
        rolls.add(Random().nextInt(20) + 1);
      }
    }

    RollLog roll = RollLog(
      rolls: rolls,
      idAction: action.id,
      dateTime: DateTime.now(),
      isGettingLower: newActionValue <= 1,
      rollType: rollType,
      idSpell: spell?.name,
      sheetName: sheetVM.sheet!.characterName,
    );

    sheetVM.onRoll(roll: roll, groupId: groupId);
    if (rollInitiativeVisible != null && campaignVM.campaign != null) {
      campaignVM.rollInitiative(
        sheet: sheetVM.sheet!,
        isVisible: rollInitiativeVisible,
        rollValue: (roll.isGettingLower)
            ? rolls.reduce((v, e) => v = min(v, e))
            : rolls.reduce((v, e) => v = max(v, e)),
      );
    }

    for (int i = 0; i < rolls.length; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      audioProvider.playDice(i);
    }

    if (campaignVM.campaign != null) {
      CampaignRollService.instance.registerRoll(
        campaignRoll: CampaignRoll(
          id: Uuid().v8(),
          userId: FirebaseAuth.instance.currentUser!.uid,
          campaignId: campaignVM.campaign!.id,
          sheetId: sheetVM.sheet!.id,
          createdAt: DateTime.now(),
          rollLog: roll,
        ),
      );

      bool publicRolls =
          campaignVM.campaign!.campaignSheetSettings.activePublicRolls;

      if (publicRolls && sheetVM.isShowingRolls) {
        ChatService.instance.sendRollToChat(
          campaignId: campaignVM.campaign!.id,
          rolllog: roll,
        );
      }
    }
  }

  static Future<void> onUploadBioImageClicked(BuildContext context) async {
    try {
      Uint8List? image = await loadAndCompressImage(context);
      if (image != null) {
        if (!context.mounted) return;
        context.read<SheetViewModel>().onUploadBioImageClicked(image);
      }
    } on ImageTooLargeException {
      if (!context.mounted) return;
      showImageTooLargeSnackbar(context);
    }
  }
}
