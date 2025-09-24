import 'package:flutter/material.dart';
import '../../../domain/models/campaign_achievement.dart';
import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
import 'package:provider/provider.dart';

import '../view/campaign_view_model.dart';

class GroupNotifications extends StatelessWidget {
  const GroupNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: campaignVM.listNewAchievements
              .map((e) => NotificationAchievementWidget(achievement: e))
              .toList(),
        ),
      ),
    );
  }
}

class NotificationAchievementWidget extends StatelessWidget {
  final CampaignAchievement achievement;
  const NotificationAchievementWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    return Container(
      width: 300,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: AppColors.red),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CONQUISTA DESBLOQUEADA",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                InkWell(
                  onTap: () {
                    campaignVM.hasAchievementShowed(achievement);
                  },
                  child: Icon(Icons.close, size: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                if (achievement.imageUrl != null)
                  Image.network(achievement.imageUrl!, width: 64),
                if (achievement.imageUrl == null)
                  Icon(Icons.star_border, size: 64),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        achievement.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: FontFamily.bungee),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        achievement.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
