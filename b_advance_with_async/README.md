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
    // await Future.delayed(const Duration(seconds: 2));
    // return "Hello! U F Jillani";
    //--------------------------------------------
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
        // loading: () => const CircularProgressIndicator(),
        error: (e, st) => Text("Error: $e"),
        );
    }
    }
    ```
## `AsyncNotifier` and `AsyncNotifierProvider`
- A logic class you create that manages `asynchronous` state.
    - It always exposes state as AsyncValue<T> (Riverpod’s wrapper for loading, data, error).
    - You implement a build() method to fetch the initial async value.
    - You can add your own methods (refresh, update, retry, etc.) to handle more logic.
    - It replaces the old `StateNotifier<AsyncValue<T>>` boilerplate.
- The provider that creates your `AsyncNotifier`.
    - It exposes an AsyncValue<T> to your widgets.
    - Comes in flavors:
        - `AsyncNotifierProvider` → persistent
        - `AsyncNotifierProvider.autoDispose` → freed when not in use
        - `AsyncNotifierProvider.family` → parameterized by arguments (e.g., userId)
### Why use it?
- Automatically handles loading/error states (through AsyncValue<T>).
- Keeps API logic out of the UI (clean architecture).
- Recomputes automatically when dependencies (ref.watch) change.
- Perfect for real-world APIs, database queries, search, authentication.

## `FutureProvider` vs. `AsyncNotifier`
- `FutureProvider` → One async fetch, UI handles result.
- `AsyncNotifier` → Async fetch + more logic (refresh, retry, update), all in one class.

## What is Consumer?
- Consumer lets you read/watch providers inside a small part of your tree, so only that part rebuilds when the provider changes.
- `ref.watch(provider.select((s) => s.field))` → rebuild only when that field changes.
## `Scoped providers` in Riverpod v2 = overrides with `ProviderScope`
- In Riverpod, scoping means creating a subtree where a provider has a different implementation/value than the rest of the app. You do this with ProviderScope(overrides: [...]).
- overrides: [...] Override providers for a subtree ProviderScope constructor
## `autoDispose` 
- When no one is listening to that provider anymore (no widgets watch it, and no other providers depend on it), Riverpod automatically disposes the provider and frees its resources.
- Stop memory leaks (players, streams, controllers).
- Stop background CPU/battery drain (position timers, buffers).
- Free file handles/decoders and network connections when user leaves the screen.
- **Fresh start** when returning to a screen.
- If you come back later, Riverpod recreates the provider (re-runs its creation/build logic).<br>
**You can add it to any provider type:**
```dart
    StateProvider.autoDispose<T>(...)
    Provider.autoDispose<T>(...)
    FutureProvider.autoDispose<T>(...)
    StreamProvider.autoDispose<T>(...)
    StateNotifierProvider.autoDispose<Notifier, T>(...)
    NotifierProvider.autoDispose<Notifier, T>(...)
    AsyncNotifierProvider.autoDispose<Notifier, T>(...)
```
**Handy lifecycle hooks inside an autoDispose provider:**
```dart
    ref.onDispose(() { /* cleanup */ });
    ref.onCancel(() { /* lost last listener but not disposed yet */ });
    ref.onResume(() { /* got a listener again */ });
```
**And you can delay disposal if you want:**
```dart
    final link = ref.keepAlive();        // keep it alive temporarily
    Future.delayed(const Duration(seconds: 30), link.close);
```
## `.family` (Parameterized Providers)
- .family allows you to pass parameters into a provider like:
    - an ID 
    - index or type
    - create multiple independent provider instances of the same logic
```dart
final userProvider = FutureProvider.family<String, int>((ref, userId) async {
  await Future.delayed(const Duration(seconds: 1));
  return "User #$userId";
});
//-----------------------
ref.watch(userProvider(1)); // → “User #1”
ref.watch(userProvider(2)); // → “User #2”
```
- When each instance goes unused → Riverpod disposes it.<br>
**Combine with `.family` + `.autoDispose`:**
```dart
final audioPlayerProvider =
  Provider.autoDispose.family<AudioPlayer, String>((ref, letter) {
    final player = AudioPlayer();
    ref.onDispose(player.dispose);
    return player;
  })
```
## `onCancel`, `onDispose`, `onResume` (Lifecycle callbacks)
### `ref.onCancel()`<br>
**When it runs**
- The last listener unsubscribed (widget left the screen). The provider might still be kept alive.<br>
**Example use**<br>
- Pause a stream / stop audio
### `ref.onDispose()`<br>
**When it runs**
- Provider is completely destroyed (removed from memory).<br>
**Example use**<br>
- Dispose controller / free memory
###  `ref.onResume()`<br>
**When it runs**
- A listener subscribed again after onCancel.<br>
**Example use**<br>
- Resume paused audio / reconnect stream
## `keepAlive()` (Prevent disposal temporarily)
- Used inside an autoDispose provider when you want to keep it alive for a bit longer (e.g., user might return soon).
- Use this when:
    - user flips alphabet pages fast (A → B → A)
    - network buffers/audio setup expensive
    - You can **cache** it for a few seconds for smoother UX.
```dart
final alphabetAudioProvider =
  Provider.autoDispose.family<AudioPlayer, String>((ref, letter) {
    final link = ref.keepAlive(); // 🧠 Prevent autoDispose for a while
    final player = AudioPlayer();

    ref.onDispose(() {
      player.dispose();
      debugPrint('Disposed $letter');
    });

    // keep for 10 seconds even after user leaves
    Future.delayed(const Duration(seconds: 10), () {
      link.close();
    });

    return player;
  });
```
## `mounted` (Is this provider still alive?)
- Inside async methods of Notifier or AsyncNotifier, check if the provider is still active before updating state.
- **Stop errors like:**
    - Tried to update state after provider was disposed.
- If user navigates away before `fetchStoriesFromApi()` finishes, `mounted` becomes false → no error, no memory leak.
- **mounted = true → widget is alive on the screen**
- **mounted = false → widget is removed, destroyed, no longer valid**
```dart
class StoryNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return [];
  }

  Future<void> loadStories() async {
    state = const AsyncLoading();
    final result = await fetchStoriesFromApi();

    if (!mounted) return; // ✅ Skip if provider is gone
    state = AsyncData(result);
  }
}
```
## Example: `A–Z Audio Learning Screen`
- Each tile (A single row/item in a list) = separate instance (family)
- Auto-disposed when unused (autoDispose)
- Pauses/stops properly (onCancel, onDispose)
- Cached briefly (keepAlive)
- Safe async updates (mounted inside Notifier)
## Why do we need to check mounted?
- Because async functions (await) take time.
- During that time, the screen may change, and your widget may be disposed.
- When the widget is removed → using:
    - ref.read(...)
    - setState(...)
    - context.go(...)
    - ScaffoldMessenger.of(context)
    - ANYTHING using context or ref
- will cause CRASH:
```dart
Bad state: Using "ref" when widget is unmounted is unsafe.
```
