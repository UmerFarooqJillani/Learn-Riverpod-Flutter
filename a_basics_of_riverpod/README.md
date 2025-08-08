# <p align="center"> a_basics_of_riverpod </p>

## `Provider` in Riverpod
Provider is used for read-only values — meaning the data never changes during the app's runtime (or at least you don’t want widgets to update reactively when it does).
- **It’s great for:**
    - Constants
    - Services (like AuthService, ThemeService)
    - Derived/computed values
- **Key Concepts:**
    - `Provider<T>`
        - Generic type T that defines what type the provider returns
    - `ref.watch()`
        - Rebuilds the widget if the value changes (if applicable)
    - `ref.read()`
        - Reads the value once, doesn’t rebuild widget on change
    - `ProviderScope`
        - Required wrapper/encapsulate around your app (in main.dart)
        - ProviderScope is the root widget required by Riverpod to track, manage, and share all your providers throughout the widget tree.
        - **Why do we need it?**<br>
            Without ProviderScope, Riverpod cannot function.<br>
            It provides an internal "container" where:
            - Providers are registered
            - Provider states are stored and updated
            - Riverpod can inject dependencies into your app
            ```dart
            void main() {
            runApp(
                ProviderScope( // 👈 This is the root of all providers
                child: MyApp(),
                ),
            );
            }
            ```
            Without ProviderScope, your app will throw errors when trying to use any provider.<br>
            Now your providers will:
            - Work globally
            - Be accessible using ref.watch, ref.read, etc.
            - Rebuild widgets automatically when values change
## Types of Providers in Riverpod
Riverpod offers different types of providers depending on what kind of data or logic you need.
1. `Provider` (For Read-only values)
    - You don’t need to change the value
    - It's a calculated value, constant, or service
        ```dart
        final nameProvider = Provider<String>((ref) {
            return "Alice";
        });
        ```
2. `StateProvider<T>` (For simple mutable values)
    - You want to **increment a counter**, **toggle a switch**, or **update a string**.
    ```dart
        final counterProvider = StateProvider<int>((ref) => 0);
    ```
3. `StateNotifierProvider` (For custom logic + complex state)
    - You want to create a ViewModel, like in MVVM
    - You have multiple properties to manage
4. `FutureProvider` (For async data (Future))   
    - You fetch something once (e.g., from API or local DB)
5. `StreamProvider` (For real-time data (Stream))
    - You need real-time updates like Firebase stream or sockets.
    
