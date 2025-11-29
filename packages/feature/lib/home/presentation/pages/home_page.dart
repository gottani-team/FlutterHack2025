import 'package:core/presentation/widgets/error_widget.dart';
import 'package:core/presentation/widgets/loading_widget.dart';
import 'package:feature/home/presentation/providers/home_providers.dart';
import 'package:feature/mining/presentation/state/mining_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: homeDataAsync.when(
        data: (data) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (data.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  data.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('haiku'),
                child: const Text('Go to Haiku Generator'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed(
                  'mining',
                  extra: {
                    'crystalId': 'test-crystal-001',
                    'crystalImageUrl': 'assets/images/test-crystal.png',
                    'memoryText':
                        'This is a test memory from the crystal. '
                        'The ancient voices whisper through time, '
                        'carrying stories of those who came before. '
                        'Feel the warmth of forgotten summers, '
                        'the gentle touch of memories preserved in stone.',
                    'glowColor': EmotionType.passion.color,
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmotionType.passion.color,
                ),
                child: const Text('Test Crystal Mining'),
              ),
            ],
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
      ),
    );
  }
}
