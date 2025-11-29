/// Core Package - Firebase Core Repository Layer
///
/// このパッケージはFeature層から使用されるドメインとデータ層を提供します。
/// Feature層はこのファイルからすべての必要な型とプロバイダーをインポートします。
///
/// **使用例**:
/// ```dart
/// import 'package:core/core.dart';
///
/// // Providerを使用
/// final authRepo = ref.watch(authRepositoryProvider);
/// final result = await authRepo.signInAnonymously();
/// ```
library;

// ========== Domain Layer ==========

// Common
export 'domain/common/result.dart';

// Entities
export 'domain/entities/ai_metadata.dart';
export 'domain/entities/collected_crystal.dart';
export 'domain/entities/crystal.dart';
export 'domain/entities/crystal_status.dart';
export 'domain/entities/emotion_type.dart';
export 'domain/entities/user.dart';
export 'domain/entities/user_session.dart';

// Failures
export 'domain/failures/core_failure.dart';

// Repositories
export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/crystal_repository.dart';
export 'domain/repositories/decipherment_repository.dart';
export 'domain/repositories/journal_repository.dart';
export 'domain/repositories/sublimation_repository.dart';
export 'domain/repositories/user_repository.dart';

// ========== Data Layer ==========

// Providers (Feature層はこれらを使用してリポジトリにアクセス)
export 'data/providers.dart';
