import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/settings/view/settings_provider.dart';
import '../_core/dimensions.dart';
import '../_core/widgets/vertical_split_view.dart';
import 'sections/ambience_assets_section.dart';
import 'sections/campaign_owner_visual_novel_section.dart';
import 'utils/campaign_scenes.dart';
import 'view/campaign_view_model.dart';
import 'view/campaign_visual_novel_view_model.dart';
import 'widgets/list_settings.dart';
import '../campaign_battle_map/sections/campaign_grid_owner.dart';
import 'package:provider/provider.dart';

import '../_core/fonts.dart';
import 'components/tutorial_populate_dialog.dart';

class CampaignOwnerSubScreen extends StatefulWidget {
  const CampaignOwnerSubScreen({super.key});

  @override
  State<CampaignOwnerSubScreen> createState() => _CampaignOwnerSubScreenState();
}

class _CampaignOwnerSubScreenState extends State<CampaignOwnerSubScreen> {
  double verticalRatio = 0.75;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      settings.getVerticalSplitRatio().then((ratio) {
        setState(() {
          verticalRatio = ratio;
          print(verticalRatio);
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);

    if (visualVM.isEmpty) {
      return _CampaignOwnerEmpty();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 96, bottom: 16),
      child: SizedBox(
        width: width(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            ListSettings(),
            Expanded(
              child: VerticalSplitView(
                initialRatio: verticalRatio,
                minRatio: 0.2,
                maxRatio: 0.9,
                dividerThickness: 4,
                spacing: 10,
                dragSensitivity: 10,
                onChange: (ratio) {
                  context.read<SettingsProvider>().setVerticalSplitRatio(ratio);
                },
                top: switch (campaignVM.campaignScene) {
                  CampaignScenes.visual => CampaignOwnerVisualNovelSection(
                    visualVM: visualVM,
                  ),
                  CampaignScenes.grid => CampaignGridOwner(),
                  CampaignScenes.cutscenes => Placeholder(),
                },

                bottom: AmbienceAssetsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignOwnerEmpty extends StatelessWidget {
  const _CampaignOwnerEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(
            "Mesa de Ambientação",
            style: TextStyle(fontSize: 22, fontFamily: FontFamily.bungee),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showTutorialServer(context);
                },
                icon: Icon(Icons.podcasts),
                label: Text("Popular do servidor"),
              ),
            ],
          ),
          Opacity(
            opacity: 0.7,
            child: Text(
              "Utilize uma das opções acima para popular sua mesa de ambientação.",
            ),
          ),
        ],
      ),
    );
  }
}
