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
                    'crystalLabel': '豊かの欠片',
                    'memoryText': '先日、カフェ・ド・ミエルで友人のアキと待ち合わせ。'
                        '新作のローズティーは、一口飲むとバラ園にいるような香りが広がり、'
                        '心まで華やぎました。隣の席のカップルが話す映画論も、'
                        '思わず聞き入ってしまうほど魅力的。'
                        '日常がこんなにも豊かになるなんて、小さな発見に感謝です。',
                    'glowColor': EmotionType.passion.color,
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmotionType.passion.color,
                ),
                child: const Text('Test Crystal Mining'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/crystal/VHcT1phkkO44FoARv6f3'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                ),
                child: const Text('Test Crystal Display'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed('repository-test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Repository Test Screen'),
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
