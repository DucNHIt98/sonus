// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chartControllerHash() => r'f8e2f22d7013ca12baf2c05924af8acf5d2a454e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChartController
    extends BuildlessAsyncNotifier<List<MusicModel>> {
  late final String region;
  late final String? playlistId;

  FutureOr<List<MusicModel>> build(String region, {String? playlistId});
}

/// See also [ChartController].
@ProviderFor(ChartController)
const chartControllerProvider = ChartControllerFamily();

/// See also [ChartController].
class ChartControllerFamily extends Family<AsyncValue<List<MusicModel>>> {
  /// See also [ChartController].
  const ChartControllerFamily();

  /// See also [ChartController].
  ChartControllerProvider call(String region, {String? playlistId}) {
    return ChartControllerProvider(region, playlistId: playlistId);
  }

  @override
  ChartControllerProvider getProviderOverride(
    covariant ChartControllerProvider provider,
  ) {
    return call(provider.region, playlistId: provider.playlistId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chartControllerProvider';
}

/// See also [ChartController].
class ChartControllerProvider
    extends AsyncNotifierProviderImpl<ChartController, List<MusicModel>> {
  /// See also [ChartController].
  ChartControllerProvider(String region, {String? playlistId})
    : this._internal(
        () => ChartController()
          ..region = region
          ..playlistId = playlistId,
        from: chartControllerProvider,
        name: r'chartControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chartControllerHash,
        dependencies: ChartControllerFamily._dependencies,
        allTransitiveDependencies:
            ChartControllerFamily._allTransitiveDependencies,
        region: region,
        playlistId: playlistId,
      );

  ChartControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.region,
    required this.playlistId,
  }) : super.internal();

  final String region;
  final String? playlistId;

  @override
  FutureOr<List<MusicModel>> runNotifierBuild(
    covariant ChartController notifier,
  ) {
    return notifier.build(region, playlistId: playlistId);
  }

  @override
  Override overrideWith(ChartController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChartControllerProvider._internal(
        () => create()
          ..region = region
          ..playlistId = playlistId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        region: region,
        playlistId: playlistId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<ChartController, List<MusicModel>>
  createElement() {
    return _ChartControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChartControllerProvider &&
        other.region == region &&
        other.playlistId == playlistId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, region.hashCode);
    hash = _SystemHash.combine(hash, playlistId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChartControllerRef on AsyncNotifierProviderRef<List<MusicModel>> {
  /// The parameter `region` of this provider.
  String get region;

  /// The parameter `playlistId` of this provider.
  String? get playlistId;
}

class _ChartControllerProviderElement
    extends AsyncNotifierProviderElement<ChartController, List<MusicModel>>
    with ChartControllerRef {
  _ChartControllerProviderElement(super.provider);

  @override
  String get region => (origin as ChartControllerProvider).region;
  @override
  String? get playlistId => (origin as ChartControllerProvider).playlistId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
