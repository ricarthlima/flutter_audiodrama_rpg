import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/campaign_visual.dart';
import '../../../_core/app_colors.dart';
import '../../../_core/components/image_dialog.dart';
import '../../view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';

class AssetImageItem extends StatelessWidget {
  final CampaignVisual visual;
  final bool isRight;

  const AssetImageItem({
    super.key,
    required this.visual,
    required this.isRight,
  });

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return InkWell(
      onTap: () {
        visualVM.toggleVisual(isRight: isRight, visual: visual);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: visualVM.isVisualInList(isRight: isRight, visual: visual)
              ? Border.all(width: 4, color: AppColors.red)
              : Border.all(width: 4, color: Colors.transparent),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(imageUrl: visual.url, width: 100),
            IconViewImageButton(imageUrl: visual.url),
            Align(
              alignment: Alignment.bottomCenter,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withAlpha(175), Colors.transparent],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  height: 25,
                  width: 100,
                  color: Colors.black,
                  child: Text(" "),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                visual.name,
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
