import 'package:feature/crystal/presentation/pages/crystal_display_page.dart';
import 'package:feature/crystal/presentation/pages/crystal_list_page.dart';
import 'package:feature/haiku/presentation/pages/haiku_page.dart';
import 'package:feature/home/presentation/pages/home_page.dart';
import 'package:feature/map/presentation/pages/map_page.dart';
import 'package:feature/memory_burial/presentation/pages/memory_burial_page.dart';
import 'package:feature/repository_test/presentation/pages/repository_test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/map', // Start with map for Chimyaku MVP
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
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: '/crystals',
        name: 'crystal-list',
        builder: (context, state) => const CrystalListPage(),
      ),
      GoRoute(
        path: '/repository-test',
        name: 'repository-test',
        builder: (context, state) => const RepositoryTestPage(),
      ),
      GoRoute(
        path: '/memory-burial',
        name: 'memory-burial',
        builder: (context, state) => const MemoryBurialPage(),
      ),
      // GoRoute(
      //   path: '/mining',
      //   name: 'mining',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //     return MiningPage(
      //       crystalId: extra?['crystalId'] ?? '',
      //       crystalImageUrl: extra?['crystalImageUrl'] ?? '',
      //       crystalLabel: extra?['crystalLabel'] ?? '',
      //       memoryText: extra?['memoryText'] ?? '',
      //       glowColor: extra?['glowColor'] as Color?,
      //       onComplete:
      //           extra?['onComplete'] as Future<void> Function(MiningResult)?,
      //     );
      //   },
      // ),
      GoRoute(
        path: '/crystal/:id',
        name: 'crystal-display',
        builder: (context, state) {
          final crystalId = state.pathParameters['id'] ?? '';
          return CrystalDisplayPage(crystalId: crystalId);
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
