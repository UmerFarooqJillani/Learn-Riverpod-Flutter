# <p align="center">b_advance_with_async</p>

<div align="center"><b>Async</b> state in Riverpod, which is super common in real-world apps (API calls, file IO, DB queries, Firebase, etc.)</div>

## FutureProvider (for one-time async values)
- Wraps a Future<T> inside a provider.
- Emits an AsyncValue<T> (so you handle .loading, .data, .error).
- One-time fetch (app version, initial data, file read).
- Lifecycle: Finishes after result.
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:package_info_plus/package_info_plus.dart';

    // Provider that fetches app version once
    final appVersionProvider = FutureProvider<String>((ref) async {
    final info = await PackageInfo.fromPlatform();
    return info.version; // e.g. "1.0.3"
    });
    ```
## StreamProvider (for live data streams)
- Wraps a Stream<T> inside a provider.
- Also emits an AsyncValue<T>, but updates every time the stream pushes new data.
- Best for real-time Continuous updates/values: audio playback position, Firebase snapshots, sockets, sensors.
- Lifecycle: Keeps listening until disposed
    ```dart
    import 'package:just_audio/just_audio.dart';

    final audioPlayerProvider = Provider<AudioPlayer>((ref) {
    final player = AudioPlayer();
    ref.onDispose(() => player.dispose());
    return player;
    });

    // Provide current playback position as a stream
    final positionProvider = StreamProvider<Duration>((ref) {
    final player = ref.watch(audioPlayerProvider);
    return player.positionStream;
    });
    //--------------------------------------------------------
    class PositionText extends ConsumerWidget {
    const PositionText({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final asyncPos = ref.watch(positionProvider);

        return asyncPos.when(
        data: (pos) => Text("Position: ${pos.inSeconds}s"),
        loading: () => const Text("Loading..."),
        error: (e, st) => Text("Error: $e"),
        );
    }
    }
    ```

