import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/campaign.dart';
import '../../../domain/models/campaign_sheet.dart';
import '../../../domain/models/sheet_model.dart';

class HomeSheetViewModel extends ChangeNotifier {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String getWorldName({
    required BuildContext context,
    required Sheet sheet,
  }) {
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<CampaignSheet> listCS = userProvider.listCampaignsSheet
        .where((e) => e.sheetId == sheet.id)
        .toList();

    if (listCS.isEmpty) {
      return "Sem mundo";
    } else {
      List<Campaign> listC = userProvider.listCampaigns
          .where((e) => e.id == listCS.first.campaignId)
          .toList();

      if (listC.isEmpty) {
        return "Sem mundo";
      } else {
        return listC.first.name ?? "Sem mundo";
      }
    }
  }
}
