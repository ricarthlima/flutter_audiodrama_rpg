import 'package:flutter/material.dart';

import 'generic_header.dart';

/// Sempre colocar numa coluna!
class ExpansibleList extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool startClosed;
  const ExpansibleList({
    super.key,
    required this.title,
    this.actions,
    required this.child,
    this.startClosed = false,
  });

  @override
  State<ExpansibleList> createState() => _ExpansibleListState();
}

class _ExpansibleListState extends State<ExpansibleList> {
  bool isExpanded = true;

  @override
  void initState() {
    isExpanded = !widget.startClosed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GenericHeader(
            title: widget.title,
            actions: _generateActions,
            dense: true,
          ),
          if (isExpanded)
            Flexible(child: SingleChildScrollView(child: widget.child)),
        ],
      ),
    );
  }

  List<Widget>? get _generateActions {
    List<Widget> result = [];
    if (widget.actions != null) {
      result.addAll(widget.actions!);
    }
    result.add(
      IconButton(
        onPressed: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
      ),
    );

    return result;
  }
}
