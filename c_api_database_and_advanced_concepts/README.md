# <p align="center"> c_api_database_and_advanced_concepts </p>

## What is AsyncValue<T>?
- A tiny wrapper that represents one of three states:
    - AsyncLoading<T> → still loading
    - AsyncData<T> → data available
    - AsyncError<T> → failed (has error + stackTrace)
### Useful properties/methods:
1. Handle all states with `.when`
    - .when forces you to cover all states (loading/data/error) → fewer mistakes.
    ```dart
    final appVersionProvider = FutureProvider<String>((ref) async {
    // simulate network
    await Future.delayed(const Duration(milliseconds: 400));
    // throw Exception('Server down'); // uncomment to see error state
    return '1.0.3';
    });

    class VersionTile extends ConsumerWidget {
    const VersionTile({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final asyncVersion = ref.watch(appVersionProvider);

        return asyncVersion.when(
        data: (v) => ListTile(title: Text('Version: $v')),
        loading: () => const ListTile(title: Text('Version: ...'), trailing: CircularProgressIndicator()),
        error: (e, st) => ListTile(
            title: const Text('Failed to load version'),
            subtitle: Text('$e'),
            trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(appVersionProvider), // retry
            ),
        ),
        );
    }
    }
    ```
2. Use booleans (`hasError`, `isLoading`) for quick checks
    - Quick and readable for small widgets.
    ```dart
    final profileProvider = FutureProvider<Profile>((ref) async => fetchProfile());

    class ProfileHeader extends ConsumerWidget {
    const ProfileHeader({super.key});
    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final asyncProfile = ref.watch(profileProvider);

        if (asyncProfile.isLoading) {
        return const CircularProgressIndicator();
        }
        if (asyncProfile.hasError) {
        return Text('Oops: ${asyncProfile.error}');
        }

        final p = asyncProfile.requireValue; // safe: not loading/error
        return Text('Hello, ${p.name}');
    }
    }
    ```
3. Producing errors safely with `AsyncValue.guard`
    - AsyncValue.guard replaces manual try/catch by converting thrown errors to AsyncError(e, stackTrace) automatically.
    ```dart
    final userProvider = AsyncNotifierProvider<UserNotifier, User>(UserNotifier.new);

    class UserNotifier extends AsyncNotifier<User> {
    @override
    Future<User> build() async {
        // initial load
        return _fetchUser();
    }

    Future<void> refreshUser() async {
        // shows loading spinner (and preserves previous UI if you want—see tip below)
        state = const AsyncLoading();
        state = await AsyncValue.guard(_fetchUser); // catches errors -> AsyncError
    }

    Future<User> _fetchUser() async {
        await Future.delayed(const Duration(milliseconds: 400));
        // throw Exception('Network error');
        return const User(id: '1', name: 'Anam');
    }
    }
    ```
4. Showing errors as side-effects (SnackBar / Dialog) using `ref.listen`
    - Sometimes you don’t want to render the error in the widget tree—you want a toast/snackbar. Use ref.listen:
    ```dart
    class UserScreen extends ConsumerStatefulWidget {
    const UserScreen({super.key});
    @override
    ConsumerState<UserScreen> createState() => _UserScreenState();
    }

    class _UserScreenState extends ConsumerState<UserScreen> {
    @override
    void initState() {
        super.initState();
        ref.listen(userProvider, (prev, next) {
        if (next.hasError) {
            final msg = next.error.toString();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
        }
        });
    }

    @override
    Widget build(BuildContext context) {
        final userAsync = ref.watch(userProvider);
        return userAsync.when(
        data: (u) => Text('Hello ${u.name}'),
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Tap retry'),
        );
    }
    }
    ```
5. Preserve previous data while reloading (better UX)
    - When you re-fetch, you may want to keep showing stale data with a small spinner.
    ```dart
    Future<void> refreshUser() async {
    // Keep old data visible, but mark as loading
    final prev = state.valueOrNull;
    state = AsyncValue<User>.loading(previous: state.asData); // keep previous
    state = await AsyncValue.guard(_fetchUser);
    }

    final async = ref.watch(userProvider);
    final isRefreshing = async.isLoading && async.hasValue; // refreshing on top of data

    ```
