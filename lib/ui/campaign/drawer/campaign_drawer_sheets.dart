import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../_core/widgets/generic_header.dart';
import '../../home/view/home_interact.dart';
import '../view/campaign_view_model.dart';
import '../widgets/list_sheets_widget.dart';

class CampaignDrawerSheets extends StatelessWidget {
  const CampaignDrawerSheets({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        GenericHeader(title: "Fichas"),
        Flexible(
          child: Column(
            spacing: 32,
            children: [
              Flexible(
                fit: FlexFit.loose,
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
                  showExpand: true,
                ),
              ),
              if (campaignVM.isOwner)
                Flexible(
                  fit: FlexFit.loose,
                  child: ListSheetsWidget(
                    title: "Outros personagens",
                    listSheetsAppUser: campaignVM.listSheetAppUser,
                    showExpand: true,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
