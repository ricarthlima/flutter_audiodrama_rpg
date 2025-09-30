import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/named_widget.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/fonts.dart';
import '../../_core/widgets/expansible_list.dart';
import '../controllers/battle_map_controller.dart';
import '../helpers/battle_grid_painter.dart';
import '../models/battle_map.dart';
import '../models/token.dart';
import 'token_widget.dart';

class CampaignBattleMapGridViewer extends StatefulWidget {
  const CampaignBattleMapGridViewer({super.key});

  @override
  State<CampaignBattleMapGridViewer> createState() =>
      _CampaignBattleMapGridViewerState();
}

class _CampaignBattleMapGridViewerState
    extends State<CampaignBattleMapGridViewer> {
  final _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final battleMapProvider = context.watch<CampaignOwnerBattleMapProvider>();

    if (battleMapProvider.battleMap == null) {
      return Center();
    }

    BattleMap battleMap = battleMapProvider.battleMap!;
    final Size imageSize = battleMap.imageSize;

    return Stack(
      key: _stackKey,
      fit: StackFit.passthrough,
      clipBehavior: Clip.hardEdge,
      children: [
        DragTarget<Token>(
          onAcceptWithDetails: (details) {
            battleMapProvider.moveToken(
              battleMap: battleMap,
              position: generatePositionByDetail(
                details.offset,
                battleMapProvider,
              ),
              token: details.data,
            );
          },
          builder: (context, candidateData, rejectedData) {
            return DragTarget<Sheet>(
              onAcceptWithDetails: (details) {
                battleMapProvider.addToken(
                  battleMap: battleMap,
                  position: generatePositionByDetail(
                    details.offset,
                    battleMapProvider,
                  ),
                  sheet: details.data,
                );
              },
              builder: (context, candidateData, rejectedData) {
                return InteractiveViewer(
                  transformationController: battleMapProvider.gridTrans,
                  minScale: 0.5,
                  maxScale: 6,
                  child: Center(
                    child: SizedBox(
                      width: imageSize.width,
                      height: imageSize.height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              battleMap.imageUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.none,
                              width: imageSize.width,
                              height: imageSize.height,
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: BattleGridPainter(
                                cols: battleMap.columns,
                                rows: battleMap.rows,
                                color: battleMap.gridColor.withAlpha(
                                  (battleMap.gridOpacity * 255).floor(),
                                ),
                                stroke: 1.0,
                              ),
                            ),
                          ),
                          for (Token token in battleMap.listTokens)
                            Builder(
                              builder: (context) {
                                Size size = Size(
                                  (imageSize.width / battleMap.columns) *
                                      token.size.width,
                                  (imageSize.height / battleMap.rows) *
                                      token.size.height,
                                );
                                print(size);
                                return Positioned(
                                  left: token.position.x,
                                  top: token.position.y,
                                  width: size.width,
                                  height: size.height,
                                  child: Transform.rotate(
                                    angle: token.rotationDeg * pi / 180.0,
                                    child: TokenWidget(
                                      token: token,
                                      sizeInGrid: size,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
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
                        value: battleMapProvider.zoom,
                        onChanged: (value) {
                          battleMapProvider.zoom = value;
                          battleMapProvider.setZoom(context.size!);
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
                      padding: EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NamedWidget(
                              title: "Opacidade do grid",
                              isLeft: true,
                              child: Slider(
                                value: battleMap.gridOpacity,
                                min: 0,
                                max: 1,
                                padding: EdgeInsets.zero,
                                onChanged: (value) {
                                  battleMap.gridOpacity = value;
                                  battleMapProvider.onUpdate(battleMap);
                                },
                              ),
                            ),
                          ],
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

  Point<double> generatePositionByDetail(
    Offset offset,
    CampaignOwnerBattleMapProvider battleMapProvider,
  ) {
    final box = _stackKey.currentContext!.findRenderObject() as RenderBox;

    // 2) Converter global -> local
    final local = box.globalToLocal(offset);

    // 3) Centralizar o token no ponto solto (opcional)
    final scenePoint = battleMapProvider.gridTrans.toScene(local);

    Point<double> position = Point(scenePoint.dx, scenePoint.dy);
    return position;
  }
}
