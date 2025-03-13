import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/fonts.dart';
import 'home_list_item_widget.dart';

class HomeListSheetsWidget extends StatelessWidget {
  final List<Sheet> listSheets;
  final String username;
  final String? title;
  final bool showAdding;

  const HomeListSheetsWidget({
    super.key,
    required this.listSheets,
    required this.username,
    this.title,
    this.showAdding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          GenericHeader(
            title: title!,
            iconButton: IconButton(
              onPressed: () {
                context.read<HomeViewModel>().onCreateSheetClicked(context);
              },
              tooltip: "Criar personagem",
              icon: Icon(Icons.add),
            ),
          ),
          if (listSheets.isEmpty)
            Center(
              child: Text(
                "Nada por aqui ainda, vamos criar?",
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: FontFamily.sourceSerif4,
                ),
              ),
            ),
          if (listSheets.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                listSheets.length,
                (index) {
                  return HomeListItemWidget(
                    sheet: listSheets[index],
                    username: username,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
