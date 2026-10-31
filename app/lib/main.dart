import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repository.dart';
import 'features/feed/feed_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseKey);
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const GeetaApp(),
  ));
}

class GeetaApp extends ConsumerStatefulWidget {
  const GeetaApp({super.key});
  @override
  ConsumerState<GeetaApp> createState() => _GeetaAppState();
}

class _GeetaAppState extends ConsumerState<GeetaApp> {
  late bool _onboarded = ref.read(prefsProvider).getBool('onboarded') ?? false;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'गीता',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(),
        themeMode: ThemeMode.dark,
        home: _onboarded
            ? const FeedScreen()
            : WelcomeScreen(onDone: () => setState(() => _onboarded = true)),
      );
}
