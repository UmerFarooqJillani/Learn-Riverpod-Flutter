# <p align="center"> Riverpod State Management In Flutter </p>

## Riverpod
- Riverpod is a state management library for [Flutter](https://github.com/UmerFarooqJillani/Flutter-Learning) that helps you manage and share app data across widgets efficiently.
- Riverpod is a modern, robust, and compile-time-safe state management solution for Flutter. 
- It was created by the same author of Provider but improves on its limitations. 
- Riverpod gives you fine control over your app’s state, allows easier testing, lazy-loading, code splitting, and integrates cleanly with async code.

## Why Use Riverpod
- Your app has multiple UI components that need to share or react to data
- You want predictable and testable state logic
- You want to separate your UI from your business logic
- You need to manage async operations like API calls, audio/video streams, Firebase, camera/AR, etc.

## Pros of Riverpod
- No context needed (unlike Provider.of)
- Compile-time safety (errors caught early)
- Hot-reload safe (even async state)
- Easier to test
- Works with **MVVM**, Clean Architecture
- **AutoDispose** helps manage memory in large apps
- Great async support via AsyncNotifier, FutureProvider, etc.
- Popular in production apps (supported by Google Devs)

## Cons of Riverpod
- Slight learning curve for beginners
- More **boilerplate** compared to **setState**
- Misusing `ref.watch` and `ref.read` can cause unnecessary rebuilds if not handled properly
- Doesn’t include routing or side-effects by default (but works great with `go_router`, `hooks_riverpod`, etc.)

## How to Install and Setup Riverpod
- Package	`flutter_riverpod: ^latest` vs `riverpod: ^latest`
  - `riverpod`
    - Pure Dart.
    - Can be used outside of Flutter — like in Dart-only projects, CLI tools, unit test logic, etc.
    - You don’t get widgets like `ConsumerWidget`, `ref.watch()` in `build()` unless you also add `flutter_riverpod`.
  - `flutter_riverpod`
    - This is the Flutter integration layer.
    - Includes everything from riverpod, plus Flutter-specific widgets and context-less architecture.
    - Enables ref.watch, ref.read, ProviderScope, ConsumerWidget, Consumer, HookConsumerWidget, etc.
  - **In Flutter apps, you only need `flutter_riverpod`, because it already includes riverpod under the hood.**
1.  Add Dependency in pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1 # Use the latest version
```
  - You do not need to add riverpod: separately, flutter_riverpod already includes it.
2. Import it:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
## Flutter’s Architecture "What’s under the hood"
Flutter is built with 3 core layers:
1. **Framework (Dart)**
    - This is what you write: Widgets, State, BuildContext, setState(), etc.
    - It's built in Dart and defines UI structure and logic.
2. **Engine (C++)**
    - Responsible for rendering, layout, painting, and compositing.
    - Uses Skia(2D graphics engine that Flutter uses internally for rendering), a high-performance rendering engine, to draw pixels on screen.
Converts widget tree → render tree → actual pixels.
3. **Embedder (Platform-Specific)**
    - Connects Flutter to the underlying OS (Android, iOS, Web, Desktop).
    - Manages platform-specific tasks: input events, lifecycle, camera, GPS, etc.

### In Simple Words `Under the hood`:
What Flutter secretly does in the background to make your app run fast, look beautiful, and respond instantly to user input.

## In Riverpod *no `context` needed (unlike `Provider.of`)* ?
In traditional Provider, you often have to access data using the BuildContext like this:
```dart
final user = Provider.of<User>(context);
```
That means:
- You can only access providers inside a widget’s build method or where you have a `BuildContext`.
- You can’t access providers in pure Dart classes or `initState()` unless you pass context.
- **Tight Coupling & Loose Coupling:**
  - **Tight coupling** refers to a situation where two or more software components are closely connected and depend(strong dependencies) on each other to function properly. 
  - **Loose coupling**, on the other hand, means that the components are less dependent on each other and can operate more independently(weak dependencies).
- **Problems with context in Provider:**
  1. Can't use in initState / dispose directly.
  2. Harder to test (because you always need a widget tree and context).
  3. Tight coupling to widgets and build context.
- **Riverpod solves this:**
  - In Riverpod, you do NOT need BuildContext to access your providers!
  - Instead, you use a ref object that is passed to your widget or provider automatically:
    ```dart
    final user = ref.watch(userProvider);
    ```
  - **Or inside providers:**
    ```dart
    String welcomeMessage(ProviderRef ref) {
      final user = ref.watch(userProvider);
      return 'Welcome ${user.name}';
    }
    ```
  - **You can use ref:**
    - In widgets (like ConsumerWidget)
    - In providers (like Provider, Notifier, FutureProvider, etc.)
    - In any lifecycle-safe area (even outside widget tree)

--- 