import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/roll_log.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/roll_log_widget.dart';
import 'package:provider/provider.dart';

import '../../../../data/services/chat_service.dart';
import '../../../../domain/models/campaign_chat.dart';
import '../../../_core/app_colors.dart';
import '../../view/campaign_view_model.dart';

class CampaignChatRollWidget extends StatelessWidget {
  final CampaignChatMessage chatMessage;

  const CampaignChatRollWidget({super.key, required this.chatMessage});

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    return Stack(
      children: [
        RollLogWidget(rollLog: RollLog.fromJson(chatMessage.message)),
        if (campaignVM.isOwner)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 8,
                vertical: 16,
              ),
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
    );
  }
}
