import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/utils/change_url.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../../_core/widgets/compactable_button.dart';
import '../../settings/settings_screen.dart';

class CampaignDrawer extends StatelessWidget {
  const CampaignDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignVM = Provider.of<CampaignViewModel>(context);

    return MouseRegion(
      onEnter: (_) => campaignVM.isDrawerClosed = false,
      onExit: (_) => campaignVM.isDrawerClosed = true,
      child: AnimatedContainer(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(
              (campaignVM.isDrawerClosed) ? 0 : 250,
            ),
        duration: Duration(milliseconds: 350),
        curve: Curves.ease,
        width: (campaignVM.isDrawerClosed) ? 48 : 275,
        height: height(context),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 8,
              children: [
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: campaignVM.currentPage == CampaignSubPages.home,
                  ),
                  title: "Início",
                  leadingIcon: Icons.home,
                  onPressed: () {
                    campaignVM.currentPage = CampaignSubPages.home;
                    changeURL(
                      "campaign/${campaignVM.campaign?.id}/${CampaignSubPages.home.name}",
                    );
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected:
                        campaignVM.currentPage == CampaignSubPages.sheets,
                  ),
                  title: "Personagens",
                  leadingIcon: Icons.list_alt_sharp,
                  onPressed: () {
                    campaignVM.currentPage = CampaignSubPages.sheets;
                    changeURL(
                      "campaign/${campaignVM.campaign?.id}/${CampaignSubPages.sheets.name}",
                    );
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected:
                        campaignVM.currentPage == CampaignSubPages.achievements,
                  ),
                  title: "Conquistas",
                  leadingIcon: Icons.star,
                  onPressed: () {
                    campaignVM.currentPage = CampaignSubPages.achievements;
                    changeURL(
                      "campaign/${campaignVM.campaign?.id}/${CampaignSubPages.achievements.name}",
                    );
                  },
                ),
              ],
            ),
            //TODO: RollLog
            CompactableButton(
              controller: CompactableButtonController(
                isCompressed: campaignVM.isDrawerClosed,
                isSelected: false,
              ),
              title: "Configurações",
              leadingIcon: Icons.settings,
              onPressed: () {
                showSettingsDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
