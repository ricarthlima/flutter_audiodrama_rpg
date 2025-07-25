import 'package:flutter/material.dart';
import '../../domain/models/campaign.dart';
import '../../_core/providers/user_provider.dart';
import 'components/join_campaign_dialog.dart';
import 'widgets/campaign_widget.dart';
import 'package:provider/provider.dart';

import '../_core/widgets/generic_header.dart';
import 'components/create_campaign_dialog.dart';

class HomeCampaignScreen extends StatelessWidget {
  const HomeCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (userProvider.listCampaigns.isEmpty)
                    Expanded(
                      child: Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            "Nada por aqui ainda, vamos criar?",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (userProvider.listCampaigns.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 16,
                        children: List.generate(
                          userProvider.listCampaigns.length,
                          (index) {
                            Campaign campaign =
                                userProvider.listCampaigns[index];
                            return CampaignWidget(campaign: campaign);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenericHeader(
                    title: "Outras campanhas",
                    iconButton: IconButton(
                      onPressed: () => showJoinCampaignDialog(context: context),
                      tooltip: "Juntar-se a campanha",
                      icon: Icon(Icons.login),
                    ),
                  ),
                  if (userProvider.listCampaignsInvited.isEmpty)
                    Expanded(
                      child: Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            "Seria bom pessoas pra te chamar, né?",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (userProvider.listCampaignsInvited.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 16,
                        children: List.generate(
                          userProvider.listCampaignsInvited.length,
                          (index) {
                            Campaign campaign =
                                userProvider.listCampaignsInvited[index];
                            return CampaignWidget(campaign: campaign);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
