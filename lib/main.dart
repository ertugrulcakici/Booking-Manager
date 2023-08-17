import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:bookingmanager/firebase_options.dart';
import 'package:bookingmanager/product/constants/app_constants.dart';
import 'package:bookingmanager/product/providers/provider_manager.dart';
import 'package:bookingmanager/view/auth/splash/splash_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

Future<void> main() async {
  await initializeApp();
  runApp(EasyLocalization(
      supportedLocales: AppConstants.supportedLocales,
      path: AppConstants.pathLocale,
      saveLocale: true,
      fallbackLocale: AppConstants.fallBackLocale,
      useOnlyLangCode: true,
      child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      parent: ProviderManager.ref,
      child: MaterialApp(
        locale: context.locale,
        localizationsDelegates: [
          ...context.localizationDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          SfGlobalLocalizations.delegate,
        ],
        localeResolutionCallback:
            (Locale? locale, Iterable<Locale> supportedLocales) => locale,
        supportedLocales: context.supportedLocales,
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        title: "Booking Manager",
        themeMode: ThemeMode.system,
        theme: ThemeData(useMaterial3: true).copyWith(
          appBarTheme: AppBarTheme(
              titleTextStyle: Theme.of(context).textTheme.titleMedium),
        ),
        home: const SplashView(),
      ),
    );
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await EasyLocalization.ensureInitialized();
}
