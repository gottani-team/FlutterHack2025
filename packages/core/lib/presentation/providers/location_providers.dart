import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';

/// LocationRepositoryのProvider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});
