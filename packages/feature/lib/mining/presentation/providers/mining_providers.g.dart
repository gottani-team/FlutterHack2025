// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mining_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the mining UI state using Riverpod 3.0 Notifier

@ProviderFor(MiningNotifier)
const miningProvider = MiningNotifierProvider._();

/// Provider for the mining UI state using Riverpod 3.0 Notifier
final class MiningNotifierProvider
    extends $NotifierProvider<MiningNotifier, MiningUIState> {
  /// Provider for the mining UI state using Riverpod 3.0 Notifier
  const MiningNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'miningProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$miningNotifierHash();

  @$internal
  @override
  MiningNotifier create() => MiningNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MiningUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MiningUIState>(value),
    );
  }
}

String _$miningNotifierHash() => r'7eb9036ac9805cfdc0a0d7972da6bd027387c393';

/// Provider for the mining UI state using Riverpod 3.0 Notifier

abstract class _$MiningNotifier extends $Notifier<MiningUIState> {
  MiningUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MiningUIState, MiningUIState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MiningUIState, MiningUIState>,
        MiningUIState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
