import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/campaign_visual.dart';
import '../../../_core/app_colors.dart';
import '../../../_core/components/image_dialog.dart';
import '../../../_core/fonts.dart';
import '../../../_core/widgets/generic_filter_widget.dart';

class ImageAreaWidget extends StatefulWidget {
  final String title;
  final List<CampaignVisual> listImages;
  final double childWidth;
  final double aspectRatio;
  final Function(CampaignVisual object) onTap;
  final bool showTitle;

  const ImageAreaWidget({
    super.key,
    required this.title,
    required this.listImages,
    required this.childWidth,
    required this.aspectRatio,
    required this.onTap,
    this.showTitle = false,
  });

  @override
  State<ImageAreaWidget> createState() => _ImageAreaWidgetState();
}

class _ImageAreaWidgetState extends State<ImageAreaWidget> {
  List<CampaignVisual> listVisualization = [];

  @override
  void initState() {
    super.initState();
    listVisualization = widget.listImages.toList();
  }

  @override
  void didUpdateWidget(covariant ImageAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listImages != widget.listImages) {
      setState(() {
        listVisualization = List.from(widget.listImages.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: TextStyle(fontFamily: FontFamily.bungee)),
            SizedBox(
              width: 200,
              child: GenericFilterWidget<CampaignVisual>(
                listValues: widget.listImages,
                listOrderers: [
                  GenericFilterOrderer<CampaignVisual>(
                    label: "Por nome",
                    iconAscending: Icons.sort_by_alpha,
                    iconDescending: Icons.sort_by_alpha,
                    orderFunction: (a, b) => a.name.compareTo(b.name),
                  ),
                ],
                textExtractor: (p0) => p0.name,
                enableSearch: true,
                onFiltered: (listFiltered) {
                  setState(() {
                    listVisualization = listFiltered.map((e) => e).toList();
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Flexible(
          child: GridView.builder(
            padding: EdgeInsets.only(bottom: 64, right: 16),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: widget.childWidth,
              childAspectRatio: widget.aspectRatio,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: listVisualization.length,
            itemBuilder: (context, index) {
              final visualObject = listVisualization[index];
              return SizedBox(
                height: (!widget.showTitle) ? null : 85,
                width: widget.childWidth,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InkWell(
                      onTap: () => widget.onTap(visualObject),
                      child: Tooltip(
                        message: visualObject.name,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: visualObject.isEnable
                                  ? AppColors.red
                                  : Colors.transparent,
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: visualObject.url,
                            placeholder: (context, url) =>
                                Icon(Icons.landscape),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    IconViewImageButton(imageUrl: visualObject.url),
                    if (widget.showTitle)
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withAlpha(175),
                                    Colors.transparent,
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Container(
                                height: 32,
                                width: double.infinity,
                                color: Colors.black,
                                child: Text(" "),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              visualObject.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
