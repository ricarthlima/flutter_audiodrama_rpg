import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';

class CampaignViewModel extends ChangeNotifier {
  Campaign? campaign;
  String? campaignId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;
  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  int notificationCount = 0;
  TextEditingController nameController = TextEditingController();

  onInitialize() async {
    if (campaignId != null) {
      isLoading = true;
      campaign = await CampaignService.instance.getCampaignById(campaignId!);
      if (campaign != null) {
        nameController.text = campaign!.name ?? "";
      }
      isLoading = false;
    }
  }

  onSave() async {
    if (campaign != null) {
      campaign!.name = nameController.text;
      CampaignService.instance.saveCampaign(campaign!);
    }
  }

  bool get isOwner {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (campaign != null && campaign!.listIdOwners.contains(uid)) {
      return true;
    }
    return false;
  }

  bool get isOwnerOrInvited {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (campaign != null && (campaign!.listIdOwners.contains(uid)) ||
        campaign!.listIdPlayers.contains(uid)) {
      return true;
    }
    return false;
  }
}
