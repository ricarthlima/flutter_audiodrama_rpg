import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/exceptions/general_exceptions.dart';
import '../../_core/fonts.dart';
import '../../_core/snackbars/snackbars.dart';
import '../../_core/utils/load_image.dart';
import '../../_core/validators/validators.dart';
import '../../campaign_battle_map/models/battle_map.dart';
import '../view/campaign_view_model.dart';

void showUpinsertBattleMap(BuildContext context, {BattleMap? battleMap}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(child: _UpinsertBattleMap(battleMap: battleMap));
    },
  );
}

class _UpinsertBattleMap extends StatefulWidget {
  final BattleMap? battleMap;
  const _UpinsertBattleMap({this.battleMap});

  @override
  State<_UpinsertBattleMap> createState() => __UpinsertBattleMapState();
}

class __UpinsertBattleMapState extends State<_UpinsertBattleMap> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Uint8List? image;
  String id = Uuid().v4();

  TextEditingController nameController = TextEditingController();
  TextEditingController columnController = TextEditingController();
  TextEditingController rowController = TextEditingController();

  TextEditingController musicController = TextEditingController();
  TextEditingController ambienceController = TextEditingController();

  List<String> listMusics = ["(Nenhuma)"];
  List<String> listAmbiences = ["(Nenhuma)"];

  String? _imageError;

  bool isLoading = false;
  bool isLoadingImage = false;

  @override
  void initState() {
    if (widget.battleMap != null) {
      id = widget.battleMap!.id;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignProvider campaignProvider = context.read<CampaignProvider>();

      listMusics.addAll(
        campaignProvider.campaign!.visualData.listMusics.map((e) {
          return e.name;
        }),
      );

      listAmbiences.addAll(
        campaignProvider.campaign!.visualData.listAmbiences.map((e) {
          return e.name;
        }),
      );

      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                "${widget.battleMap != null ? 'Editando' : 'Criando'} Mapa de Batalha",
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Básico",
                            style: TextStyle(fontFamily: FontFamily.bungee),
                          ),
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(label: Text("Nome")),
                            validator: (v) => InputValidators.required(v),
                          ),
                        ],
                      ),
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dimensões",
                            style: TextStyle(fontFamily: FontFamily.bungee),
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              Flexible(
                                child: TextFormField(
                                  controller: columnController,
                                  decoration: InputDecoration(
                                    label: Text("Colunas"),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) =>
                                      InputValidators.positiveInt(v),
                                ),
                              ),
                              Flexible(
                                child: TextFormField(
                                  controller: rowController,
                                  decoration: InputDecoration(
                                    label: Text("Linhas"),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) =>
                                      InputValidators.positiveInt(v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Imagem",
                            style: TextStyle(fontFamily: FontFamily.bungee),
                          ),
                          if (image != null) Image.memory(image!),
                          ElevatedButton(
                            onPressed: (isLoading || isLoadingImage)
                                ? null
                                : () {
                                    _uploadImage();
                                  },
                            child: Text("Subir imagem"),
                          ),
                          if (_imageError != null)
                            Text(
                              _imageError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Outras configurações",
                            style: TextStyle(fontFamily: FontFamily.bungee),
                          ),
                          Text("Mudar música ao ativar"),
                          DropdownMenu<String>(
                            controller: musicController,
                            width: 400,
                            enableFilter: false,
                            enableSearch: false,
                            requestFocusOnTap: false,
                            initialSelection: listMusics.first,
                            dropdownMenuEntries: listMusics.map((e) {
                              return DropdownMenuEntry(value: e, label: e);
                            }).toList(),
                          ),
                          Text("Mudar ambientação ao ativar"),
                          DropdownMenu<String>(
                            controller: ambienceController,
                            width: 400,
                            enableFilter: false,
                            enableSearch: false,
                            requestFocusOnTap: false,
                            initialSelection: listAmbiences.first,
                            dropdownMenuEntries: listAmbiences.map((e) {
                              return DropdownMenuEntry(value: e, label: e);
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              (isLoading)
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 16,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _createBattleMap();
                              },
                              child: Text("Criar"),
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    try {
      setState(() {
        isLoadingImage = true;
      });
      image = await loadAndCompressImage(context);
      setState(() {
        isLoadingImage = false;
      });
    } on ImageTooLargeException {
      if (!mounted) return;
      showImageTooLargeSnackbar(context);
    }
  }

  Future<void> _createBattleMap() async {
    final form = formKey.currentState;
    if (form == null) return;

    final bool okFields = form.validate();
    final bool okImage = image != null;

    setState(() {
      _imageError = okImage ? null : 'Selecione uma imagem';
    });

    if (!okFields || !okImage) return;

    try {
      setState(() {
        isLoading = true;
      });
      await context.read<CampaignProvider>().upinsertBattleMap(
        id: id,
        name: nameController.text,
        columns: int.parse(columnController.text),
        rows: int.parse(rowController.text),
        image: image!,
        ambience: ambienceController.text != listAmbiences.first
            ? ambienceController.text
            : null,
        music: musicController.text != listMusics.first
            ? musicController.text
            : null,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, "Falha ao salvar: $e");
    }
  }
}
