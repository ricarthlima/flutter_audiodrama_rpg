import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/condition_dao.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/theme.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';

import 'package:flutter_rpg_audiodrama/firebase_options.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/view/statistics_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ui/settings/view/settings_provider.dart';
import 'data/daos/item_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "dotenv");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: dotenv.env["SUPABASE_URL"]!,
    anonKey: dotenv.env["SUPABASE_ANON_KEY"]!,
  );

  await ActionDAO.instance.initialize();
  await ItemDAO.instance.initialize();
  await ConditionDAO.instance.initialize();

  SettingsProvider themeProvider = SettingsProvider();
  await themeProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => HomeSheetViewModel()),
        ChangeNotifierProvider(create: (_) => SheetViewModel(id: "")),
        ChangeNotifierProvider(create: (_) => ShoppingViewModel()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      supportedLocales: [
        Locale('pt', 'BR'), // Adiciona suporte ao português do Brasil
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Suporte para iOS também
      ],
    );
  }
}
