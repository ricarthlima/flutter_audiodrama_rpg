import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';

class HomeListCampaignWidget extends StatelessWidget {
  final Campaign campaign;
  const HomeListCampaignWidget({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(campaign.name!),
    );
  }
}
