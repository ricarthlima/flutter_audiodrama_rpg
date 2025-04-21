import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/widgets/generic_filter_widget.dart';
import '../view/campaign_view_model.dart';
import 'campaign_sheet_item.dart';

class ListSheetsWidget extends StatefulWidget {
  final String title;
  final List<SheetAppUser> listSheetsAppUser;
  final List<Widget>? actions;

  const ListSheetsWidget({
    super.key,
    required this.title,
    required this.listSheetsAppUser,
    this.actions,
  });

  @override
  State<ListSheetsWidget> createState() => _ListSheetsWidgetState();
}

class _ListSheetsWidgetState extends State<ListSheetsWidget> {
  List<Sheet> listSheetsVisualization = [];

  @override
  void initState() {
    super.initState();
    listSheetsVisualization =
        widget.listSheetsAppUser.map((e) => e.sheet).toList();
  }

  @override
  void didUpdateWidget(covariant ListSheetsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listSheetsAppUser != widget.listSheetsAppUser) {
      setState(() {
        listSheetsVisualization =
            List.from(widget.listSheetsAppUser.map((e) => e.sheet).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GenericHeader(
          title: widget.title,
          actions: widget.actions,
          dense: true,
        ),
        if (widget.listSheetsAppUser.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GenericFilterWidget<Sheet>(
              listValues: widget.listSheetsAppUser.map((e) => e.sheet).toList(),
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
              ],
              textExtractor: (p0) => p0.characterName,
              enableSearch: true,
              onFiltered: (listFiltered) {
                setState(() {
                  listSheetsVisualization = listFiltered.map((e) => e).toList();
                });
              },
            ),
          ),
        if (widget.listSheetsAppUser.isNotEmpty)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  listSheetsVisualization.length,
                  (index) {
                    SheetAppUser sheetAppUser = widget.listSheetsAppUser
                        .where((e) => e.sheet == listSheetsVisualization[index])
                        .first;
                    AppUser appUser = sheetAppUser.appUser;
                    return CampaignSheetItem(
                      sheet: listSheetsVisualization[index],
                      appUser: appUser,
                      username: appUser.username ?? "",
                      isShowingByCampaign: true,
                      onDetach: () {
                        campaignVM.openSheetInCampaign(sheetAppUser);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
