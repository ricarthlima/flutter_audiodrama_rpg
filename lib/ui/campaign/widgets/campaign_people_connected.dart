import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../../../data/services/chat_service.dart';
import '../../../domain/models/app_user.dart';

class CampaignPeopleConnected extends StatefulWidget {
  const CampaignPeopleConnected({super.key});

  @override
  State<CampaignPeopleConnected> createState() =>
      _CampaignPeopleConnectedState();
}

class _CampaignPeopleConnectedState extends State<CampaignPeopleConnected> {
  bool isHide = false;

  @override
  Widget build(BuildContext context) {
    if (isHide) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isHide = false;
          });
        },
        child: Opacity(
          opacity: 0.05,
          child: Icon(Icons.visibility_off, size: 16),
        ),
      );
    }
    final campaignVM = context.watch<CampaignProvider>();
    final userProvider = context.watch<UserProvider>();

    return StreamBuilder(
      stream: ChatService.instance.listenUserPresences(
        campaignId: campaignVM.campaign!.id,
      ),
      builder: (context, snapshot) {
        // int count = 1;

        // if (snapshot.data != null) {
        //   count = snapshot.data!.snapshot.children.length;
        // }
        List<AppUser> listUsers = [];

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

        return GestureDetector(
          onTap: () {
            setState(() {
              isHide = true;
            });
          },
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: listUsers.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: (e.imageB64 != null)
                          ? Image.memory(base64Decode(e.imageB64!))
                          : Icon(Icons.person, size: 18),
                    ),
                    Text(
                      e.username ?? e.id ?? "sem nome",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
