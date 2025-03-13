import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignViewModel =
        Provider.of<CampaignViewModel>(context);

    if (campaignViewModel.campaign != null) {
      return Placeholder();
    }

    return Center(
      child: Text("Campanha não encontrada.\n ${campaignViewModel.campaignId}"),
    );
  }
}
