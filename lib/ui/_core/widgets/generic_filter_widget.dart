// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class GenericFilterWidget<T> extends StatefulWidget {
  final List<T> listValues;
  final List<GenericFilterOrderer<T>> listOrderers;
  final void Function(List<T>) onFiltered;
  final bool enableSearch;
  final String Function(T) textExtractor;

  const GenericFilterWidget({
    super.key,
    required this.listValues,
    required this.listOrderers,
    required this.onFiltered,
    required this.textExtractor,
    this.enableSearch = true,
  });

  @override
  _GenericFilterWidgetState<T> createState() => _GenericFilterWidgetState<T>();
}

class _GenericFilterWidgetState<T> extends State<GenericFilterWidget<T>> {
  late List<T> filteredList;
  String searchQuery = '';
  GenericFilterOrderer<T>? selectedOrderer;
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    filteredList = List.from(widget.listValues);

    // Se houver ordernadores disponíveis, seleciona o primeiro automaticamente
    if (widget.listOrderers.isNotEmpty) {
      selectedOrderer = widget.listOrderers.first;
    }

    // Espera o primeiro frame para aplicar a ordenação e filtro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<T> tempList = widget.listValues.where((item) {
      String itemText = widget.textExtractor(item).toLowerCase();
      return searchQuery.isEmpty ||
          itemText.contains(searchQuery.toLowerCase());
    }).toList();

    // Verifica se há um ordenador selecionado e aplica a ordenação
    if (selectedOrderer != null) {
      tempList.sort((a, b) {
        int result = selectedOrderer!.orderFunction(a, b);
        return isAscending ? result : -result;
      });
    }

    // Atualiza o estado para refletir a nova lista ordenada e filtrada
    setState(() {
      filteredList = List.from(tempList);
    });

    widget.onFiltered(filteredList);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.enableSearch)
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'Pesquisar'),
              onChanged: (value) {
                searchQuery = value;
                _applyFilters();
              },
            ),
          ),
        const SizedBox(width: 16),
        ...widget.listOrderers.map((orderer) {
          bool isSelected = selectedOrderer == orderer;
          return IconButton(
            icon: Icon(
              isSelected
                  ? (isAscending
                        ? orderer.iconAscending
                        : orderer.iconDescending)
                  : orderer.iconAscending,
            ),
            onPressed: () {
              setState(() {
                if (selectedOrderer?.label == orderer.label) {
                  isAscending =
                      !isAscending; // Alterna entre ascendente e descendente
                } else {
                  selectedOrderer = orderer;
                  isAscending =
                      true; // Quando muda de critério, sempre começa em ascendente
                }
              });
              _applyFilters();
            },
            tooltip:
                "${orderer.label} (${isAscending ? "Ascendente" : "Descendente"})",
          );
        }),
      ],
    );
  }
}

class GenericFilterOrderer<T> {
  final String label;
  final IconData iconAscending;
  final IconData iconDescending;
  final int Function(T a, T b) orderFunction;

  GenericFilterOrderer({
    required this.label,
    required this.iconAscending,
    required this.iconDescending,
    required this.orderFunction,
  });
}
