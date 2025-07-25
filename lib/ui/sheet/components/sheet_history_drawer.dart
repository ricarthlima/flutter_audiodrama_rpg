import 'dart:math';

import 'package:flutter/material.dart';
import '../../../domain/models/roll_log.dart';
import '../widgets/roll_log_widget.dart';

import '../../_core/fonts.dart';

class SheetHistoryDrawer extends StatefulWidget {
  final List<RollLog> listRollLog;
  const SheetHistoryDrawer({super.key, required this.listRollLog});

  @override
  State<SheetHistoryDrawer> createState() => _SheetHistoryDrawerState();
}

class _SheetHistoryDrawerState extends State<SheetHistoryDrawer> {
  final ScrollController _scrollController = ScrollController();
  int itensPerPage = 25;
  int showingPages = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Histórico de Rolagem",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.bungee,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                      Visibility(
                        visible: widget.listRollLog.length >
                            showingPages * itensPerPage,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showingPages++;
                            });
                          },
                          child: Text("Carregar mais antigas"),
                        ),
                      ),
                      SizedBox(height: 16),
                    ] +
                    (widget.listRollLog
                        .sublist(max(
                            0,
                            widget.listRollLog.length -
                                (showingPages * itensPerPage)))
                        .map((rl) => RollLogWidget(rollLog: rl))
                        .toList() as List<Widget>),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
