import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/ui/home_campaign/widgets/campaign_widget.dart';
import 'package:provider/provider.dart';

import '../_core/widgets/generic_header.dart';
import 'components/create_campaign_dialog.dart';
import 'view/home_campaign_view_model.dart';

class HomeCampaignScreen extends StatelessWidget {
  const HomeCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HomeCampaignViewModel homeCampaignVM =
        Provider.of<HomeCampaignViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          GenericHeader(
            title: "Minhas Campanhas",
            iconButton: IconButton(
              onPressed: () {
                showCreateCampaignDialog(context: context);
              },
              tooltip: "Criar campanha",
              icon: Icon(Icons.add),
            ),
          ),
          if (homeCampaignVM.listCampaigns.isEmpty)
            Center(
              child: Text(
                "Nada por aqui ainda, vamos criar?",
                style: TextStyle(fontSize: 24),
              ),
            ),
          if (homeCampaignVM.listCampaigns.isNotEmpty)
            Wrap(
              spacing: 16,
              children: List.generate(
                homeCampaignVM.listCampaigns.length,
                (index) {
                  Campaign campaign = homeCampaignVM.listCampaigns[index];
                  return CampaignWidget(campaign: campaign);
                },
              ),
            ),
        ],
      ),
    );
  }
}
