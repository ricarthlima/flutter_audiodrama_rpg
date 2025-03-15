import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../_core/release_mode.dart';
import '../../../data/services/campaign_service.dart';
import '../../../domain/models/campaign.dart';
import '../../../domain/models/campaign_sheet.dart';
import '../../../domain/models/sheet_model.dart';

class HomeSheetViewModel extends ChangeNotifier {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  StreamSubscription? streamSubscription;

  List<Sheet> listSheets = [];

  List<Campaign> listCampaigns = [];
  List<CampaignSheet> listCampaignsSheet = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  onInitialize() async {
    isLoading = true;
    streamSubscription = FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        listSheets = snapshot.docs.map((e) => Sheet.fromMap(e.data())).toList();
        notifyListeners();
      },
    );

    listCampaigns = await CampaignService.instance.getAllCampaigns();
    listCampaignsSheet = await CampaignService.instance.getListCampaignSheet();

    CampaignService.instance.getCampaignSheetStream().listen(
      (snapshot) {
        listCampaignsSheet = [];
        for (var doc in snapshot.docs) {
          listCampaignsSheet.add(CampaignSheet.fromMap(doc.data()));
        }
      },
    );
    isLoading = false;
  }

  String getWorldName(Sheet sheet) {
    List<CampaignSheet> listCS =
        listCampaignsSheet.where((e) => e.sheetId == sheet.id).toList();

    if (listCS.isEmpty) {
      return "Sem mundo";
    } else {
      List<Campaign> listC =
          listCampaigns.where((e) => e.id == listCS.first.campaignId).toList();

      if (listC.isEmpty) {
        return "Sem mundo";
      } else {
        return listC.first.name ?? "Sem mundo";
      }
    }
  }
}
