import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/audio_provider.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_roll_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_roll.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/constants/roll_type.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/dto/spell.dart';
import '../helpers/sheet_subpages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/action_template.dart';
import '../../../domain/models/roll_log.dart';
import '../../sheet_statistics/view/statistics_view_model.dart';
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
    //TODO: Provovalmente é melhor isso estar no initState da tela
    context.read<StatisticsViewModel>().listCompleteRollLog = context
        .read<SheetViewModel>()
        .sheet!
        .listRollLog;

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
  }) async {
    SheetViewModel sheetVM = context.read<SheetViewModel>();
    CampaignViewModel campaignVM = context.read<CampaignViewModel>();

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
    );

    sheetVM.onRoll(roll: roll, groupId: groupId);

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
    }
  }

  static Future<void> onUploadBioImageClicked(BuildContext context) async {
    ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );

    if (image != null) {
      if (!context.mounted) return;
      context.read<SheetViewModel>().onUploadBioImageClicked(image);
    }
  }
}
