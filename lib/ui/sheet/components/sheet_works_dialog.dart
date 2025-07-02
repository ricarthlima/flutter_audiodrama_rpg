import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/list_action.dart';
import '../../_core/widgets/loading_widget.dart';
import '../view/sheet_view_model.dart';
import '../widgets/sheet_not_found_widget.dart';

Future<dynamic> showSheetWorksDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SheetWorksDialog(),
      );
    },
  );
}

class SheetWorksDialog extends StatefulWidget {
  final bool isPopup;
  const SheetWorksDialog({super.key, this.isPopup = false});

  @override
  State<SheetWorksDialog> createState() => _SheetWorksDialogState();
}

class _SheetWorksDialogState extends State<SheetWorksDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.isPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<SheetViewModel>(context, listen: false);
        viewModel.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    return (sheetViewModel.isLoading)
        ? LoadingWidget()
        : (sheetViewModel.isFoundSheet)
            ? _buildBody(context)
            : SheetNotFoundWidget();
  }

  Scaffold _buildBody(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Configurações da Ficha")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                "Ofícios",
                style: TextStyle(
                  fontFamily: "Bungee",
                ),
              ),
              Column(
                children: List.generate(
                  sheetVM.actionRepo.getListWorks().length,
                  (index) {
                    ListAction work = sheetVM.actionRepo.getListWorks()[index];
                    return SizedBox(
                      width: 300,
                      child: CheckboxListTile(
                        value:
                            sheetVM.sheet!.listActiveWorks.contains(work.name),
                        title: Text(work.name[0].toUpperCase() +
                            work.name.substring(1)),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          sheetVM.toggleActiveWork(work.name);
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(
                thickness: 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
