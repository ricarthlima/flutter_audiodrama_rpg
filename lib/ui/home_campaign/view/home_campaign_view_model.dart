import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../data/services/campaign_service.dart';
import '../../../domain/models/campaign.dart';
import '../../../router.dart';

abstract class HomeCampaignInteract {
  static Future<void> createCampaign({
    required BuildContext context,
    required String name,
    required String description,
    Uint8List? imageBytes,
  }) async {
    Campaign campaign = await CampaignService.instance.createCampaign(
      name: name,
      description: description,
      fileImage: imageBytes,
    );

    if (!context.mounted) return;
    AppRouter().goCampaign(context: context, campaignId: campaign.id);
  }

  static Future<void> joinCampaign({required String joinCode}) async {
    return CampaignService.instance.joinCampaign(joinCode);
  }
}
