import 'package:flutter/material.dart';

import '../widgets/campaign_battlemap_grid_viewer.dart';

class CampaignGridGuest extends StatelessWidget {
  const CampaignGridGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return CampaignBattleMapGridViewer(isOwner: false);
  }
}
