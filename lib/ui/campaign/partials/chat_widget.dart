import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../_core/providers/user_provider.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/campaign_chat.dart';
import '../../_core/fonts.dart';
import 'package:intl/intl.dart';
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
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    final FocusNode focusNode = FocusNode();

    TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    GlobalKey lastItemKey = GlobalKey();

    sendMessage() {
      String value = messageController.text;
      if (value.isEmpty) return;
      ChatService.instance.sendMessageToChat(
        campaignId: campaignVM.campaign!.id,
        message: value,
      );
      setState(() {
        messageController.text = "";
      });
    }

    void scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients &&
            scrollController.position.hasContentDimensions) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        ? Image.memory(
                                            base64Decode(e.imageB64!),
                                          )
                                        : Icon(Icons.person, size: 18),
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
              style: TextStyle(fontSize: 14, fontFamily: FontFamily.bungee),
            ),
          ],
        ),
        StreamBuilder(
          stream: ChatService.instance.listenChat(
            campaignId: campaignVM.campaign!.id,
          ),
          builder: (context, snapshot) {
            List<CampaignChatMessage> listMessages = [];

            if (snapshot.hasData) {
              listMessages = snapshot.data!.docs
                  .map((e) => CampaignChatMessage.fromMap(e.data()))
                  .toList();

              listMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              Widget result = Expanded(
                child: ListView.builder(
                  itemCount: listMessages.length,
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    CampaignChatMessage chatMessage = listMessages[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color!.withAlpha(10),
                      ),
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 4,
                        children: [
                          ListTile(
                            key: index == listMessages.length - 1
                                ? lastItemKey
                                : null,
                            title: MarkdownBody(data: chatMessage.message),
                            subtitle: (Text(
                              "${(chatMessage.userId == FirebaseAuth.instance.currentUser!.uid) ? (userProvider.currentAppUser.username ?? "") : campaignVM.listSheetAppUser.where((x) => x.appUser.id! == chatMessage.userId).first.appUser.username ?? ""} | ${DateFormat('dd/MM/yyyy - HH:mm', 'pt_BR').format(chatMessage.createdAt)}",
                              style: TextStyle(fontSize: 8),
                            )),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: chatMessage.message),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Copiado para a área de transferência',
                                    ),
                                  ),
                                );
                              }
                            },
                            label: Text("Copiar"),
                            icon: Icon(Icons.copy),
                          ),
                          if (campaignVM.isOwner)
                            ElevatedButton.icon(
                              onPressed: () {
                                ChatService.instance.deleteMessage(
                                  campaignId: campaignVM.campaign!.id,
                                  messageId: chatMessage.id,
                                );
                              },

                              label: Text("Remover"),
                              icon: Icon(Icons.delete),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
              scrollToBottom();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (lastItemKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    lastItemKey.currentContext!,
                    duration: Duration(milliseconds: 100),
                  );
                }
              });

              return result;
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(15),
          ),
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(8),
            child: KeyboardListener(
              focusNode: focusNode,
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    !HardwareKeyboard.instance.isShiftPressed) {
                  sendMessage();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  TextFormField(
                    controller: messageController,
                    autocorrect: true,
                    onFieldSubmitted: (value) {
                      sendMessage();
                    },
                    style: TextStyle(fontSize: 12),
                    maxLines: null,
                    maxLength: 2000,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      sendMessage();
                    },
                    child: Text("Enviar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
