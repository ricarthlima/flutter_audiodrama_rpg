import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rpg_audiodrama/_core/helpers/print.dart';
import 'package:flutter_rpg_audiodrama/data/repositories/spell_repository.dart';
import 'package:flutter_rpg_audiodrama/data/repositories_remote/action_repository_remote.dart';
import 'package:flutter_rpg_audiodrama/data/repositories_remote/item_repository_remote.dart';
import 'package:flutter_rpg_audiodrama/data/repositories_remote/spell_repository_remote.dart';

import '_core/url_strategy/url_strategy.dart';
import 'data/repositories/action_repository.dart';
import 'data/repositories/item_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '_core/providers/audio_provider.dart';
import '_core/providers/user_provider.dart';
import 'router.dart';
import 'ui/_core/theme.dart';
import 'ui/campaign/view/campaign_view_model.dart';
import 'ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'ui/home/view/home_view_model.dart';
import 'ui/settings/view/settings_provider.dart';
import 'ui/sheet/providers/sheet_view_model.dart';
import 'ui/sheet_shopping/view/shopping_view_model.dart';
import 'ui/sheet_statistics/view/statistics_view_model.dart';

import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');

FirebaseOptions get currentPlatform => flavor == 'dev'
    ? dev.DefaultFirebaseOptions.currentPlatform
    : prod.DefaultFirebaseOptions.currentPlatform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  printD(flavor);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await FullScreen.ensureInitialized();

  configureUrlStrategy();

  await Firebase.initializeApp(options: currentPlatform);

  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY"),
  );

  ActionRepository actionRepo = ActionRepositoryRemote();
  await actionRepo.onInitialize();

  ItemRepository itemRepo = ItemRepositoryRemote();
  await itemRepo.onInitialize();

  // TODO: Se convir, pegar a Condição vinda do JSON
  // ConditionRepository conditionRepo = ConditionRepositoryRemote();
  // await conditionRepo.onInitialize();

  SpellRepository spellRepository = SpellRepositoryRemote();
  await spellRepository.onInitialize();

  SettingsProvider settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  AudioProvider audioProvider = AudioProvider();
  await audioProvider.onInitialize();

  HomeViewModel homeVM = HomeViewModel();
  SheetViewModel sheetVM = SheetViewModel(
    id: "",
    username: "",
    actionRepo: actionRepo,
    // conditionRepo: conditionRepo,
  );
  ShoppingViewModel shoppingVM = ShoppingViewModel(
    sheetVM: sheetVM,
    itemRepo: itemRepo,
  );
  StatisticsViewModel statisticsVM = StatisticsViewModel();
  CampaignViewModel campaignVM = CampaignViewModel();
  CampaignVisualNovelViewModel campaignVisualVM = CampaignVisualNovelViewModel(
    campaignId: "",
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => homeVM),
        ChangeNotifierProvider(create: (_) => sheetVM),
        ChangeNotifierProvider(create: (_) => shoppingVM),
        ChangeNotifierProvider(create: (_) => statisticsVM),
        ChangeNotifierProvider(create: (_) => campaignVM),
        ChangeNotifierProvider(create: (_) => campaignVisualVM),
        ChangeNotifierProvider(create: (_) => audioProvider),
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
      scrollBehavior: const _WebScrollBehavior(),
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

class _WebScrollBehavior extends MaterialScrollBehavior {
  const _WebScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
