// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$artistControllerHash() => r'a53dc5f643d353f16ee0fa473b3e59fc9ae07e7d';

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

/// See also [artistController].
@ProviderFor(artistController)
const artistControllerProvider = ArtistControllerFamily();

/// See also [artistController].
class ArtistControllerFamily extends Family<AsyncValue<ArtistData>> {
  /// See also [artistController].
  const ArtistControllerFamily();

  /// See also [artistController].
  ArtistControllerProvider call(
    String videoId,
  ) {
    return ArtistControllerProvider(
      videoId,
    );
  }

  @override
  ArtistControllerProvider getProviderOverride(
    covariant ArtistControllerProvider provider,
  ) {
    return call(
      provider.videoId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'artistControllerProvider';
}

/// See also [artistController].
class ArtistControllerProvider extends AutoDisposeFutureProvider<ArtistData> {
  /// See also [artistController].
  ArtistControllerProvider(
    String videoId,
  ) : this._internal(
          (ref) => artistController(
            ref as ArtistControllerRef,
            videoId,
          ),
          from: artistControllerProvider,
          name: r'artistControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$artistControllerHash,
          dependencies: ArtistControllerFamily._dependencies,
          allTransitiveDependencies:
              ArtistControllerFamily._allTransitiveDependencies,
          videoId: videoId,
        );

  ArtistControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
  }) : super.internal();

  final String videoId;

  @override
  Override overrideWith(
    FutureOr<ArtistData> Function(ArtistControllerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArtistControllerProvider._internal(
        (ref) => create(ref as ArtistControllerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoId: videoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ArtistData> createElement() {
    return _ArtistControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArtistControllerProvider && other.videoId == videoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ArtistControllerRef on AutoDisposeFutureProviderRef<ArtistData> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _ArtistControllerProviderElement
    extends AutoDisposeFutureProviderElement<ArtistData>
    with ArtistControllerRef {
  _ArtistControllerProviderElement(super.provider);

  @override
  String get videoId => (origin as ArtistControllerProvider).videoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
