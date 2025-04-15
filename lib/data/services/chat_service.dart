import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class ChatService {
  ChatService._();
  static final ChatService _instance = ChatService._();
  static ChatService get instance => _instance;

  Future<void> addUserToCampaign(
      {required String userId, required String campaignId}) async {
    await FirebaseDatabase.instance.goOnline();

    final db = FirebaseDatabase.instance;
    final userRef = db.ref("campaigns/$campaignId/users/$userId");

    await userRef.set({
      'online': true,
      'timestamp': ServerValue.timestamp,
    });

    await userRef.onDisconnect().remove();
  }

  Stream<DatabaseEvent> listenUserPresences({required String campaignId}) {
    final db = FirebaseDatabase.instance;
    return db.ref("campaigns/$campaignId/users").onValue;
  }

  disconnect() {
    FirebaseDatabase.instance.goOffline();
  }
}
