import 'package:flutter/material.dart';
import '../../sheet/providers/sheet_view_model.dart';
import 'package:provider/provider.dart';

class NotesWidget extends StatelessWidget {
  const NotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          Text(
            "Anote aqui o que quiser",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (sheetViewModel.isOwner)
            Expanded(
              child: TextFormField(
                controller: sheetViewModel.notesTextController(),
                maxLines: null,
                expands: true,
              ),
            ),
          if (!sheetViewModel.isOwner)
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  sheetViewModel.notesTextController().text,
                ),
              ),
            ),
          if (sheetViewModel.isOwner)
            AnimatedSwitcher(
              duration: Duration(milliseconds: 750),
              child: (sheetViewModel.isSavingNotes == null)
                  ? ElevatedButton(
                      onPressed: () {
                        sheetViewModel.saveNotes();
                      },
                      child: Text("Salvar"),
                    )
                  : (sheetViewModel.isSavingNotes!)
                  ? Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Icon(Icons.check, size: 32),
            ),
        ],
      ),
    );
  }
}
