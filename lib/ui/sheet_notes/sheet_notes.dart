import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/tab_title.dart';
import 'widgets/bio_widget.dart';
import 'widgets/notes_widget.dart';

enum _SheetNotesPages { bio, notes }

class SheetNotesScreen extends StatefulWidget {
  const SheetNotesScreen({super.key});

  @override
  State<SheetNotesScreen> createState() => _SheetNotesScreenState();
}

class _SheetNotesScreenState extends State<SheetNotesScreen> {
  _SheetNotesPages currentPage = _SheetNotesPages.bio;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16,
          children: [
            TabTitle(
              title: "Biografia",
              isActive: currentPage == _SheetNotesPages.bio,
              onTap: () {
                setState(() {
                  currentPage = _SheetNotesPages.bio;
                });
              },
            ),
            TabTitle(
              title: "Anotações livres",
              isActive: currentPage == _SheetNotesPages.notes,
              onTap: () {
                setState(() {
                  currentPage = _SheetNotesPages.notes;
                });
              },
            ),
          ],
        ),
        Divider(),
        Expanded(
          child: IndexedStack(
            index: currentPage.index,
            children: [BioWidget(), NotesWidget()],
          ),
        ),
      ],
    );
  }
}
