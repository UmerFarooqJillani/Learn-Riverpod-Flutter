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