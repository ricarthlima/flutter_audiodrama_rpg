import '../../domain/models/sheet_model.dart';
import '../../ui/_core/utils/download_json_file.dart';
import '../../ui/sheet/view/sheet_view_model.dart';

downloadSheetJSON(SheetViewModel sheetVM) async {
  Sheet? sheet = await sheetVM.saveChanges();

  if (sheet != null) {
    downloadJsonFile(
      sheet.toMapWithoutId(),
      "sheet-${sheet.characterName.toLowerCase().replaceAll(" ", "_")}.json",
    );
  }
}
