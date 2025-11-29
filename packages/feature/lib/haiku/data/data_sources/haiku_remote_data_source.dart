import 'dart:convert';

import 'package:core/data/data_sources/remote_data_source.dart';
import 'package:core/data/utils/logger.dart';
import 'package:feature/haiku/data/models/haiku_model.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mustache_template/mustache.dart';
// import 'package:firebase_ai/firebase_ai.dart'; // Assuming this is the package

abstract class HaikuRemoteDataSource {
  Stream<HaikuModel> generateHaiku(String theme);
  Future<String> loadImageUrl();
}

class HaikuRemoteDataSourceImpl implements HaikuRemoteDataSource {
  // ignore: unused_field
  final RemoteDataSource _remoteDataSource;

  HaikuRemoteDataSourceImpl(this._remoteDataSource);

  @override
  Stream<HaikuModel> generateHaiku(String theme) async* {
    final remoteConfig = FirebaseRemoteConfig.instance;

    final modelsMap = json.decode(remoteConfig.getString('models')) ?? {};
    if (modelsMap.isEmpty) {
      appLogger.w('Models are not set');
    }
    final modelName = modelsMap['generateHaiku'] ?? 'gemini-2.5-flash';

    final systemPrompt = remoteConfig.getString('generateHaiku_system');
    if (systemPrompt.isEmpty) {
      appLogger.w('System prompt is not set');
    }

    final model = FirebaseAI.googleAI().generativeModel(model: modelName);

    final renderedPrompt =
        Template(systemPrompt).renderString({'theme': theme});

    final contentStream = model.generateContentStream([
      Content.text(
        renderedPrompt,
      ),
    ]);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final createdAt = DateTime.now();
    var accumulatedContent = '';

    await for (final response in contentStream) {
      final text = response.text;
      if (text != null) {
        accumulatedContent += text;
        yield HaikuModel(
          id: id,
          theme: theme,
          content: accumulatedContent,
          createdAt: createdAt,
        );
      }
    }
  }

  @override
  Future<String> loadImageUrl() async {
    final cloudStorage = FirebaseStorage.instance;

    final url = await cloudStorage.ref('img/basho.png').getDownloadURL();
    return url;
  }
}
