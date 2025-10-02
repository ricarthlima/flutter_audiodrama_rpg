import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/dimensions.dart';
import '../../view/campaign_visual_novel_view_model.dart';

class CampaignGuestNovel extends StatelessWidget {
  const CampaignGuestNovel({super.key});

  @override
  Widget build(BuildContext context) {
    final visualVM = context.watch<CampaignVisualNovelViewModel>();

    return InteractiveViewer(
      transformationController:
          (!visualVM.data.allowPan && !visualVM.data.allowZoom)
          ? TransformationController(Matrix4.identity())
          : null,
      panEnabled: visualVM.data.allowPan,
      scaleEnabled: visualVM.data.allowZoom,
      maxScale: 10,
      child: AnimatedSwitcher(
        duration: Duration(
          milliseconds:
              visualVM.data.transitionBackgroundDurationInMilliseconds,
        ),
        child: (visualVM.data.backgroundActive == null)
            ? Container(key: ValueKey('empty'), color: Colors.black)
            : Image.network(
                visualVM.data.backgroundActive!.url,
                key: ValueKey(visualVM.data.backgroundActive!.url),
                fit: BoxFit.fitWidth,
                width: width(context),
                height: height(context),
              ),
      ),
    );
  }
}
