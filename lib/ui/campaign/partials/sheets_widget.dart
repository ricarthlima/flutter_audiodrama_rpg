import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/list_sheets_widget.dart';
import 'package:provider/provider.dart';

import '../../home/view/home_interact.dart';

class CampaignSheetsWidget extends StatelessWidget {
  const CampaignSheetsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Column(
      spacing: 32,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: ListSheetsWidget(
            title: "Meus personagens",
            actions: [
              IconButton(
                onPressed: () {
                  HomeInteract.onCreateCharacterClicked(
                    context,
                    campaignId: campaignVM.campaign?.id,
                  );
                },
                tooltip: "Criar personagem",
                icon: Icon(Icons.add),
              ),
            ],
            listSheetsAppUser: userProvider
                .getMySheetsByCampaign(campaignVM.campaign!.id)
                .map(
                  (e) => SheetAppUser(
                    sheet: e,
                    appUser: userProvider.currentAppUser,
                  ),
                )
                .toList(),
          ),
        ),
        if (campaignVM.isOwner)
          Flexible(
            fit: FlexFit.tight,
            child: ListSheetsWidget(
              title: "Outros personagens",
              listSheetsAppUser: campaignVM.listSheetAppUser,
            ),
          ),
      ],
    );
  }
}
