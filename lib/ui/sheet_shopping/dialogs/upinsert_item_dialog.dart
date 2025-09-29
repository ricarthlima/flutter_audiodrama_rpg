import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/dto/item.dart';
import '../../_core/fonts.dart';
import '../../sheet/providers/sheet_view_model.dart';

class UpinsertItemDialog extends StatefulWidget {
  final Item? customItem;
  final Function onDismiss;
  const UpinsertItemDialog({
    super.key,
    required this.onDismiss,
    this.customItem,
  });

  @override
  State<UpinsertItemDialog> createState() => _UpinsertItemDialogState();
}

class _UpinsertItemDialogState extends State<UpinsertItemDialog> {
  bool isDetailsOpen = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController(text: "1");
  TextEditingController mechanicController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  bool isFinite = false;
  TextEditingController maxUsesController = TextEditingController();

  @override
  void initState() {
    setState(() {
      if (widget.customItem != null) {
        nameController.text = widget.customItem!.name;
        descriptionController.text = widget.customItem!.description;
        mechanicController.text = widget.customItem!.mechanic;
        weightController.text = widget.customItem!.weight.toString();
        priceController.text = widget.customItem!.price.toString();
        maxUsesController.text = widget.customItem!.maxUses.toString();
        isFinite = widget.customItem!.isFinite;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(16),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                widget.customItem == null
                    ? 'Adicionar item'
                    : 'Editando ${widget.customItem?.name}',
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
              ),
              TextFormField(
                controller: nameController,
                maxLength: 20,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.abc),
                  label: Text('Nome'),
                ),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.abc),
                  label: Text('Descrição'),
                ),
                maxLines: 3,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.numbers),
                  label: Text('Quantidade'),
                ),
              ),
              ListTile(
                title: Text("Mostrar detalhes"),
                contentPadding: EdgeInsets.zero,
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      isDetailsOpen = !isDetailsOpen;
                    });
                  },
                  icon: Icon(
                    isDetailsOpen ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ),
              AnimatedSize(
                duration: Duration(milliseconds: 250),
                child: SizedBox(
                  height: isDetailsOpen ? null : 0,
                  child: Column(
                    spacing: 8,
                    children: [
                      TextFormField(
                        controller: mechanicController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.abc),
                          label: Text('Mecânica'),
                        ),
                        maxLines: 3,
                      ),
                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.fitness_center),
                          label: Text('Peso'),
                        ),
                      ),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.attach_money_rounded),
                          label: Text('Preço'),
                        ),
                      ),
                      CheckboxListTile(
                        value: isFinite,
                        onChanged: (value) {
                          setState(() {
                            isFinite = !isFinite;
                          });
                        },
                        title: Text("É finito?"),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      TextFormField(
                        enabled: isFinite,
                        controller: maxUsesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],

                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.numbers),
                          label: Text('Usos máximos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onDismiss();
                    },
                    child: Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _createItem();
                    },
                    child: Text("Criar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createItem() {
    Item item = Item(
      id: (widget.customItem != null) ? widget.customItem!.id : Uuid().v4(),
      name: nameController.text,
      weight: double.tryParse(weightController.text) ?? 0,
      price: int.tryParse(priceController.text) ?? 0,
      description: descriptionController.text,
      mechanic: mechanicController.text,
      isFinite: isFinite,
      maxUses: int.tryParse(maxUsesController.text),
      listCategories: [],
    );

    context.read<SheetViewModel>().upinsertCustomItem(
      item,
      int.tryParse(amountController.text) ?? 1,
    );
    widget.onDismiss();
  }
}
