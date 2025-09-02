import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/models/group_action.dart';
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
    return [
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
        ] +
        List.generate(sheetVM.sheet!.listActiveWorks.length, (index) {
          Campaign? campaign = userProvider.getCampaignBySheet(
            sheetVM.sheet!.id,
          );
          String key = sheetVM.sheet!.listActiveWorks[index];

          if (campaign != null &&
              !campaign.campaignSheetSettings.listActiveWorkIds.contains(key)) {
            return SizedBox();
          }
          return ListActionsWidget(
            name: key,
            color: Colors.amber,
            groupAction: sheetVM.mapGroupAction[key]!,
            isEditing: sheetVM.isEditing,
          );
        });
  }
}
