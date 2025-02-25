import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/sheet_model.dart';
import '../../_core/helpers.dart';
import '../view/home_view_model.dart';

class HomeListItemWidget extends StatelessWidget {
  final String userId;
  final Sheet sheet;
  const HomeListItemWidget({
    super.key,
    required this.sheet,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    return ListTile(
      leading: Icon(
        Icons.feed,
        size: 48,
      ),
      title: Text(
        sheet.characterName,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: (userId == FirebaseAuth.instance.currentUser!.uid)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    viewModel.onDuplicateSheet(context: context, sheet: sheet);
                  },
                  iconSize: 32,
                  icon: Icon(Icons.copy),
                ),
                IconButton(
                  onPressed: () {
                    viewModel.onRemoveSheet(context: context, sheet: sheet);
                  },
                  iconSize: 32,
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.red,
                  ),
                ),
              ],
            )
          : null,
      subtitle: Text(getBaseLevel(sheet.baseLevel)),
      onTap: () {
        viewModel.goToSheet(
          context,
          sheet: sheet,
          userId: userId,
        );
      },
    );
  }
}
