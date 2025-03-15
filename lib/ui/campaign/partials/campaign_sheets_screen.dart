import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/widgets/home_list_item_widget.dart';
import 'package:provider/provider.dart';

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
            children: _getListWidgets(context, userProvider, campaignVM)
                .map(
                  (e) => Flexible(
                    child: SingleChildScrollView(
                      child: e,
                    ),
                  ),
                )
                .toList(),
          );
  }

  List<Widget> _getListWidgets(
    BuildContext context,
    UserProvider userProvider,
    CampaignViewModel campaignVM,
  ) {
    return [
      Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            "Meus personagens",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: userProvider
                .getMySheetsByCampaign(campaignVM.campaignId!)
                .map((sheet) => HomeListItemWidget(
                      sheet: sheet,
                      username: userProvider.currentAppUser.username!,
                      isShowingByCampaign: true,
                    ))
                .toList(),
          ),
          if (isVertical(context))
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                thickness: 0.1,
              ),
            ),
        ],
      ),
      if (campaignVM.isOwner)
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              "Outros personagens",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: campaignVM.mapSheetOthers.keys
                  .map((e) => HomeListItemWidget(
                        sheet: e,
                        username: campaignVM.mapSheetOthers[e]!.username!,
                        isShowingByCampaign: true,
                        appUser: campaignVM.mapSheetOthers[e],
                      ))
                  .toList(),
            ),
          ],
        ),
    ];
  }
}
