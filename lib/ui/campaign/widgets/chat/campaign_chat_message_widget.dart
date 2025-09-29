import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../../_core/providers/user_provider.dart';
import '../../view/campaign_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/services/chat_service.dart';
import '../../../../domain/models/campaign_chat.dart';
import '../../../_core/app_colors.dart';

class CampaignChatMessageWidget extends StatelessWidget {
  final CampaignChatMessage chatMessage;
  final String? nextMessageUserId;

  const CampaignChatMessageWidget({
    super.key,
    required this.chatMessage,
    this.nextMessageUserId,
  });

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    final userProvider = context.watch<UserProvider>();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(10),
      ),
      margin: (nextMessageUserId != chatMessage.userId)
          ? EdgeInsets.only(bottom: 8)
          : null,
      padding: EdgeInsets.all(4),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                MarkdownBody(selectable: true, data: chatMessage.message),
                if (nextMessageUserId != chatMessage.userId)
                  Opacity(
                    opacity: 0.5,
                    child: Text(
                      "${(chatMessage.userId == uid) ? (userProvider.currentAppUser.username ?? "") : campaignVM.listSheetAppUser.where((x) => x.appUser.id! == chatMessage.userId).first.appUser.username ?? ""} | ${DateFormat('dd/MM/yyyy - HH:mm', 'pt_BR').format(chatMessage.createdAt)}",
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
              ],
            ),
          ),
          if (campaignVM.isOwner)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Tooltip(
                  message: "Remover",
                  child: InkWell(
                    onTap: () {
                      ChatService.instance.deleteMessage(
                        campaignId: campaignVM.campaign!.id,
                        messageId: chatMessage.id,
                      );
                    },
                    child: Icon(Icons.delete, size: 10, color: AppColors.red),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
