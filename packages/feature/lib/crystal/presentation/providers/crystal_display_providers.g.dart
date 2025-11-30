// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crystal_display_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the crystal display UI state using Riverpod 3.0 Notifier

@ProviderFor(CrystalDisplayNotifier)
const crystalDisplayProvider = CrystalDisplayNotifierProvider._();

/// Provider for the crystal display UI state using Riverpod 3.0 Notifier
final class CrystalDisplayNotifierProvider
    extends $NotifierProvider<CrystalDisplayNotifier, CrystalDisplayUIState> {
  /// Provider for the crystal display UI state using Riverpod 3.0 Notifier
  const CrystalDisplayNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crystalDisplayProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crystalDisplayNotifierHash();

  @$internal
  @override
  CrystalDisplayNotifier create() => CrystalDisplayNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrystalDisplayUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrystalDisplayUIState>(value),
    );
  }
}

String _$crystalDisplayNotifierHash() =>
    r'f44cae5a258b11467490933da50ccf307580bfdd';

/// Provider for the crystal display UI state using Riverpod 3.0 Notifier

abstract class _$CrystalDisplayNotifier
    extends $Notifier<CrystalDisplayUIState> {
  CrystalDisplayUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CrystalDisplayUIState, CrystalDisplayUIState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CrystalDisplayUIState, CrystalDisplayUIState>,
        CrystalDisplayUIState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
