import 'package:flutter/material.dart';

import '../../models/action_template.dart';
import '../widgets/action_tooltip.dart';

Future<dynamic> showDialogTip(
  BuildContext context,
  ActionTemplate action,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: Colors.white,
            ),
          ),
          child: ActionTooltip(action: action),
        ),
      );
    },
  );
}
