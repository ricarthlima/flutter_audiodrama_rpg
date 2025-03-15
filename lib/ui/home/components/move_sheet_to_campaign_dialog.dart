import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/app_colors.dart';

Future<dynamic> showMoveSheetToCampaignDialog({
  required BuildContext context,
  required Sheet sheet,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: _MoveSheetToCampaignDialog(sheet: sheet),
      );
    },
  );
}

class _MoveSheetToCampaignDialog extends StatefulWidget {
  final Sheet sheet;
  const _MoveSheetToCampaignDialog({required this.sheet});

  @override
  State<_MoveSheetToCampaignDialog> createState() =>
      _MoveSheetToCampaignDialogState();
}

class _MoveSheetToCampaignDialogState
    extends State<_MoveSheetToCampaignDialog> {
  Campaign? campaign;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      setState(() {
        campaign = userProvider.getCampaignBySheet(widget.sheet.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    HomeViewModel homeViewModel = Provider.of<HomeViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 4,
          color: AppColors.red,
        ),
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
            "Mover para campanha",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          DropdownButton<Campaign>(
            value: campaign,
            isExpanded: true,
            items: userProvider.listAllCampaigns.map(
              (Campaign campaign) {
                return DropdownMenuItem<Campaign>(
                  value: campaign,
                  child: Text(campaign.name!),
                );
              },
            ).toList(),
            onChanged: (value) {
              setState(() {
                campaign = value;
              });
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => onSavePressed(homeViewModel),
                child: Text("Salvar"),
              ),
              TextButton(
                onPressed: () => onRemoveCampaignPressed(homeViewModel),
                child: Text(
                  "Remover do mundo",
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onSavePressed(HomeViewModel homeViewModel) async {
    if (campaign != null) {
      await homeViewModel.saveCampaignSheet(
        campaignId: campaign!.id,
        sheetId: widget.sheet.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> onRemoveCampaignPressed(HomeViewModel homeViewModel) async {
    await homeViewModel.removeSheetFromCampaign(widget.sheet.id);
    if (!mounted) return;
    Navigator.pop(context);
  }
}
