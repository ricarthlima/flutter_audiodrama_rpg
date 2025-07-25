import 'package:flutter/material.dart';
import 'widgets/bio_widget.dart';
import 'widgets/notes_widget.dart';

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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(icon: Icon(Icons.edit), text: "Bio"),
            Tab(icon: Icon(Icons.note_alt), text: "Anotações"),
          ]),
          Expanded(
            child: TabBarView(children: [
              BioWidget(),
              NotesWidget(),
            ]),
          ),
        ],
      ),
    );
  }
}
