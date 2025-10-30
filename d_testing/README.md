# <p align="center"> d_testing </p>

## `ProviderContainer`
- Think of ProviderContainer as a mini `test lab` for your Riverpod providers.
- Normally, in your app, providers are managed automatically by ProviderScope in main.dart.
- use your providers outside of widgets
- manually control when they are created and destroyed
- test their logic directly (without running the whole Flutter app)
```dart
*************************************************************************
* Environment *    Who manages providers?   *      Use case             *
*************************************************************************
*  Real app   *    ProviderScope (auto)     *  Normal UI and features   *
*  Testing    *  ProviderContainer (manual) * Testing or headless logic *
*************************************************************************
```
### Why we use `ProviderContainer`
1. For testing (main reason)
2. To manually read or change provider values
3. To override dependencies
4. To manually dispose / refresh providers

### Real-World Example 
1. See the file`lib/provider_container.dart`
2. Now, what if you want to test that appNameProvider works correctly
without running the app?
3. Create a test file `test/app_name_test.dart`
4. Import packages
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:flutter_test/flutter_test.dart';
    ```
5. Create a ProviderContainer and test
6. Output:
    ```Output
    ✓ App name provider should return the correct name
    ```
### When & Where to Write `ProviderContainer` Code
- You write this in your test files, usually in the test/ folder. ✅
- You don’t write this inside your Flutter app code (UI). ❌
### When do we write tests?
#### Situation **(Small project / Learning)**
- You can write tests at the end, after app works
#### Situation **(Big project / Professional)**
- Write tests along the way, as you create features
### My recommendation (for you as a beginner)
1. First focus on building features (learn how Riverpod, state, and widgets work).
2. Once your project is stable → start writing tests for important providers (API calls, logic, etc.).
3. Later, you can use ProviderContainer to test everything automatically.

## Scoped Overrides in Riverpod
- Scoped Overrides let you use different provider values inside a specific part of your app. Perfect for testing, themes, or screen-specific data.
### Why Use It
- Use different data or behavior in a specific screen or test.
- Helps with testing, themes, fake APIs, or debug/demo modes.
### How It Works
- Wrap your widget tree (or test) in a new ProviderScope(overrides: [...]).
```dart
final apiUrlProvider = Provider((ref) => 'https://real-api.com');

void main() {
  testWidgets('use fake API', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiUrlProvider.overrideWithValue('https://fake-api.com')
        ],
        child: const MyApp(),
      ),
    );
  });
}
```
## What to test (mental model)
- **Unit tests (most):** pure Dart logic (providers/notifiers/repositories).
- **Widget tests (some):** a widget tree with ProviderScope, fast in memory.
- **Integration tests (few):** full app on device/emulator, slow but realistic.<br>
**`Unit tests` are fastest/cheapest, catch most bugs early. `Widget tests` ensure UI + providers talk correctly. `Integration tests` verify real flows (navigation, assets, plugins).**

### Where tests live & how to run
- Unit & Widget: test/ 
    ```dart
    flutter test
    ```
- Integration: integration_test/
    ```dart
    flutter test integration_test (or via IDE/CI)
    ```
### Riverpod testing building block:
- `ProviderContainer` (Great for unit tests (no UI) and overrides.)
    - Outside of Flutter widgets, you can drive providers manually: 
        ```dart
        final container = ProviderContainer(
        overrides: [/* fake repos, config, etc. */],
        );
        // read/watch providers
        final value = container.read(myProvider);
        // cleanup
        container.dispose();
        ```
### Unit Testing (pure logic)
- When?
    - Testing Notifiers/AsyncNotifiers, repositories, and computed providers.
    - No UI. Fast feedback.
- Why?
    - Most bugs live in logic, keeps tests stable and quick.
#### Example A (StateNotifier counter)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = NotifierProvider<Counter, int>(Counter.new);

class Counter extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
  void decrement() => state--;
}
//------------- Unit Testing -----------------
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counter.dart';

void main() {
  test('counter increments & decrements', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
    container.read(counterProvider.notifier).decrement();
    expect(container.read(counterProvider), 0);
  });
}
```
#### Example B (AsyncNotifier with error handling)
```dart
final userProvider =
  AsyncNotifierProvider<UserNotifier, String>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async => _fetchUser();
  Future<String> _fetchUser() async => 'Anam'; // mock here or call repo
}
//------------- Unit Testing -----------------
test('loads user name', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final name = await container.read(userProvider.future);
  expect(name, 'Anam');
});
```
#### Example C (Override a dependency (fake repo))
```dart
final repoProvider = Provider<UserRepo>((_) => UserRepoHttp());
final userNameProvider = FutureProvider<String>((ref) async {
  return ref.read(repoProvider).fetchName();
});

class FakeUserRepo implements UserRepo {
  @override
  Future<String> fetchName() async => 'Fake-Name';
}

test('override repo with fake', () async {
  final container = ProviderContainer(overrides: [
    repoProvider.overrideWithValue(FakeUserRepo()),
  ]);
  addTearDown(container.dispose);

  expect(await container.read(userNameProvider.future), 'Fake-Name');
});
```
### Widget Testing (UI + providers in memory)
- When?
    - Testing widgets that use `ref.watch/ref.read`.
    - Verifying UI reacts to provider changes (loading/data/error).
    - No real device runs super fast.
