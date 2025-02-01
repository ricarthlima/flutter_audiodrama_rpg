import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_template.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/ui/sheet_screen.dart';

import 'package:flutter_rpg_audiodrama/firebase_options.dart';
import 'package:provider/provider.dart';

import '_core/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SheetTemplate.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: SheetScreen(
        sheet: SheetModel(
          characterName: "Angus Silvana",
          listActionValue: [
            ActionValue(
              actionId: "827ede50-5b3f-4aea-9d43-b43a6762520a",
              value: 3,
            ),
          ],
        ),
      ),
    );
  }
}
