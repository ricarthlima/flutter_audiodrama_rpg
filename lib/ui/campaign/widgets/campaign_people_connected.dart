import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../../data/services/chat_service.dart';
import '../../../domain/models/app_user.dart';
import '../view/campaign_view_model.dart';

class CampaignPeopleConnected extends StatefulWidget {
  const CampaignPeopleConnected({super.key});

  @override
  State<CampaignPeopleConnected> createState() =>
      _CampaignPeopleConnectedState();
}

class _CampaignPeopleConnectedState extends State<CampaignPeopleConnected> {
  bool isHide = false;

  String? campaignId;
  Stream<DatabaseEvent>? stream;

  @override
  void didUpdateWidget(covariant CampaignPeopleConnected oldWidget) {
    if (campaignId != context.read<UserProvider>().lastCampaignId) {
      super.didUpdateWidget(oldWidget);
    }
  }

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
    final userProvider = context.watch<UserProvider>();

    if (userProvider.lastCampaignId != campaignId) {
      campaignId = userProvider.lastCampaignId;
      stream = ChatService.instance.listenUserPresences(
        campaignId: campaignId!,
      );
    }

    if (campaignId == null || stream == null) return SizedBox();

    return StreamBuilder(
      key: ValueKey<String>(campaignId ?? ""),
      stream: stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          case ConnectionState.active:
            // int count = j1;

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
                  final CampaignProvider campaign = context
                      .read<CampaignProvider>();

                  // Indize por id para lookup O(1) e evitar .first em vazio
                  final Map<String, AppUser> usersById = {
                    for (final e in campaign.listSheetAppUser)
                      if (e.appUser.id != null) e.appUser.id!: e.appUser,
                  };

                  if (userId.isNotEmpty) {
                    final AppUser? found = usersById[userId];
                    if (found != null) {
                      listUsers.add(found);
                    }
                  }
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
          case ConnectionState.done:
            return SizedBox();
        }
      },
    );
  }
}
