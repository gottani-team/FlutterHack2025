// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collected_crystals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that fetches collected crystals for the current user

@ProviderFor(collectedCrystals)
const collectedCrystalsProvider = CollectedCrystalsProvider._();

/// Provider that fetches collected crystals for the current user

final class CollectedCrystalsProvider extends $FunctionalProvider<
        AsyncValue<List<CollectedCrystal>>,
        List<CollectedCrystal>,
        FutureOr<List<CollectedCrystal>>>
    with
        $FutureModifier<List<CollectedCrystal>>,
        $FutureProvider<List<CollectedCrystal>> {
  /// Provider that fetches collected crystals for the current user
  const CollectedCrystalsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'collectedCrystalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$collectedCrystalsHash();

  @$internal
  @override
  $FutureProviderElement<List<CollectedCrystal>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CollectedCrystal>> create(Ref ref) {
    return collectedCrystals(ref);
  }
}

String _$collectedCrystalsHash() => r'48d60af09f7ed96245311f48777210d7fb9bcaf6';
