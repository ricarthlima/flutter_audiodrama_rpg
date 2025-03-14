import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_service.dart';
import 'package:flutter_rpg_audiodrama/domain/exceptions/general_exceptions.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/models/campaign.dart';

class HomeCampaignViewModel extends ChangeNotifier {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  CampaignService campaignService = CampaignService.instance;

  StreamSubscription? streamSubscription;
  StreamSubscription? streamSubscriptionInvited;

  List<Campaign> listCampaigns = [];
  List<Campaign> listCampaignsInvited = [];

  onInitialize() {
    streamSubscription = FirebaseFirestore.instance
        .collection("campaigns")
        .where("listIdOwners", arrayContains: uid)
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        listCampaigns = snapshot.docs
            .map(
              (e) => Campaign.fromMap(e.data()),
            )
            .toList();
        notifyListeners();
      },
    );

    streamSubscriptionInvited = FirebaseFirestore.instance
        .collection("campaigns")
        .where("listIdPlayers", arrayContains: uid)
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        listCampaignsInvited = snapshot.docs
            .map(
              (e) => Campaign.fromMap(e.data()),
            )
            .toList();
        notifyListeners();
      },
    );
  }

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

  Future<Uint8List?> onLoadImageClicked(BuildContext context) async {
    ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );

    if (image != null) {
      int sizeInBytes = await image.length();

      if (sizeInBytes >= 2000000) {
        throw ImageTooLargeException();
      } else {
        return await image.readAsBytes();
      }
    }

    return null;
  }

  Future<void> joinCampaign({required String joinCode}) async {
    return campaignService.joinCampaign(joinCode);
  }
}
