import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_visual.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';

class CampaignHomeScreen extends StatelessWidget {
  const CampaignHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    if (campaignVM.isOwner) {
      return _CampaignHomeOwner();
    }

    return _CampaignHomeGuest();
  }
}

class _CampaignHomeGuest extends StatelessWidget {
  final double sizeFactor;
  const _CampaignHomeGuest({this.sizeFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: _generateListStack(context, visualVM),
        ),
      ),
    );
  }

  List<Widget> _generateListStack(
    BuildContext context,
    CampaignVisualNovelViewModel visualVM,
  ) {
    List<Widget> result = [];

    if (visualVM.backgroundActive != null) {
      result.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.network(
            visualVM.backgroundActive!.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    List<Widget> leftList = [];
    for (int i = 0; i < visualVM.listLeftActive.length; i++) {
      CampaignVisual cm = visualVM.listLeftActive[i];
      leftList.add(
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: visualVM.visualScale *
                  i *
                  visualVM.distanceFactor *
                  sizeFactor,
            ),
            child: Image.network(
              cm.imageUrl,
              width: visualVM.visualScale * sizeFactor,
            ),
          ),
        ),
      );
    }

    List<Widget> rightList = [];
    for (int i = 0; i < visualVM.listRightActive.length; i++) {
      CampaignVisual cm = visualVM.listRightActive[i];
      rightList.add(
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: visualVM.visualScale *
                  i *
                  visualVM.distanceFactor *
                  sizeFactor,
            ),
            child: Transform.flip(
              flipX: true,
              child: Image.network(
                cm.imageUrl,
                width: visualVM.visualScale * sizeFactor,
              ),
            ),
          ),
        ),
      );
    }
    leftList = leftList.reversed.toList();
    rightList = rightList.reversed.toList();
    result.addAll(leftList);
    result.addAll(rightList);

    return result;
  }
}

class _CampaignHomeOwner extends StatelessWidget {
  const _CampaignHomeOwner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 32, right: 96),
      child: SizedBox(
        width: width(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: _ListCharactersVisual(),
                ),
                VerticalDivider(),
                Flexible(
                  flex: 6,
                  child: SizedBox(
                    width: width(context) * 0.5,
                    child: _CampaignHomeGuest(
                      sizeFactor: 0.5,
                    ),
                  ),
                ),
                VerticalDivider(),
                Flexible(
                  flex: 3,
                  child: _ListCharactersVisual(
                    isRight: true,
                  ),
                ),
              ],
            ),
            _ListBackgrounds(),
            Divider(thickness: 0.1),
            _ListSounds(),
          ],
        ),
      ),
    );
  }
}

class _ListCharactersVisual extends StatelessWidget {
  final bool isRight;
  const _ListCharactersVisual({this.isRight = false});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isRight)
              Text(
                "Personagens da Esquerda",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: FontFamily.bungee,
                ),
              ),
            if (isRight)
              Text(
                "Personagens da Direita",
                style: TextStyle(
                  fontFamily: FontFamily.bungee,
                ),
              ),
            CheckboxListTile(
              value: (isRight) ? visualVM.isClearRight : visualVM.isClearLeft,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                if (isRight) {
                  visualVM.isClearRight = !visualVM.isClearRight;
                } else {
                  visualVM.isClearLeft = !visualVM.isClearLeft;
                }
              },
              title: Text("Limpar ao mudar fundo"),
            ),
            Wrap(
              children: List.generate(
                visualVM.listVisuals.length,
                (index) {
                  CampaignVisual cv = visualVM.listVisuals[index];
                  return _ImageVisualItem(
                    visual: cv,
                    isRight: isRight,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ImageVisualItem extends StatelessWidget {
  final CampaignVisual visual;
  final bool isRight;

  const _ImageVisualItem({
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
            Image.network(
              visual.imageUrl,
              width: 100,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                visual.name,
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListBackgrounds extends StatelessWidget {
  const _ListBackgrounds();

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          "Planos de fundo",
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
        ),
        SizedBox(
          width: width(context),
          height: (64 * 2) + 16,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                visualVM.listBackgrounds.length,
                (index) {
                  CampaignVisual visualBG = visualVM.listBackgrounds[index];
                  return _BackgroundItem(visualBG: visualBG);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundItem extends StatelessWidget {
  final CampaignVisual visualBG;
  const _BackgroundItem({required this.visualBG});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);
    return InkWell(
      onTap: () {
        visualVM.toggleBackground(visualBG);
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: visualVM.backgroundActive == visualBG
              ? Border.all(width: 4, color: AppColors.red)
              : Border.all(width: 4, color: Colors.transparent),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              Image.network(
                visualBG.imageUrl,
                height: 64,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  visualBG.name,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListSounds extends StatelessWidget {
  const _ListSounds();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                "Músicas",
                style: TextStyle(
                  fontFamily: FontFamily.bungee,
                ),
              ),
              Wrap(
                children: List.generate(
                  50,
                  (index) => IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.music_note_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                "Ambientações",
                style: TextStyle(
                  fontFamily: FontFamily.bungee,
                ),
              ),
              Wrap(
                children: List.generate(
                  50,
                  (index) => IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.speaker),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                "SFXs",
                style: TextStyle(
                  fontFamily: FontFamily.bungee,
                ),
              ),
              Wrap(
                children: List.generate(
                  50,
                  (index) => IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.speaker),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
