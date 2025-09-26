import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/campaign_chat.dart';
import '../../_core/fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/services/chat_service.dart';
import '../view/campaign_view_model.dart';
import '../widgets/chat/campaign_chat_message_widget.dart';

class CampaignChatSection extends StatefulWidget {
  const CampaignChatSection({super.key});

  @override
  State<CampaignChatSection> createState() => _CampaignChatSectionState();
}

class _CampaignChatSectionState extends State<CampaignChatSection> {
  List<SheetAppUser> listSheetAppUser = [];
  String? whisperId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignVM = context.read<CampaignProvider>();
      listSheetAppUser = List<SheetAppUser>.from(campaignVM.listSheetAppUser);
      listSheetAppUser.removeWhere(
        (e) => campaignVM.campaign!.listIdOwners.contains(e.appUser.id),
      );

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);

    final FocusNode focusNode = FocusNode();

    TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    GlobalKey lastItemKey = GlobalKey();

    sendMessage() {
      String value = messageController.text;

      if (whisperId == "") {
        whisperId = null;
      }

      if (value.isEmpty) return;
      ChatService.instance.sendMessageToChat(
        campaignId: campaignVM.campaign!.id,
        message: value,
        whisperId: whisperId,
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

    if (campaignVM.campaign == null) return SizedBox();

    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(
          "Chat",
          style: TextStyle(fontSize: 14, fontFamily: FontFamily.bungee),
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
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    itemCount: listMessages.length,
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      CampaignChatMessage chatMessage = listMessages[index];
                      String? nextUserId =
                          (index < listMessages.length - 1 &&
                              chatMessage.createdAt
                                      .difference(
                                        listMessages[index + 1].createdAt,
                                      )
                                      .abs() <
                                  Duration(minutes: 2) &&
                              chatMessage.type == CampaignChatType.message &&
                              listMessages[index + 1].type ==
                                  CampaignChatType.message &&
                              chatMessage.whisperId ==
                                  listMessages[index + 1].whisperId)
                          ? listMessages[index + 1].userId
                          : null;
                      Widget result = SizedBox();
                      switch (chatMessage.type) {
                        case CampaignChatType.message:
                          result = CampaignChatMessageWidget(
                            key: index == listMessages.length - 1
                                ? lastItemKey
                                : null,
                            chatMessage: chatMessage,
                            nextMessageUserId: nextUserId,
                          );
                        case CampaignChatType.roll:
                          // TODO: Handle this case.
                          throw UnimplementedError();
                        case CampaignChatType.spell:
                          // TODO: Handle this case.
                          throw UnimplementedError();
                      }
                      return Padding(
                        padding: EdgeInsetsGeometry.only(right: 16),
                        child: Visibility(
                          visible:
                              (chatMessage.userId == uid) ||
                              (chatMessage.whisperId == null) ||
                              (chatMessage.whisperId! == uid) ||
                              (chatMessage.whisperId == "OWNERS" &&
                                  campaignVM.isOwner),
                          child: result,
                        ),
                      );
                    },
                  ),
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
          alignment: Alignment.bottomCenter,
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
                Container(
                  padding: EdgeInsets.all(4),
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withAlpha(30),
                  child: TextFormField(
                    controller: messageController,
                    autocorrect: true,
                    onFieldSubmitted: (value) {
                      sendMessage();
                    },
                    style: TextStyle(fontSize: 12),
                    maxLength: 2000,
                    maxLines: 5,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu(
                        enableFilter: false,
                        enableSearch: false,
                        requestFocusOnTap: false,
                        expandedInsets: EdgeInsets.zero,
                        label: Text("Sussurrar para"),
                        menuStyle: MenuStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        ),
                        dropdownMenuEntries:
                            [
                              DropdownMenuEntry<String>(
                                value: '',
                                label: '(Todo mundo)',
                              ),
                              DropdownMenuEntry<String>(
                                value: 'OWNERS',
                                label: '(Pessoas narradoras)',
                              ),
                            ] +
                            listSheetAppUser
                                .map(
                                  (e) => DropdownMenuEntry<String>(
                                    value: e.appUser.id ?? '',
                                    label: e.sheet.characterName,
                                  ),
                                )
                                .toList(),
                        onSelected: (value) {
                          setState(() {
                            whisperId = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
