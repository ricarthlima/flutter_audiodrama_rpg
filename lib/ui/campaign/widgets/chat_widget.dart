import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/services/chat_service.dart';
import '../view/campaign_view_model.dart';

class CampaignChatWidget extends StatefulWidget {
  const CampaignChatWidget({super.key});

  @override
  State<CampaignChatWidget> createState() => _CampaignChatWidgetState();
}

class _CampaignChatWidgetState extends State<CampaignChatWidget> {
  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          StreamBuilder(
            stream: ChatService.instance.listenUserPresences(
              campaignId: campaignVM.campaign!.id,
            ),
            builder: (context, snapshot) {
              int count = 1;
              List<AppUser> listUsers = [];

              if (snapshot.data != null) {
                count = snapshot.data!.snapshot.children.length;
              }

              if (snapshot.data != null) {
                for (DataSnapshot data in snapshot.data!.snapshot.children) {
                  String userId = data.key ?? "";

                  if (userId == FirebaseAuth.instance.currentUser!.uid) {
                    listUsers.add(userProvider.currentAppUser);
                  } else if (userId != "") {
                    listUsers.add(
                      campaignVM.listSheetAppUser
                          .where((e) => e.appUser.id! == userId)
                          .first
                          .appUser,
                    );
                  }
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Text(
                    "Pessoas conectadas ($count)",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.bungee,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      child: Column(
                        children: listUsers
                            .map(
                              (e) => ListTile(
                                leading: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: (e.imageB64 != null)
                                      ? Image.memory(base64Decode(e.imageB64!))
                                      : Icon(
                                          Icons.person,
                                          size: 18,
                                        ),
                                ),
                                title: Text(e.username ?? e.id ?? "sem nome"),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Divider(thickness: 0.1),
                ],
              );
            },
          ),
          Text(
            "Chat",
            style: TextStyle(
              fontSize: 14,
              fontFamily: FontFamily.bungee,
            ),
          ),
        ],
      ),
    );
  }
}
