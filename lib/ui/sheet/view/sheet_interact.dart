import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/daos/action_dao.dart';
import '../../../domain/models/action_template.dart';
import '../../../domain/models/roll_log.dart';
import '../../_core/dimensions.dart';
import '../../sheet_notes/sheet_notes.dart';
import '../../shopping/shopping_screen.dart';
import '../../shopping/view/shopping_view_model.dart';
import '../../statistics/statistics_screen.dart';
import '../../statistics/view/statistics_view_model.dart';
import '../components/action_dialog_tooltip.dart';
import '../components/roll_body_dialog.dart';
import '../components/roll_dialog.dart';
import '../components/sheet_works_dialog.dart';
import 'sheet_view_model.dart';

abstract class SheetInteract {
  static Future<void> onRollBodyDice(
      {required BuildContext context, required bool isSerious}) {
    int roll = Random().nextInt(6) + 1;
    return showRollBodyDialog(
      context: context,
      roll: roll,
      isSerious: isSerious,
    );
  }

  static onItemsButtonClicked(BuildContext context) async {
    final shoppingVM = Provider.of<ShoppingViewModel>(
      context,
      listen: false,
    );
    shoppingVM.openInventory(context.read<SheetViewModel>().listSheetItems);

    if (!isVertical(context)) {
      await showShoppingDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingDialogScreen(),
        ),
      );
    }
  }

  static Future<void> onNotesButtonClicked(BuildContext context) async {
    if (!isVertical(context)) {
      await showSheetNotesDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetNotesScreen(),
        ),
      );
    }
  }

  static onStatisticsButtonClicked(BuildContext context) async {
    context.read<StatisticsViewModel>().listCompleteRollLog =
        context.read<SheetViewModel>().listRollLog;

    if (!isVertical(context)) {
      await showSheetStatisticsDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetStatisticsScreen(),
        ),
      );
    }
  }

  static void onWorksButtonClicked(BuildContext context) async {
    if (!isVertical(context)) {
      await showSheetWorksDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetWorksDialog(),
        ),
      );
    }
  }

  static Future<void> rollAction({
    required BuildContext context,
    required ActionTemplate action,
  }) async {
    SheetViewModel sheetVM = context.read<SheetViewModel>();

    List<int> rolls = [];

    int newActionValue =
        sheetVM.getTrainLevelByAction(action.id) + (sheetVM.modGlobalTrain);

    if (newActionValue < 0) {
      newActionValue = 0;
    }

    if (newActionValue > 4) {
      newActionValue = 4;
    }

    if (ActionDAO.instance.isOnlyFreeOrPreparation(action.id)) {
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
    );

    _showRolls(context: context, roll: roll);
    sheetVM.onRoll(roll: roll);
  }

  static Future<void> _showRolls(
      {required BuildContext context, required RollLog roll}) async {
    ActionTemplate? action = ActionDAO.instance.getActionById(roll.idAction);

    if (!ActionDAO.instance.isOnlyFreeOrPreparation(roll.idAction) ||
        ActionDAO.instance.isLuckAction(roll.idAction)) {
      return showRollDialog(context: context, rollLog: roll);
    } else {
      if (action != null) {
        return showDialogTip(
          context,
          action,
          isEffortUsed: action.isPreparation,
        );
      }
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
