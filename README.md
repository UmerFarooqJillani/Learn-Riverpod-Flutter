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
1.  Add Dependency in pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1 # Use the latest version
```
2. Import it in .dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
