import 'package:core/core.dart';
import 'package:core/presentation/theme/app_theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseAppCheck.instance.activate(
      // ignore: deprecated_member_use
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      // ignore: deprecated_member_use
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttestWithDeviceCheckFallback,
    );
  } catch (e) {
    debugPrint('App Check initialization failed: $e');
  }

  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval:
          kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
    ));
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    debugPrint('Remote Config initialization failed: $e');
  }

  // Create a container to access providers before ProviderScope
  final container = ProviderContainer();

  // Perform anonymous sign in
  await _ensureAuthenticated(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

/// Ensure the user is authenticated (sign in anonymously if needed)
Future<void> _ensureAuthenticated(ProviderContainer container) async {
  final authRepository = container.read(authRepositoryProvider);

  // Check if user is already signed in
  final currentSession = await authRepository.getCurrentSession();

  switch (currentSession) {
    case Success():
      debugPrint('User already signed in');
      return;
    case Failure():
      // Not signed in, perform anonymous sign in
      final result = await authRepository.signInAnonymously();
      switch (result) {
        case Success(value: final session):
          debugPrint('Anonymous sign in successful: ${session.id}');
        case Failure(error: final failure):
          debugPrint('Anonymous sign in failed: $failure');
      }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'App Template',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
