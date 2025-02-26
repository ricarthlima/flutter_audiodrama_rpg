import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet_notes/widgets/bio_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet_notes/widgets/notes_widget.dart';

Future<void> showSheetNotesDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(child: SheetNotesScreen());
    },
  );
}

class SheetNotesScreen extends StatefulWidget {
  const SheetNotesScreen({super.key});

  @override
  State<SheetNotesScreen> createState() => _SheetNotesScreenState();
}

class _SheetNotesScreenState extends State<SheetNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      height: height(context),
      padding: EdgeInsets.all(16),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(tabs: [Tab(text: "Bio"), Tab(text: "Anotações")]),
            Expanded(
              child: TabBarView(children: [
                BioWidget(),
                NotesWidget(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
