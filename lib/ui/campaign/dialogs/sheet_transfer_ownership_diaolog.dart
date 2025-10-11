import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/sheet_service.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/circular_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_user.dart';
import '../../../domain/models/sheet_model.dart';
import '../../_core/app_colors.dart';
import '../view/campaign_view_model.dart';

Future<dynamic> showSheetTransferOwnershipDialog({
  required BuildContext context,
  required Sheet sheet,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(child: _SheetTransferOwnershipDialog(sheet: sheet));
    },
  );
}

class _SheetTransferOwnershipDialog extends StatefulWidget {
  final Sheet sheet;
  const _SheetTransferOwnershipDialog({required this.sheet});

  @override
  State<_SheetTransferOwnershipDialog> createState() =>
      _SheetTransferOwnershipDialogState();
}

class _SheetTransferOwnershipDialogState
    extends State<_SheetTransferOwnershipDialog> {
  AppUser? currentOwner;
  List<AppUser> listUsers = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignVM = context.read<CampaignProvider>();
      setState(() {
        listUsers = campaignVM.listUsers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: AppColors.red),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.all(32),
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          Text(
            "Transferir ${widget.sheet.characterName} para:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          DropdownButton<AppUser>(
            value: currentOwner,
            isExpanded: true,
            items: listUsers.map((AppUser user) {
              return DropdownMenuItem<AppUser>(
                value: user,
                child: Text(user.username ?? ""),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                currentOwner = value;
              });
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () =>
                    (currentOwner != null) ? onSavePressed() : null,
                child: (isLoading) ? CPIElevatedButton() : Text("Salvar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onSavePressed() async {
    if (currentOwner != null) {
      setState(() {
        isLoading = true;
      });
      await SheetService().transferOwnership(
        sheet: widget.sheet,
        user: currentOwner!,
        campaignId: context.read<CampaignProvider>().campaign!.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
