// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$genreControllerHash() => r'7fbb571375050bbd4f0548796d664efa337146e5';

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

abstract class _$GenreController
    extends BuildlessAsyncNotifier<List<MusicModel>> {
  late final String genre;

  FutureOr<List<MusicModel>> build(
    String genre,
  );
}

/// See also [GenreController].
@ProviderFor(GenreController)
const genreControllerProvider = GenreControllerFamily();

/// See also [GenreController].
class GenreControllerFamily extends Family<AsyncValue<List<MusicModel>>> {
  /// See also [GenreController].
  const GenreControllerFamily();

  /// See also [GenreController].
  GenreControllerProvider call(
    String genre,
  ) {
    return GenreControllerProvider(
      genre,
    );
  }

  @override
  GenreControllerProvider getProviderOverride(
    covariant GenreControllerProvider provider,
  ) {
    return call(
      provider.genre,
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
  String? get name => r'genreControllerProvider';
}

/// See also [GenreController].
class GenreControllerProvider
    extends AsyncNotifierProviderImpl<GenreController, List<MusicModel>> {
  /// See also [GenreController].
  GenreControllerProvider(
    String genre,
  ) : this._internal(
          () => GenreController()..genre = genre,
          from: genreControllerProvider,
          name: r'genreControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$genreControllerHash,
          dependencies: GenreControllerFamily._dependencies,
          allTransitiveDependencies:
              GenreControllerFamily._allTransitiveDependencies,
          genre: genre,
        );

  GenreControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.genre,
  }) : super.internal();

  final String genre;

  @override
  FutureOr<List<MusicModel>> runNotifierBuild(
    covariant GenreController notifier,
  ) {
    return notifier.build(
      genre,
    );
  }

  @override
  Override overrideWith(GenreController Function() create) {
    return ProviderOverride(
      origin: this,
      override: GenreControllerProvider._internal(
        () => create()..genre = genre,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        genre: genre,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<GenreController, List<MusicModel>>
      createElement() {
    return _GenreControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GenreControllerProvider && other.genre == genre;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, genre.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GenreControllerRef on AsyncNotifierProviderRef<List<MusicModel>> {
  /// The parameter `genre` of this provider.
  String get genre;
}

class _GenreControllerProviderElement
    extends AsyncNotifierProviderElement<GenreController, List<MusicModel>>
    with GenreControllerRef {
  _GenreControllerProviderElement(super.provider);

  @override
  String get genre => (origin as GenreControllerProvider).genre;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
