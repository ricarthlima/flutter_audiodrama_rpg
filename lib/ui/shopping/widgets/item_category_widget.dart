import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/utils/i18n_categories.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:provider/provider.dart';

class ItemCategoryWidget extends StatelessWidget {
  final String category;
  final bool isActive;
  final bool isSeller;
  const ItemCategoryWidget({
    super.key,
    required this.category,
    required this.isActive,
    required this.isSeller,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isSeller) {
          context.read<ShoppingViewModel>().toggleCategory(category, true);
        } else {
          context.read<ShoppingViewModel>().toggleCategory(category, false);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        margin: EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: (isActive) ? AppColors.red : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(i18nCategories(category)),
      ),
    );
  }
}
