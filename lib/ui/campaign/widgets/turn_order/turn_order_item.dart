import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/campaign_turn_order.dart';
import '../../../../domain/models/sheet_model.dart';

class TurnOrderItem extends StatelessWidget {
  final SheetTurnOrder sheetOrder;
  const TurnOrderItem({super.key, required this.sheetOrder});

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    final userProvider = context.watch<UserProvider>();

    List<Sheet> listMySheets = userProvider.getMySheetsByCampaign(
      campaignVM.campaign!.id,
    );

    Sheet sheet =
        (campaignVM.listSheetAppUser.map((e) => e.sheet).toList() +
                listMySheets)
            .where((e) => e.id == sheetOrder.sheetId)
            .first;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    bool canEdit = campaignVM.isOwner || sheet.id == uid;

    return Opacity(
      opacity: sheetOrder.isVisible ? 1 : 0.5,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 40,
          height: 40,
          child: (sheet.imageUrl != null)
              ? Image.network(sheet.imageUrl!)
              : Icon(Icons.person, size: 40),
        ),
        title: Text(sheet.characterName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            (canEdit)
                ? IntrinsicWidth(
                    stepWidth: 32,
                    child: TextFormField(
                      controller: TextEditingController(
                        text: sheetOrder.orderValue.toString(),
                      ),
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(border: InputBorder.none),
                      style: TextStyle(fontFamily: FontFamily.bungee),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (value) {
                        campaignVM.changeTurnValue(
                          sheetId: sheetOrder.sheetId,
                          orderValue: int.parse(value),
                        );
                      },
                    ),
                  )
                : Text(
                    sheetOrder.orderValue.toString(),
                    style: TextStyle(fontFamily: FontFamily.bungee),
                  ),
            if (canEdit)
              IconButton(
                onPressed: () {
                  campaignVM.toggleTurnVisibility(sheetId: sheetOrder.sheetId);
                },
                padding: EdgeInsets.zero,
                tooltip: "Mudar visibilidade",
                icon: Icon(
                  sheetOrder.isVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            if (canEdit)
              IconButton(
                onPressed: () {
                  campaignVM.removeFromTurn(sheetOrder.sheetId);
                },
                padding: EdgeInsets.zero,
                tooltip: "Remover da lista",
                icon: Icon(Icons.delete, color: AppColors.red),
              ),
          ],
        ),
      ),
    );
  }
}
