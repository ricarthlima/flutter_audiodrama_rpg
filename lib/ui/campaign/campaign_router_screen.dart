import 'package:flutter/material.dart';
import 'campaign_owner_sub_screen.dart';
import 'campaign_guest_screen.dart';
import 'view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../../_core/providers/user_provider.dart';

class CampaignRouterScreen extends StatefulWidget {
  const CampaignRouterScreen({super.key});

  @override
  State<CampaignRouterScreen> createState() => _CampaignRouterScreenState();
}

class _CampaignRouterScreenState extends State<CampaignRouterScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignProvider campaignVM = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).playCampaignAudios(campaignVM.campaign!);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);

    if (campaignVM.isOwner) {
      return CampaignOwnerSubScreen();
    }

    return CampaignGuestScreen();
  }
}
