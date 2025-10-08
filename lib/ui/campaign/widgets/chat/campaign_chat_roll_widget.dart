import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/roll_log.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/roll_log_widget.dart';

import '../../../../domain/models/campaign_chat.dart';

class CampaignChatRollWidget extends StatelessWidget {
  final CampaignChatMessage chatMessage;

  const CampaignChatRollWidget({super.key, required this.chatMessage});

  @override
  Widget build(BuildContext context) {
    return RollLogWidget(rollLog: RollLog.fromJson(chatMessage.message));
  }
}