- Why?
    - Catch regressions in UI logic without heavy integration setup.
#### Example (Greeting widget)
- If you added a real delay (e.g., await Future.delayed(400.ms)), pump >= that delay.
- If you don’t know how long: use await tester.pumpAndSettle() (waits until no more scheduled frames), but be careful of infinite streams which never `settle`.
```dart
// lib/greeting.dart
final greetingProvider = Provider((_) => 'Hello');

class GreetingText extends ConsumerWidget {
  const GreetingText({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(greetingProvider);
    return Text(text, textDirection: TextDirection.ltr);
  }
}
//------------- Widget test with scoped override -----------------
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'greeting.dart';

void main() {
  testWidgets('show overridden greeting', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [greetingProvider.overrideWithValue('Salam!')],
        child: const GreetingText(),
      ),
    );

    expect(find.text('Salam!'), findsOneWidget);
  });
}
```
**Async UI pattern**
```dart
//--------------------------- Provider ------------------
final versionProvider = FutureProvider<String>((ref) async {
  // in real life: await http.get(...)
  return '1.0.3';
});
//--------------------------- UI ----------------------------
class VersionTile extends ConsumerWidget {
  const VersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVersion = ref.watch(versionProvider);

    return asyncVersion.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (v) => Center(child: Text('Version: $v')),
    );
  }
}
// ---------------- widget test ------------------------------
testWidgets('shows loading then data', (tester) async {
  // 1) Build a widget tree with Riverpod available
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: VersionTile())),
  );

  // 2) First frame: FutureProvider is in loading state
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // 3) Advance fake time / pump another frame so the microtask queue resolves
  await tester.pump(const Duration(milliseconds: 10));
  // If your future has a real delay, use that duration (e.g. 400ms).
  // For an immediate future, any small pump is enough to trigger the rebuild.

  // 4) Now the provider should have data
  expect(find.textContaining('1.0.3'), findsOneWidget);
});
```
### Integration Testing (end-to-end on device)
- When?
    - Verifying full user flows: navigation, plugins (camera/audio), assets, platform channels.
    - Slowest; use sparingly for `happy paths`.
- Why?
    - Ensures your app works for real users on real devices.
```dart   
//------------------ Auth providers (app code) -------------------------
// lib/providers.dart
final authRepoProvider = Provider<AuthRepo>((_) => RealAuthRepo());

final authStateProvider =
  AsyncNotifierProvider<AuthController, bool>(AuthController.new);

class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => false; // logged out initially

  Future<void> login(String user, String pass) async {
    state = const AsyncLoading(); // UI can show loading
    final ok = await ref.read(authRepoProvider).login(user, pass);
    state = AsyncData(ok);        // true when logged-in
  }
}
//------------------ UI ------------------------
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(key: const Key('user'), controller: userCtrl),
          TextField(key: const Key('pass'), controller: passCtrl, obscureText: true),
          if (auth.isLoading) const CircularProgressIndicator(),
          ElevatedButton(
            key: const Key('loginBtn'),
            onPressed: () => ref.read(authStateProvider.notifier)
                               .login(userCtrl.text, passCtrl.text),
            child: const Text('Login'),
          ),
        ]),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(), // After login, your app could navigate to Dashboard
    );
  }
}
//----------- Integration test ---------------------
// integration_test/app_test.dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:your_app/main.dart';
import 'package:your_app/providers.dart';

class FakeAuthRepo implements AuthRepo {
  @override
  Future<bool> login(String u, String p) async => u == 'a' && p == '1';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();  // Sets up the integration test runner so it launches on a device/emulator.

  testWidgets('login happy path', (tester) async {
    // 1) Boot the real app, but override the API dependency to avoid real network
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepoProvider.overrideWithValue(FakeAuthRepo()),
        ],
        child: const App(),
      ),
    );

    // 2) Interact like a real user
    await tester.enterText(find.byKey(const Key('user')), 'a');
    await tester.enterText(find.byKey(const Key('pass')), '1');
    await tester.tap(find.byKey(const Key('loginBtn')));

    // 3) Let animations/async settle (button ripple, AsyncLoading → AsyncData)
    // pumpAndSettle():
    // Wait for animations and async state transitions (loading → data).
    await tester.pumpAndSettle();

    // 4) Assert the expected result (e.g., you navigated or UI changed)
    // If your app navigates to a dashboard showing “Welcome”:
    expect(find.text('Welcome'), findsOneWidget);
  });
}
```
## Quick cheat-sheet
```dart
Unit → ProviderContainer (+ overrides) → logic only.
Widget → ProviderScope + pumpWidget (+ overrides) → UI reacts.
Integration → integration_test + real app → end-to-end.
```
**Commands:**
```dart
flutter test                         # unit + widget
flutter test --coverage              # coverage
flutter test integration_test        # integration
```
**Quick comparisons:**
- `ProviderScope` makes providers available to all descendant widgets.
- `ProviderContainer` cannot be used because it’s not part of Flutter’s widget system.
```dart
Unit (Providers & logic (no UI)) → Fast Speed Using ProviderContainer (Not using ProviderScope)
Widget (UI + provider UI (in memory)) → Med Speed Using ProviderScope (Not using ProviderContainer)
Integration (Full app on device/emulator) → Slow Speed Using ProviderScope (Not using ProviderContainer)
```
