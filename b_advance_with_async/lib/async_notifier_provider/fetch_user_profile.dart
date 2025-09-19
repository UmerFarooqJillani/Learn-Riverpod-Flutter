import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ProfileScreen(),
        ),
      ),
    );
  }
}
//------------------- What’s happening behind the scenes? ----------------------------
// 1- AsyncNotifierProvider creates ProfileNotifier.
// 2- build() runs → fetches user → emits AsyncLoading, then AsyncData(User).
// 3- Widget rebuilds automatically when state changes.
// 4- If refresh fails, AsyncValue.guard sets state = AsyncError.
// 5- UI handles all 3 states with .when.

// Imagine you have an API repo ---------------------------------------------
class User {
  final String id;
  final String name;
  const User({required this.id, required this.name});
}

class UserRepo {
  Future<User> fetchUser(String id) async {
    await Future.delayed(const Duration(seconds: 2)); // simulate API delay
    return User(id: id, name: "Alice");
  }
}

final userRepoProvider = Provider((ref) => UserRepo());

// Create AsyncNotifier ---------------------------------------------
final profileProvider =
  AsyncNotifierProvider<ProfileNotifier, User>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<User> {
  late final UserRepo _repo;

  @override
  Future<User> build() async {
    _repo = ref.watch(userRepoProvider);

    // Initial load: fetch user from API
    return _repo.fetchUser("123");
  }

  Future<void> refresh() async {
    // Show spinner
    state = const AsyncLoading();

    // Run API safely (if error, wraps in AsyncError)
    state = await AsyncValue.guard(() => _repo.fetchUser("123"));
  }
}
// Use in UI ---------------------------------------------
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return asyncUser.when(
      data: (user) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello ${user.name}", style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: notifier.refresh,
            child: const Text("Refresh"),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error: $e"),
          ElevatedButton(
            onPressed: notifier.refresh,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

