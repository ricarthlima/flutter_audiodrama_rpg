import 'package:flutter/material.dart';

import '../../../domain/models/action_template.dart';
import '../widgets/action_tooltip.dart';

class RollTipStackDialog extends StatelessWidget {
  final ActionTemplate action;
  final bool isEffortUsed;
  const RollTipStackDialog({
    super.key,
    required this.action,
    this.isEffortUsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
          width: 4,
          color: Colors.white,
        ),
      ),
      child: ActionTooltip(
        action: action,
        isEffortUsed: isEffortUsed,
      ),
    );
  }
}
