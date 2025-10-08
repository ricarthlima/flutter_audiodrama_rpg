import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/chat/campaign_chat_roll_widget.dart';
import 'package:provider/provider.dart';

import '../../../data/services/chat_service.dart';
import '../../../domain/models/campaign_chat.dart';
import '../../_core/widgets/generic_header.dart';
import '../view/campaign_view_model.dart';
import '../widgets/chat/campaign_chat_message_widget.dart';

class CampaignDrawerChat extends StatefulWidget {
  const CampaignDrawerChat({super.key});

  @override
  State<CampaignDrawerChat> createState() => _CampaignDrawerChatState();
}

class _CampaignDrawerChatState extends State<CampaignDrawerChat> {
  late final FocusNode _focusNode;
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;

  String? whisperId;
  bool _isAutoScrolling = false;
  bool _didInitialJump = false;
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final CampaignProvider cp = context.watch<CampaignProvider>();
    if (whisperId != null &&
        whisperId!.isNotEmpty &&
        !cp.listSheetAppUser.any((e) => e.appUser.id == whisperId)) {
      setState(() => whisperId = null);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(CampaignProvider campaignVM) {
    String value = _messageController.text;
    if (value.isEmpty) return;
    String? to = (whisperId == "") ? null : whisperId;
    ChatService.instance.sendMessageToChat(
      campaignId: campaignVM.campaign!.id,
      message: value,
      whisperId: to,
    );
    _messageController.clear();
  }

  Future<void> _scrollToEnd({required bool immediate}) async {
    if (!_scrollController.hasClients) return;
    final double target = _scrollController.position.maxScrollExtent;
    if (immediate) {
      try {
        _scrollController.jumpTo(target);
      } catch (_) {}
      return;
    }
    if (_isAutoScrolling) return;
    _isAutoScrolling = true;
    try {
      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 140),
        curve: Curves.linear,
      );
    } catch (_) {
    } finally {
      _isAutoScrolling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = context.watch<CampaignProvider>();
    if (campaignVM.campaign == null) return const SizedBox();

    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GenericHeader(title: "Chat"),
        Expanded(
          child: StreamBuilder(
            stream: ChatService.instance.listenChat(
              campaignId: campaignVM.campaign!.id,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              List<CampaignChatMessage> listMessages =
                  snapshot.data!.docs
                      .map((e) => CampaignChatMessage.fromMap(e.data()))
                      .toList()
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

              int count = listMessages.length;

              if (!_didInitialJump && count > 0) {
                _didInitialJump = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _scrollToEnd(immediate: true);
                });
              }

              if (count > _lastItemCount) {
                _lastItemCount = count;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _scrollToEnd(immediate: false);
                });
              }

              Widget list = ListView.builder(
                controller: _scrollController,
                itemCount: listMessages.length,
                itemBuilder: (context, index) {
                  CampaignChatMessage chatMessage = listMessages[index];

                  String? nextUserId;
                  if (index + 1 < listMessages.length) {
                    CampaignChatMessage next = listMessages[index + 1];
                    bool isCluster =
                        (chatMessage.type == CampaignChatType.message) &&
                        (next.type == CampaignChatType.message) &&
                        (chatMessage.whisperId == next.whisperId) &&
                        (chatMessage.createdAt
                                .difference(next.createdAt)
                                .abs() <
                            const Duration(minutes: 2));
                    nextUserId = isCluster ? next.userId : null;
                  }

                  Widget child;
                  switch (chatMessage.type) {
                    case CampaignChatType.message:
                      child = CampaignChatMessageWidget(
                        chatMessage: chatMessage,
                        nextMessageUserId: nextUserId,
                      );
                      break;
                    case CampaignChatType.roll:
                      child = CampaignChatRollWidget(chatMessage: chatMessage);
                      break;
                    case CampaignChatType.spell:
                      child = const SizedBox.shrink();
                      break;
                  }

                  bool visible =
                      (chatMessage.userId == uid) ||
                      (chatMessage.whisperId == null) ||
                      (chatMessage.whisperId == uid) ||
                      (chatMessage.whisperId == "OWNERS" && campaignVM.isOwner);

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Visibility(visible: visible, child: child),
                  );
                },
              );

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: list,
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter &&
                  !HardwareKeyboard.instance.isShiftPressed) {
                _sendMessage(campaignVM);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withAlpha(30),
                  child: TextFormField(
                    controller: _messageController,
                    autocorrect: true,
                    onFieldSubmitted: (_) => _sendMessage(campaignVM),
                    style: const TextStyle(fontSize: 12),
                    maxLength: 2000,
                    maxLines: 5,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu<String>(
                        enableFilter: false,
                        enableSearch: false,
                        requestFocusOnTap: false,
                        expandedInsets: EdgeInsets.zero,
                        label: const Text("Sussurrar para"),
                        menuStyle: const MenuStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        ),
                        dropdownMenuEntries: [
                          const DropdownMenuEntry<String>(
                            value: '',
                            label: '(Todo mundo)',
                          ),
                          const DropdownMenuEntry<String>(
                            value: 'OWNERS',
                            label: '(Pessoas narradoras)',
                          ),
                          ...campaignVM.listSheetAppUser.map(
                            (e) => DropdownMenuEntry<String>(
                              value: e.appUser.id ?? '',
                              label: e.sheet.characterName,
                            ),
                          ),
                        ],
                        onSelected: (String? value) {
                          setState(() {
                            whisperId = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () => _sendMessage(campaignVM),
                      icon: const Icon(Icons.send),
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
