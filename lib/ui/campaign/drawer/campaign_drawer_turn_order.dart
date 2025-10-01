import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/turn_order/turn_order_item.dart';
import 'package:provider/provider.dart';

import '../../_core/widgets/generic_header.dart';

class CampaignDrawerTurnOrder extends StatelessWidget {
  const CampaignDrawerTurnOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();

    if (campaignVM.campaign == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenericHeader(
          title: "Turnos",
          actions: [
            if (campaignVM.isOwner)
              IconButton(
                onPressed: () {
                  campaignVM.removeSheetTurn();
                },
                icon: Icon(Icons.arrow_back),
              ),
            if (campaignVM.isOwner)
              IconButton(
                onPressed: () {
                  campaignVM.addSheetTurn();
                },
                icon: Icon(Icons.arrow_forward),
              ),
          ],
        ),
        Expanded(
          child: ListView(
            children: List.generate(
              campaignVM.campaign!.campaignTurnOrder.listSheetOrders.length,
              (index) {
                final sheetOrder = campaignVM
                    .campaign!
                    .campaignTurnOrder
                    .listSheetOrders[index];
                return TurnOrderItem(sheetOrder: sheetOrder, index: index);
              },
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                if (campaignVM.isOwner)
                  InkWell(
                    onTap: () {
                      campaignVM.removeTurn();
                    },
                    child: Icon(Icons.remove),
                  ),
                Text(
                  campaignVM.campaign!.campaignTurnOrder.turn.toString(),
                  style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 18),
                ),
                if (campaignVM.isOwner)
                  InkWell(
                    onTap: () {
                      campaignVM.addTurn();
                    },
                    child: Icon(Icons.add),
                  ),
              ],
            ),
            Opacity(
              opacity: 0.5,
              child: Text(
                "TURNO ATUAL",
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
