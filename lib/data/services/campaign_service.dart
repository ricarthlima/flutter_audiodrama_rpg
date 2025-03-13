import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rpg_audiodrama/_core/helpers/generate_access_key.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../_core/utils/supabase_prefs.dart';

class CampaignService {
  CampaignService._();
  static final CampaignService _instance = CampaignService._();
  static CampaignService get instance => _instance;

  final _supabase = Supabase.instance.client;

  Future<Campaign> createCampaign({
    required String name,
    required String description,
    DateTime? nextSession,
    Uint8List? fileImage,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String? imageBannerUrl;

    // TODO: Estou ignorando colisão
    String enterCode = generateAccessKey();

    Campaign newCampaign = Campaign(
      id: Uuid().v4(),
      listIdOwners: [uid],
      listIdPlayers: [],
      enterCode: enterCode,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      name: name,
      description: description,
      imageBannerUrl: imageBannerUrl,
      nextSession: nextSession,
    );

    if (fileImage != null) {
      imageBannerUrl = await uploadImage(fileImage, newCampaign.id);
    }

    await FirebaseFirestore.instance
        .collection("campaigns")
        .doc(newCampaign.id)
        .set(newCampaign.toMap());

    return newCampaign;
  }

  // Apenas o próprio usuário
  Future<String> uploadImage(Uint8List file, String fileName) async {
    String bucket = SupabasePrefs.storageBucketSheet;
    String filePath = "campaigns/$fileName";

    await _supabase.storage.from(bucket).uploadBinary(
          filePath,
          file,
          fileOptions: FileOptions(upsert: true),
        );

    final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

    return publicUrl;
  }

  // Apenas o próprio usuário
  Future<void> removeImage(String fileName) {
    return _supabase.storage
        .from(SupabasePrefs.storageBucketSheet)
        .remove(["bios/$fileName"]);
  }
}
