import 'package:flutter/material.dart';
import '../../../../domain/models/campaign_visual.dart';
import '../../../_core/fonts.dart';
import '../../view/campaign_visual_novel_view_model.dart';
import 'asset_image_item.dart';
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
            "Esquerda",
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: FontFamily.bungee),
          ),
        if (isRight)
          Text("Direita", style: TextStyle(fontFamily: FontFamily.bungee)),
        Tooltip(
          message: "Limpar ao mudar o fundo",
          child: CheckboxListTile(
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
              "Limpar",
              textAlign: (!isRight) ? TextAlign.end : TextAlign.start,
            ),
          ),
        ),
        Flexible(
          child: GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(right: 16),
            gridDelegate:
                // SliverGridDelegateWithMaxCrossAxisExtent(
                //   maxCrossAxisExtent: 50,
                //   mainAxisSpacing: 4,
                //   crossAxisSpacing: 4,
                // ),
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
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
