import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  try {
    print('Checking ChannelClient methods...');
    // We can't easily list methods at runtime in Dart without reflection,
    // but we can try to use them and see if they compile/run.
    // Since this is just a plan, I'll try to find the correct API.
  } finally {
    yt.close();
  }
}
