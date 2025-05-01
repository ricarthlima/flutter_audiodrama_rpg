import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/components/remove_dialog.dart';
import '../components/create_sheet_dialog.dart';
import 'home_view_model.dart';

abstract class HomeInteract {
  static Future<void> onCreateCharacterClicked(
    BuildContext context, {
    String? campaignId,
  }) async {
    String? resultName = await showCreateSheetDialog(context);
    if (resultName != null) {
      if (!context.mounted) return;
      context.read<HomeViewModel>().onCreateSheetClicked(
            name: resultName,
            campaignId: campaignId,
          );
    }
  }

  static Future<void> onRemoveSheet({
    required BuildContext context,
    required Sheet sheet,
  }) async {
    bool? isRemoving = await showRemoveSheetDialog(
      context: context,
      name: sheet.characterName,
    );

    if (isRemoving != null && isRemoving) {
      if (!context.mounted) return;
      await context.read<HomeViewModel>().onRemoveSheet(sheet: sheet);
    }
  }
}
