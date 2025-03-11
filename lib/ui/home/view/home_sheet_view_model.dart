import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../_core/release_mode.dart';
import '../../../domain/models/sheet_model.dart';

class HomeSheetViewModel extends ChangeNotifier {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  StreamSubscription? streamSubscription;

  List<Sheet> listSheets = [];

  onInitialize() {
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
  }
}
