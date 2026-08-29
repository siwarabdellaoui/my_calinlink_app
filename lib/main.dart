
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'shared/providers/theme_provider.dart';
import 'services/socket_service.dart';


Future<void> main() async {
  // Initialisation Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des intercepteurs API
  ApiClient.initializeInterceptors();

  // Orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Configuration de la barre système
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Création du container de providers Riverpod
  final container = ProviderContainer();

  // Connexion Socket.IO
  final socketService = SocketService();
  socketService.connect(container);

  // Lancement de l'application
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CalinLinkApp(),
    ),
  );
}


// =========================================================
// APPLICATION PRINCIPALE
// =========================================================

class CalinLinkApp extends ConsumerWidget {
  const CalinLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router
    final router = ref.watch(routerProvider);

    // Thème
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'CâlinLink',

      // Thème clair
      theme: AppTheme.lightTheme,

      // Thème sombre
      darkTheme: AppTheme.darkTheme,

      // Thème actuellement sélectionné
      themeMode: themeState.currentEffectiveTheme,

      // Router de l'application
      routerConfig: router,

      // Désactiver le bandeau DEBUG
      debugShowCheckedModeBanner: false,
    );
  }
}

