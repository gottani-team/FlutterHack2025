// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crystal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that fetches crystal data by ID
/// Currently returns mock data, will be replaced with real API call later

@ProviderFor(crystal)
const crystalProvider = CrystalFamily._();

/// Provider that fetches crystal data by ID
/// Currently returns mock data, will be replaced with real API call later

final class CrystalProvider extends $FunctionalProvider<
        AsyncValue<MemoryCrystal>, MemoryCrystal, FutureOr<MemoryCrystal>>
    with $FutureModifier<MemoryCrystal>, $FutureProvider<MemoryCrystal> {
  /// Provider that fetches crystal data by ID
  /// Currently returns mock data, will be replaced with real API call later
  const CrystalProvider._(
      {required CrystalFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'crystalProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crystalHash();

  @override
  String toString() {
    return r'crystalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemoryCrystal> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MemoryCrystal> create(Ref ref) {
    final argument = this.argument as String;
    return crystal(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrystalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crystalHash() => r'6eab6db7f38e8d513006f9c75deb2b79b8180a64';

/// Provider that fetches crystal data by ID
/// Currently returns mock data, will be replaced with real API call later

final class CrystalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemoryCrystal>, String> {
  const CrystalFamily._()
      : super(
          retry: null,
          name: r'crystalProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider that fetches crystal data by ID
  /// Currently returns mock data, will be replaced with real API call later

  CrystalProvider call(
    String crystalId,
  ) =>
      CrystalProvider._(argument: crystalId, from: this);

  @override
  String toString() => r'crystalProvider';
}
