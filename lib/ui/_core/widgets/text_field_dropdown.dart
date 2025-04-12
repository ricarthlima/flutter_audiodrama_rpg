import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

class TextFieldDropdown extends StatefulWidget {
  final List<String> listOptions;
  final Function(String value) onSubmit;
  final bool autofocus;
  final InputDecoration? decoration;
  final TextFieldDropdownOptions options;

  const TextFieldDropdown({
    super.key,
    required this.listOptions,
    required this.onSubmit,
    this.autofocus = false,
    this.decoration,
    this.options = TextFieldDropdownOptions.first,
  });

  @override
  State<TextFieldDropdown> createState() => _TextFieldDropdownState();
}

class _TextFieldDropdownState extends State<TextFieldDropdown> {
  final TextEditingController _controller = TextEditingController();
  List<String> opcoesFiltradas = [];
  bool mostrarDropdown = false;

  void _filtrar(String entrada) {
    if (entrada == "") {
      opcoesFiltradas = [];
      mostrarDropdown = false;
      setState(() {});
      return;
    }
    final input = entrada.toLowerCase();
    setState(() {
      opcoesFiltradas = widget.listOptions.where((opcao) {
        final opcaoLower = opcao.toLowerCase();
        return opcaoLower.contains(input) ||
            opcaoLower.similarityTo(input) > 0.5;
      }).toList();
      mostrarDropdown = opcoesFiltradas.isNotEmpty;
    });
  }

  void _selecionar(String valor) {
    _controller.text = valor;
    setState(() => mostrarDropdown = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          autofocus: widget.autofocus,
          controller: _controller,
          decoration: widget.decoration,
          onChanged: _filtrar,
          onTap: () => _filtrar(_controller.text),
          onFieldSubmitted: (value) {
            widget.onSubmit(_controller.text);
          },
        ),
        SizedBox(
          height: 24,
          child: (mostrarDropdown)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.options == TextFieldDropdownOptions.dropdown)
                      ListView(
                        shrinkWrap: true,
                        children: opcoesFiltradas
                            .map(
                              (opcao) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(opcao),
                                onTap: () => _selecionar(opcao),
                              ),
                            )
                            .toList(),
                      ),
                    if (widget.options == TextFieldDropdownOptions.first)
                      Text(opcoesFiltradas.first),
                  ],
                )
              : null,
        )
      ],
    );
  }
}

enum TextFieldDropdownOptions {
  first,
  dropdown,
}
