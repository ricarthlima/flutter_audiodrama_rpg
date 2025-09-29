import 'package:flutter/material.dart';
import '../../../../domain/models/campaign_visual.dart';
import '../../../_core/fonts.dart';
import '../../view/campaign_visual_novel_view_model.dart';
import 'asset_image_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class CharacterAssetAreaWidget extends StatelessWidget {
  final bool isRight;
  CharacterAssetAreaWidget({super.key, this.isRight = false});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isRight)
          Text(
            "Personagens da Esquerda",
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: FontFamily.bungee),
          ),
        if (isRight)
          Text(
            "Personagens da Direita",
            style: TextStyle(fontFamily: FontFamily.bungee),
          ),
        CheckboxListTile(
          value: (isRight) ? visualVM.isClearRight : visualVM.isClearLeft,
          contentPadding: EdgeInsets.zero,
          controlAffinity: (isRight)
              ? ListTileControlAffinity.leading
              : ListTileControlAffinity.trailing,
          onChanged: (value) {
            if (isRight) {
              visualVM.isClearRight = !visualVM.isClearRight;
            } else {
              visualVM.isClearLeft = !visualVM.isClearLeft;
            }
          },
          title: Text(
            "Limpar ao mudar fundo",
            textAlign: (!isRight) ? TextAlign.end : TextAlign.start,
          ),
        ),
        Flexible(
          child: MasonryGridView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(right: 16),
            gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120, // largura máxima por item
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: visualVM.data.listPortraits.length,
            itemBuilder: (context, index) {
              CampaignVisual cv = visualVM.data.listPortraits[index];
              return AssetImageItem(visual: cv, isRight: isRight);
            },
          ),
        ),
      ],
    );
  }
}
