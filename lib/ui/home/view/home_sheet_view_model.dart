import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/campaign.dart';
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

    Campaign? campaign = userProvider.getCampaignBySheet(sheet.id);

    if (campaign != null) {
      return campaign.name!;
    }

    return "Sem mundo";
  }
}
