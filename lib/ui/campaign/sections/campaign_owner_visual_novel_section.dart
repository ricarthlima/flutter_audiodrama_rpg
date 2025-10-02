import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_scenes.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/campaign_visual.dart';
import '../../_core/dimensions.dart';
import '../view/campaign_visual_novel_view_model.dart';
import '../widgets/visual_novel/character_area_widget.dart';

import '../guest/campaign_guest_screen.dart';
import '../widgets/visual_novel/image_area_widget.dart';

class CampaignOwnerVisualNovelSection extends StatelessWidget {
  const CampaignOwnerVisualNovelSection({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignVM = context.watch<CampaignProvider>();
    final visualVM = context.watch<CampaignVisualNovelViewModel>();

    void onTapBackground(CampaignVisual object) {
      visualVM.toggleBackground(object);
      campaignVM.setSceneType(CampaignScenes.novel);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Flexible(
          flex: 4,
          fit: FlexFit.tight,
          child: ImageAreaWidget(
            title: "Cenários",
            listImages: visualVM.data.listBackgrounds,
            childWidth: 200,
            showTitle: true,
            aspectRatio: 16 / 9,
            onTap: onTapBackground,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: CharacterAssetAreaWidget(),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CampaignGuestScreen(
                    sizeFactor: 300 / height(context),
                    isPreview: true,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                IntrinsicWidth(
                  child: CheckboxListTile(
                    value: visualVM.data.allowPan,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text("Mover"),
                    onChanged: (value) {
                      visualVM.togglePan();
                    },
                  ),
                ),
                IntrinsicWidth(
                  child: CheckboxListTile(
                    value: visualVM.data.allowZoom,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text("Zoom"),
                    onChanged: (value) {
                      visualVM.toggleZoom();
                    },
                  ),
                ),
                IntrinsicWidth(
                  child: CheckboxListTile(
                    value: visualVM.isClearZoomAndPan,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text("Centralizar ao mudar"),
                    onChanged: (value) {
                      visualVM.isClearZoomAndPan = !visualVM.isClearZoomAndPan;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: CharacterAssetAreaWidget(isRight: true),
        ),
      ],
    );
  }
}
