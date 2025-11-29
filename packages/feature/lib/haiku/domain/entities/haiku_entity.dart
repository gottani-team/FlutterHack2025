import 'package:equatable/equatable.dart';

class HaikuEntity extends Equatable {
  final String id;
  final String theme;
  final String content;
  final DateTime createdAt;

  const HaikuEntity({
    required this.id,
    required this.theme,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, theme, content, createdAt];
}

