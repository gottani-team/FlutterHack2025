// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haiku_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(generateHaikuStream)
const generateHaikuStreamProvider = GenerateHaikuStreamFamily._();

final class GenerateHaikuStreamProvider extends $FunctionalProvider<
        AsyncValue<HaikuModel>, HaikuModel, Stream<HaikuModel>>
    with $FutureModifier<HaikuModel>, $StreamProvider<HaikuModel> {
  const GenerateHaikuStreamProvider._(
      {required GenerateHaikuStreamFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'generateHaikuStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$generateHaikuStreamHash();

  @override
  String toString() {
    return r'generateHaikuStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<HaikuModel> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<HaikuModel> create(Ref ref) {
    final argument = this.argument as String;
    return generateHaikuStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GenerateHaikuStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$generateHaikuStreamHash() =>
    r'8d2d8affdb069de51bb1c87d6068e101a6014edb';

final class GenerateHaikuStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<HaikuModel>, String> {
  const GenerateHaikuStreamFamily._()
      : super(
          retry: null,
          name: r'generateHaikuStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GenerateHaikuStreamProvider call(
    String theme,
  ) =>
      GenerateHaikuStreamProvider._(argument: theme, from: this);

  @override
  String toString() => r'generateHaikuStreamProvider';
}

@ProviderFor(getHeaderImageUrl)
const getHeaderImageUrlProvider = GetHeaderImageUrlProvider._();

final class GetHeaderImageUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const GetHeaderImageUrlProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getHeaderImageUrlProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getHeaderImageUrlHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return getHeaderImageUrl(ref);
  }
}

String _$getHeaderImageUrlHash() => r'de69592283b163fe050f868cad341b9ca77b9395';
