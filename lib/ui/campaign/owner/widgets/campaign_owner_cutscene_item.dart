import 'package:flutter/material.dart';

import '../../../_core/components/wip_snackbar.dart';

class CampaignOwnerCutsceneItem extends StatelessWidget {
  final String title;
  const CampaignOwnerCutsceneItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(height: 64, width: 64, child: Placeholder()),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                showSnackBarWip(context);
              },
              icon: Icon(Icons.play_arrow),
            ),
            IconButton(
              onPressed: () {
                showSnackBarWip(context);
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
