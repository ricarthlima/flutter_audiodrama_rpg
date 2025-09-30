import 'package:flutter/material.dart';
import '../../../_core/providers/audio_provider.dart';
import '../view/campaign_visual_novel_view_model.dart';
import '../widgets/visual_novel/audio_area_widget.dart';
import '../widgets/visual_novel/image_area_widget.dart';
import 'package:provider/provider.dart';

class AmbienceAssetsSection extends StatelessWidget {
  const AmbienceAssetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Flexible(
          flex: 4,
          fit: FlexFit.tight,
          child: ImageAreaWidget(
            title: "Objetos, Notas e Itens",
            listImages: visualVM.data.listObjects,
            childWidth: 64,
            aspectRatio: 1,
            onTap: visualVM.toggleObject,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: AudioAreaWidget(
            title: "Músicas",
            type: AudioProviderType.music,
            listAudios: visualVM.data.listMusics,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: AudioAreaWidget(
            title: "Ambientações",
            type: AudioProviderType.ambience,
            listAudios: visualVM.data.listAmbiences,
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: AudioAreaWidget(
            title: "Efeitos",
            type: AudioProviderType.sfx,
            listAudios: visualVM.data.listSfxs,
          ),
        ),
      ],
    );
  }
}
