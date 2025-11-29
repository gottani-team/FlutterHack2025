import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature/haiku/presentation/providers/haiku_providers.dart';
import 'package:feature/haiku/presentation/widgets/triangle_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class HaikuPage extends HookConsumerWidget {
  const HaikuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = useTextEditingController();
    final theme = useState<String?>(null);
    final haikuStream =
        ref.watch(generateHaikuStreamProvider(theme.value ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('松尾芭蕉'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              imageUrl: ref.watch(getHeaderImageUrlProvider).value ?? '',
              height: 200,
              width: 200,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const SizedBox(
                  height: 200,
                  width: 200,
                ),
              ),
              errorWidget: (context, url, error) => const SizedBox(
                height: 200,
                width: 200,
                child: Icon(Icons.error),
              ),
            ),
            const Gap(8),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    CustomPaint(
                      size: const Size(20, 20),
                      painter: TrianglePainter(color: Colors.white),
                    ),
                    Flexible(
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            haikuStream.value?.content ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            TextField(
              controller: themeController,
              decoration: const InputDecoration(
                labelText: '季語を入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                if (themeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('季語を入力してください'),
                    ),
                  );
                  return;
                }
                FocusScope.of(context).unfocus();
                theme.value = themeController.text;
              },
              child: const Text('詠む'),
            ),
          ],
        ),
      ),
    );
  }
}
