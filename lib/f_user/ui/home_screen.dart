import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';

import '../../_core/fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AUDIODRAMA RPG",
          style: TextStyle(
            fontFamily: Fonts.bungee,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then(
                (value) {
                  if (!context.mounted) return;
                  GoRouter.of(context).go(AppRouter.auth);
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
