import 'package:flutter/material.dart';
import '../../../_core/providers/user_provider.dart';
import '../../../domain/models/campaign.dart';
import '../../_core/dimensions.dart';
import '../models/group_action.dart';
import '../../_core/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/sheet_view_model.dart';
import '../widgets/list_actions_widget.dart';

class SheetActionsScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const SheetActionsScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);
    final userProvider = Provider.of<UserProvider>(context);
    return (isVertical(context))
        ? PageView(children: _buildActionsColumns(sheetVM, userProvider))
        : Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: _buildActionsColumns(sheetVM, userProvider),
                ),
              ),
            ),
          );
  }

  List<Widget> _buildActionsColumns(
    SheetViewModel sheetVM,
    UserProvider userProvider,
  ) {
    Campaign? campaign = userProvider.getCampaignBySheet(sheetVM.sheet!.id);

    List<Widget> baseActions = [
      Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Expanded(
            child: ListActionsWidget(
              name: "Básicas",
              isEditing: sheetVM.isEditing,
              groupAction: sheetVM.mapGroupAction[GroupActionIds.basic]!,
            ),
          ),
          ListActionsWidget(
            name: "Resistidas",
            isEditing: sheetVM.isEditing,
            color: AppColors.red,
            groupAction: sheetVM.mapGroupAction[GroupActionIds.resisted]!,
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          ListActionsWidget(
            name: "Força",
            isEditing: sheetVM.isEditing,
            groupAction: sheetVM.mapGroupAction[GroupActionIds.strength]!,
          ),
          Expanded(
            child: ListActionsWidget(
              name: "Agilidade",
              isEditing: sheetVM.isEditing,
              groupAction: sheetVM.mapGroupAction[GroupActionIds.agility]!,
            ),
          ),
        ],
      ),
      ListActionsWidget(
        name: "Intelecto",
        isEditing: sheetVM.isEditing,
        groupAction: sheetVM.mapGroupAction[GroupActionIds.intellect]!,
      ),
      ListActionsWidget(
        name: "Sociais",
        isEditing: sheetVM.isEditing,
        groupAction: sheetVM.mapGroupAction[GroupActionIds.social]!,
      ),
    ];

    List<Widget> myWorks = [];
    List<Widget> campaignWorks = [];

    if (campaign != null) {
      campaignWorks = List.generate(
        campaign.campaignSheetSettings.listActiveWorkIds.length,
        (index) {
          String workId =
              campaign.campaignSheetSettings.listActiveWorkIds[index];
          return ListActionsWidget(
            name: workId,
            color: Colors.amber,
            groupAction: sheetVM.mapGroupAction[workId]!,
            isEditing: sheetVM.isEditing,
          );
        },
      );
    } else {
      myWorks = List.generate(sheetVM.sheet!.listActiveWorks.length, (index) {
        String key = sheetVM.sheet!.listActiveWorks[index];
        return ListActionsWidget(
          name: key,
          color: Colors.amber,
          groupAction: sheetVM.mapGroupAction[key]!,
          isEditing: sheetVM.isEditing,
        );
      });
    }
    return baseActions + myWorks + campaignWorks;
  }
}
