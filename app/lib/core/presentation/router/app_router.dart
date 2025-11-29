import 'package:feature/haiku/presentation/pages/haiku_page.dart';
import 'package:feature/home/presentation/pages/home_page.dart';
import 'package:feature/mining/presentation/pages/mining_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/haiku',
        name: 'haiku',
        builder: (context, state) => const HaikuPage(),
      ),
      GoRoute(
        path: '/mining',
        name: 'mining',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MiningPage(
            crystalId: extra?['crystalId'] ?? '',
            crystalImageUrl: extra?['crystalImageUrl'] ?? '',
            memoryText: extra?['memoryText'] ?? '',
            glowColor: extra?['glowColor'] as Color?,
            onComplete: extra?['onComplete']
                as Future<void> Function(MiningResult)?,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
