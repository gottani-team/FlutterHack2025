import 'package:core/presentation/widgets/error_widget.dart';
import 'package:core/presentation/widgets/loading_widget.dart';
import 'package:feature/home/presentation/providers/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
