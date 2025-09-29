import 'package:flutter/material.dart';

import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
import '../../_core/widgets/text_markdown.dart';

class ConditionWidget extends StatefulWidget {
  final int condition;
  const ConditionWidget({super.key, required this.condition});

  @override
  State<ConditionWidget> createState() => _ConditionWidgetState();
}

class _ConditionWidgetState extends State<ConditionWidget> {
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _showTooltip(),
      onExit: (event) => _hideTooltip(),
      child: Text(
        getConditionName(widget.condition),
        style: TextStyle(
          fontFamily: FontFamily.bungee,
          color: (widget.condition > 0) ? AppColors.red : null,
        ),
      ),
    );
  }

  void _showTooltip() {
    if (_overlayEntry != null) return; // Evita múltiplos tooltips

    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx, // Centraliza horizontalmente
        top: offset.dy + renderBox.size.height + 8, // Abaixo do widget alvo
        child: Material(
          color: Colors.transparent,
          child: ConditionTooltip(condition: widget.condition),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class ConditionTooltip extends StatelessWidget {
  final int condition;
  const ConditionTooltip({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            getConditionName(condition),
            style: TextStyle(
              color: Colors.white,
              fontFamily: FontFamily.bungee,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextMarkdown(
            getConditionDescription(condition),
            regularStyle: TextStyle(
              fontFamily: "SourceSerif4",
              color: Colors.white,
            ),
            boldStyle: TextStyle(fontFamily: "Bungee", color: AppColors.red),
          ),
        ],
      ),
    );
  }
}

String getConditionName(int condition) {
  switch (condition) {
    case 0:
      return "DESPERTO";
    case 1:
      return "VULNERÁVEL";
    case 2:
      return "INCAPAZ";
    case 3:
      return "MORRENDO";
    case 4:
      return "MORTE";
    default:
      return "DESPERTO";
  }
}

String getConditionDescription(int condition) {
  switch (condition) {
    case 0:
      return """O estado **Desperto**, é o padrão que você estará durante a maioria da aventura. Nele você consegue usar **Ações.** """;
    case 1:
      return """Algumas situações podem te colocar em um estado de **Vulnerável**. Seja perder um **Teste Resistido** de **Luta**, e ser ter alguma parte do corpo ferida; seja escorregar e perder o equilíbrio; seja por perder a visão em uma granada de fumaça. 

No estado **Vulnerável** você não pode executar ações exceto tentar se recuperar com um **Resistir (Fisiológico)** para voltar para o estado de Desperto ou tentar **Correr** para fugir se houver condições. Outro personagem pode também usar **Socorrer** para tentar te fazer voltar para o estado de Desperto.

Você ainda é capaz de se defender o suficiente para impedir a ação **Finalizar** do inimigo.""";
    case 2:
      return """Outras situações podem te colocar no estado de **Incapaz.** Perder um **Teste Resistido** de **Luta** já estando **Vulnerável,** se machucar gravemente, se afogar, entre outras situações.

Note que, por exemplo, uma pessoa lutadora bem treinada pode usar suas duas ações para, primeiro, te deixar “Vulnerável”, acertando um *jab* no seu nariz, e depois “Incapaz” com um cruzado no seu queixo.

No estado **Vulnerável** você não pode nem tentar se recuperar, nem fugir, está totalmente a mercê dos seus aliados, para usarem um **Socorrer** para te trazer de volta para **Incapaz**, ou de seus inimigos que podem usar **Finalizar** para lhe colocar na condição de **Morrendo** ou **Morte.**""";
    case 3:
      return """Já o estado **Morrendo** é muito similar ao **Incapaz,** exceto pelo fato de que algo está efetivamente te matando, muito provavelmente, de forma rápida. Seja uma facada ou um tiro, uma queda muito mal sucedida de um lugar muito alto e diversos outros casos. Quanto tempo você tem de vida, seja em turnos ou em tempo corrido, estará completamente a cargo da pessoa narradora, mas ela deverá usar a tabela no **Apêndice B3**, para basear suas decisões. Obviamente, uma (outra) ação **Finalizar** também poderá você.""";
    case 4:
      return """E bom… **Morte**, você morreu. :D """;
    default:
      return "DESPERTO";
  }
}
