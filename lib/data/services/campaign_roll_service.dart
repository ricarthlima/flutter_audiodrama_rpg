import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/campaign_roll.dart';

class CampaignRollService {
  CampaignRollService._();
  static final CampaignRollService _instance = CampaignRollService._();
  static CampaignRollService get instance => _instance;

  Future<void> registerRoll({required CampaignRoll campaignRoll}) async {
    return FirebaseFirestore.instance
        .collection("campaigns")
        .doc(campaignRoll.campaignId)
        .collection("rolls")
        .doc(campaignRoll.id)
        .set(campaignRoll.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listen({
    required String campaignId,
  }) {
    return FirebaseFirestore.instance
        .collection("campaigns")
        .doc(campaignId)
        .collection("rolls")
        .snapshots();
  }
}
