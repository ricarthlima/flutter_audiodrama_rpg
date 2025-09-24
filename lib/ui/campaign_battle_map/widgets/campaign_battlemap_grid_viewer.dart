import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/expansible_list.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/models/battle_map.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/widgets/drop_on_battlemap.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/widgets/token_widget.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../helpers/battle_grid_painter.dart';
import '../helpers/grid_helpers.dart';
import '../models/token.dart';

class CampaignBattleMapGridViewer extends StatelessWidget {
  const CampaignBattleMapGridViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    bool isActive =
        campaignProvider.ownerViewBattleMap != null ||
        campaignProvider.campaign!.activeBattleMapId != null;

    if (!isActive) {
      return Placeholder();
    }

    String id = (campaignProvider.ownerViewBattleMap != null)
        ? campaignProvider.ownerViewBattleMap!
        : campaignProvider.campaign!.activeBattleMapId!;

    BattleMap battleMap = campaignProvider.campaign!.listBattleMaps
        .where((e) => e.id == id)
        .first;

    final Size imageSize = battleMap.imageSize;
    final GridSpec grid = GridSpec(
      cols: battleMap.columns,
      rows: battleMap.rows,
    );

    return Stack(
      fit: StackFit.passthrough,
      children: [
        DropOnBattleMap<Token>(
          controller: campaignProvider.gridTransformationOwner,
          imageSize: imageSize,
          grid: grid,
          onDrop: (DropResult<Token> dropResult) {
            campaignProvider.moveTokenToBattleMap(
              battleMap: battleMap,
              position: dropResult.rawGridPos,
              token: dropResult.data,
            );
          },
          child: DropOnBattleMap<Sheet>(
            controller: campaignProvider.gridTransformationOwner,
            imageSize: imageSize,
            grid: grid,
            onDrop: (DropResult<Sheet> dropResult) {
              campaignProvider.addTokenToBattleMap(
                battleMap: battleMap,
                sheet: dropResult.data,
                position: dropResult.rawGridPos,
              );
            },
            child: InteractiveViewer(
              transformationController:
                  campaignProvider.gridTransformationOwner,
              minScale: 0.5,
              maxScale: 6,
              child: Padding(
                padding: const EdgeInsets.all(128.0),
                child: Stack(
                  children: [
                    Positioned.fill(child: Image.network(battleMap.imageUrl)),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BattleGridPainter(
                          cols: battleMap.columns,
                          rows: battleMap.rows,
                          color: Colors.white.withOpacity(0.25),
                          stroke: 1.0,
                        ),
                      ),
                    ),
                    for (Token t in battleMap.listTokens)
                      Builder(
                        builder: (_) {
                          final Rect r = tokenRectPx(t, imageSize, grid: grid);
                          return Positioned(
                            left: r.left,
                            top: r.top,
                            width: r.width,
                            height: r.height,
                            child: Transform.rotate(
                              angle: t.rotationDeg * pi / 180.0,
                              child: TokenWidget(
                                token: t,
                                battleMap: battleMap,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(color: Colors.black.withAlpha(200), height: 40),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                battleMap.name,
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.zoom_in),
                      Slider(
                        min: 0.5,
                        max: 6,
                        value: campaignProvider.battleMapZoom,
                        onChanged: (value) {
                          campaignProvider.battleMapZoom = value;
                          campaignProvider.setZoom(context.size!);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: ExpansibleList(
                    title: "Configurações",
                    startClosed: true,
                    child: Container(
                      color: Colors.black.withAlpha(200),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Trabalho em progresso")],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
