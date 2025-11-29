import 'package:feature/haiku/data/models/haiku_model.dart';

abstract class HaikuRepository {
  Stream<HaikuModel> generateHaiku(String theme);
  Future<String> loadImageUrl();
}
