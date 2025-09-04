import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../domain/models/campaign_chat.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  ChatService._();
  static final ChatService _instance = ChatService._();
  static ChatService get instance => _instance;

  Future<void> addUserToCampaign({
    required String userId,
    required String campaignId,
  }) async {
    await FirebaseDatabase.instance.goOnline();

    final db = FirebaseDatabase.instance;
    final userRef = db.ref("campaigns/$campaignId/users/$userId");

    await userRef.set({'online': true, 'timestamp': ServerValue.timestamp});

    await userRef.onDisconnect().remove();
  }

  Stream<DatabaseEvent> listenUserPresences({required String campaignId}) {
    final db = FirebaseDatabase.instance;
    return db.ref("campaigns/$campaignId/users").onValue;
  }

  void disconnect() {
    FirebaseDatabase.instance.goOffline();
  }

  Future<void> sendMessageToChat({
    required String campaignId,
    required String message,
  }) async {
    CampaignChatMessage chatMessage = CampaignChatMessage(
      id: Uuid().v8(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      message: message,
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection("campaigns")
        .doc(campaignId)
        .collection("chat")
        .doc(chatMessage.id)
        .set(chatMessage.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenChat({
    required String campaignId,
  }) {
    return FirebaseFirestore.instance
        .collection("campaigns")
        .doc(campaignId)
        .collection("chat")
        .snapshots();
  }

  Future<void> deleteMessage({
    required String campaignId,
    required String messageId,
  }) async {
    return FirebaseFirestore.instance
        .collection("campaigns")
        .doc(campaignId)
        .collection("chat")
        .doc(messageId)
        .delete();
  }
}
