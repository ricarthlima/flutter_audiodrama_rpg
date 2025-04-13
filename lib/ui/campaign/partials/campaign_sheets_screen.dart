import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/list_sheets_widget.dart';
import 'package:provider/provider.dart';

import '../../home/view/home_view_model.dart';

class CampaignSheetsScreen extends StatelessWidget {
  const CampaignSheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return (isVertical(context))
        ? SingleChildScrollView(
            child: Column(
              children: _getListWidgets(context, userProvider, campaignVM),
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 64,
            children: _getListWidgets(context, userProvider, campaignVM)
                .map((e) => Flexible(child: e))
                .toList(),
          );
  }

  List<Widget> _getListWidgets(
    BuildContext context,
    UserProvider userProvider,
    CampaignViewModel campaignVM,
  ) {
    return [
      ListSheetsWidget(
        title: "Meus personagens",
        actions: [
          IconButton(
            onPressed: () {
              context.read<HomeViewModel>().onCreateSheetClicked(
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
      if (campaignVM.isOwner)
        ListSheetsWidget(
          title: "Outros personagens",
          listSheetsAppUser: campaignVM.listSheetAppUser,
        ),
    ];
  }
}
