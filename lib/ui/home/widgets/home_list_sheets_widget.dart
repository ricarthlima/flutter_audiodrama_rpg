import 'package:flutter/material.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/fonts.dart';
import 'home_list_item_widget.dart';

class HomeListSheetsWidget extends StatelessWidget {
  final List<Sheet> listSheets;
  final String username;
  final String? title;

  const HomeListSheetsWidget({
    super.key,
    required this.listSheets,
    required this.username,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (listSheets.isEmpty) {
      return Center(
        child: Text(
          "Nada por aqui ainda, vamos criar?",
          style: TextStyle(
            fontSize: 24,
            fontFamily: FontFamily.sourceSerif4,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: FontFamily.bungee,
                ),
              ),
            ),
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
