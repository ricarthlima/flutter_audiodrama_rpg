import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../../_core/widgets/compactable_button.dart';
import '../view/home_view_model.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    return MouseRegion(
      onEnter: (_) => viewModel.isDrawerClosed = false,
      onExit: (_) => viewModel.isDrawerClosed = true,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 350),
        curve: Curves.ease,
        width: (viewModel.isDrawerClosed) ? 48 : 275,
        height: height(context),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 8,
              children: [
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: viewModel.isDrawerClosed,
                    isSelected: viewModel.currentPage == HomeSubPages.sheets,
                  ),
                  title: "Personagens",
                  leadingIcon: Icons.list_alt_sharp,
                  onPressed: () {
                    viewModel.currentPage = HomeSubPages.sheets;
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: viewModel.isDrawerClosed,
                    isSelected: viewModel.currentPage == HomeSubPages.worlds,
                  ),
                  title: "Campanhas",
                  leadingIcon: Icons.local_florist_outlined,
                  onPressed: () {
                    viewModel.currentPage = HomeSubPages.worlds;
                  },
                ),
              ],
            ),
            CompactableButton(
              controller: CompactableButtonController(
                isCompressed: viewModel.isDrawerClosed,
                isSelected: viewModel.currentPage == HomeSubPages.profile,
              ),
              leadingIcon: Icons.person_outline,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FirebaseAuth.instance.currentUser!.displayName!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              onPressed: () {
                viewModel.currentPage = HomeSubPages.profile;
              },
            )
          ],
        ),
      ),
    );
  }
}
