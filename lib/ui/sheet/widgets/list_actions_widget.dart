import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/action_template.dart';
import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../models/group_action.dart';
import '../providers/sheet_view_model.dart';
import 'action_widget.dart';

class ListActionsWidget extends StatelessWidget {
  final String name;
  final GroupAction groupAction;
  final bool isEditing;
  final Color? color;

  const ListActionsWidget({
    super.key,
    required this.name,
    required this.groupAction,
    required this.isEditing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);
    return Container(
      width: (isVertical(context))
          ? width(context) - 100
          : (width(context) / 5) - (30),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: (color != null)
              ? color!
              : Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16, left: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isVertical(context)
                            ? 16
                            : getZoomFactor(context, 18),
                        fontFamily: FontFamily.bungee,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                _ModGroup(sheetVM: sheetVM, groupAction: groupAction),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: // TODO: Ações ativadas por padrão config de campanha
              groupAction.listActions
                  .where((e) => e.enabled)
                  .length,
              itemBuilder: (context, index) {
                ActionTemplate action = groupAction.listActions
                    .where((e) => e.enabled)
                    .toList()[index];

                return ActionWidget(
                  action: action,
                  groupId: groupAction.id,
                  isWork: groupAction.isWork,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModGroup extends StatelessWidget {
  final SheetViewModel sheetVM;
  final GroupAction groupAction;
  const _ModGroup({required this.sheetVM, required this.groupAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (sheetVM.isOwner)
            InkWell(
              onTap: (sheetVM.modValueGroup(groupAction.id) > -4)
                  ? () {
                      sheetVM.changeModGroup(
                        id: groupAction.id,
                        isAdding: false,
                      );
                    }
                  : null,
              child: Icon(Icons.remove),
            ),
          Tooltip(
            message: "Clique para manter o modificador",
            child: SizedBox(
              width: 42,
              child: InkWell(
                onTap: sheetVM.isOwner
                    ? () {
                        sheetVM.toggleModHold(id: groupAction.id);
                      }
                    : null,
                child: Text(
                  sheetVM.modValueGroup(groupAction.id).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontFamily.bungee,
                    color: (sheetVM.modHoldGroup(groupAction.id))
                        ? AppColors.red
                        : null,
                  ),
                ),
              ),
            ),
          ),
          if (sheetVM.isOwner)
            InkWell(
              onTap: (sheetVM.modValueGroup(groupAction.id) < 4)
                  ? () {
                      sheetVM.changeModGroup(
                        id: groupAction.id,
                        isAdding: true,
                      );
                    }
                  : null,
              child: Icon(Icons.add),
            ),
        ],
      ),
    );
  }
}
