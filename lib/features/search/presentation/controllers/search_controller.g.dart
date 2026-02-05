// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$youtubeServiceHash() => r'8f7531361b6e655bf12adca594b5af5116a7ce2d';

/// See also [youtubeService].
@ProviderFor(youtubeService)
final youtubeServiceProvider = Provider<YoutubeService>.internal(
  youtubeService,
  name: r'youtubeServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$youtubeServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef YoutubeServiceRef = ProviderRef<YoutubeService>;
String _$searchControllerHash() => r'd7e87567f28ffb2ad0be923d4f94889e41c479b6';

/// See also [SearchController].
@ProviderFor(SearchController)
final searchControllerProvider =
    AutoDisposeAsyncNotifierProvider<SearchController, List<Video>>.internal(
  SearchController.new,
  name: r'searchControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchController = AutoDisposeAsyncNotifier<List<Video>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
