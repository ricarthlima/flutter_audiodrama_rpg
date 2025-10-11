// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/utils/download_sheet_json.dart';
import '../../../domain/models/sheet_model.dart';
import '../../_core/fonts.dart';
import '../../_core/widgets/generic_filter_widget.dart';
import '../../_core/widgets/generic_header.dart';
import '../view/home_interact.dart';
import '../view/home_view_model.dart';
import 'home_list_item_widget.dart';

class HomeListSheetsWidget extends StatefulWidget {
  final List<Sheet> listSheets;
  final String username;
  final String? title;
  final String? subtitle;
  final bool showAdding;
  final bool showTitle;

  const HomeListSheetsWidget({
    super.key,
    required this.listSheets,
    required this.username,
    this.title,
    this.subtitle,
    this.showAdding = true,
    this.showTitle = true,
  });

  @override
  State<HomeListSheetsWidget> createState() => _HomeListSheetsWidgetState();
}

class _HomeListSheetsWidgetState extends State<HomeListSheetsWidget> {
  List<Sheet> listSheetsVisualization = [];
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    listSheetsVisualization = widget.listSheets;
  }

  @override
  void didUpdateWidget(covariant HomeListSheetsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listSheets != widget.listSheets) {
      setState(() {
        listSheetsVisualization = List.from(widget.listSheets);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          if (widget.showTitle)
            GenericHeader(
              title: widget.title!,
              subtitle: widget.subtitle,
              actions: [
                if (widget.showAdding)
                  IconButton(
                    onPressed: () {
                      importFromJson(context);
                    },
                    tooltip: "Importar personagem",
                    icon: Icon(Icons.file_download_outlined),
                  ),
                if (widget.showAdding)
                  IconButton(
                    onPressed: () {
                      HomeInteract.onCreateCharacterClicked(context);
                    },
                    tooltip: "Criar personagem",
                    icon: Icon(Icons.add),
                  ),
              ],
              iconButton: IconButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                icon: Icon(
                  (!isExpanded) ? Icons.expand_more : Icons.expand_less,
                ),
              ),
              showDivider: false,
            ),
          if (widget.listSheets.isEmpty)
            Expanded(
              child: Center(
                child: Opacity(
                  opacity: 0.25,
                  child: Text(
                    "Nada por aqui ainda,\nvamos criar?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: FontFamily.sourceSerif4,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.listSheets.isNotEmpty && isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GenericFilterWidget<Sheet>(
                listValues: widget.listSheets,
                listOrderers: [
                  GenericFilterOrderer<Sheet>(
                    label: "Por nome",
                    iconAscending: Icons.sort_by_alpha,
                    iconDescending: Icons.sort_by_alpha,
                    orderFunction: (a, b) =>
                        a.characterName.compareTo(b.characterName),
                  ),
                  GenericFilterOrderer<Sheet>(
                    label: "Por experiência",
                    iconAscending: Icons.military_tech_outlined,
                    iconDescending: Icons.military_tech_outlined,
                    orderFunction: (a, b) {
                      int c = a.baseLevel.compareTo(b.baseLevel);
                      return (c != 0)
                          ? c
                          : a.characterName.compareTo(b.characterName);
                    },
                  ),
                  // GenericFilterOrderer<_SheetCampaign>(
                  //   label: "Por campanha",
                  //   iconAscending: Icons.local_florist_outlined,
                  //   iconDescending: Icons.local_florist_outlined,
                  //   orderFunction: (a, b) {
                  //     int c = a.campaignName.compareTo(b.campaignName);
                  //     return (c != 0)
                  //         ? c
                  //         : a.sheet.characterName
                  //             .compareTo(b.sheet.characterName);
                  //   },
                  // ),
                ],
                textExtractor: (p0) => p0.characterName,
                enableSearch: true,
                onFiltered: (listFiltered) {
                  setState(() {
                    listSheetsVisualization = listFiltered
                        .map((e) => e)
                        .toList();
                  });
                },
              ),
            ),
          if (widget.listSheets.isNotEmpty)
            Expanded(
              child: ListView(
                children: List.generate(listSheetsVisualization.length, (
                  index,
                ) {
                  return HomeListItemWidget(
                    sheet: listSheetsVisualization[index],
                    username: widget.username,
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> importFromJson(BuildContext context) async {
  Map<String, dynamic>? map = await pickAndReadJsonFile();
  if (map != null && context.mounted) {
    context.read<HomeViewModel>().createSheetByMap(map);
  }
}
