import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_service.dart';
import 'package:flutter_rpg_audiodrama/router.dart';

import '../../../domain/models/campaign.dart';

class HomeCampaignViewModel extends ChangeNotifier {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  CampaignService campaignService = CampaignService.instance;

  Future<void> createCampaign({
    required BuildContext context,
    required String name,
    required String description,
    Uint8List? fileImage,
  }) async {
    Campaign campaign = await campaignService.createCampaign(
      name: name,
      description: description,
      fileImage: fileImage,
    );

    if (!context.mounted) return;
    AppRouter().goCampaign(context: context, campaignId: campaign.id);
  }

  Future<void> joinCampaign({required String joinCode}) async {
    return campaignService.joinCampaign(joinCode);
  }
}
