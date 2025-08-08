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

## `ref` in Riverpod
- `ref` stands for **Reference**.
- It is the main tool you use to interact with providers.
- Think of ref as the remote control that lets you:
    - Watch a provider
    - Read a provider
    - Listen to provider changes
    - Access notifiers
    - Do anything provider-related
### Where does `ref` come from (used in)?
You get access to ref in 2 main places:
1. Inside a Provider:
    - Here, ref is used to build or depend on other providers.
    ```dart
    final greetingProvider = Provider<String>((ref) {
        return "Hello, world!";
    });
    ```
2. Inside a Consumer widget:
    - Here, ref is used to watch or read providers inside widgets.
## `ref.watch` (Watch and Rebuild Automatically)
- `ref.watch(provider)` is used to listen to changes in a provider’s value and automatically rebuild the widget when the value changes.
- Use `ref.watch` inside `Consumer`, `ConsumerWidget`, or `HookConsumerWidget`.
### Why Use It?
- Automatically update when state changes.
- No manual `setState()`.
- Clean code for reactive Flutter widgets.
###  Under the Hood
When the provider’s value changes:
- Riverpod marks the widget dirty.
- It triggers a rebuild of that widget tree.
### When NOT to use `ref.watch`
- Riverpod subscribes (to agree to regularly receive something) the widget to the provider.
- Don't use ref.watch when:
    - You don't want the widget to rebuild.
    - You're calling a method or doing navigation (use `ref.read` or `ref.listen` instead).
## `ref.read` (Read Once, No Rebuild, for logic)
- `ref.read(provider)` is used to get the current value of a provider once without subscribing to it.
- It does NOT rebuild the widget when the value changes.
- **Use it when:**
    - You want to trigger an action & Update a value.
    - You want to change state,  Call methods (not UI).
    - You want to Navigate after action (Navigate after updating state), validate, or fetch something once
### Under the Hood
- `ref.read` accesses the provider’s value once at that point.
- It doesn’t track the value for rebuilds.
- Efficient for logic, not for reactive UI.
## `ref.listen` (Respond to Changes Without Rebuilding the Widget)
- `ref.listen(provider, (previous, next) {})` allows you to react to provider value changes, but it does not rebuild the widget.
- **When Should You Use ref.listen?**
    - You want to show a Snackbar	
        - Without rebuilding the widget
    - You want to log state changes	
        - Debugging purposes
    - You want to navigate on state	
        - e.g., go to success page
    - You want to trigger animations	
        - When state updates
##  `listen` vs `watch` vs `read`
- `ref.watch` (Reactive UI updates)
    - **Rebuilds UI:** ✅ Yes
    - **Triggers callback:** ❌ No
- `ref.read` (Get current value (no rebuild))
    - **Rebuilds UI:** ❌ No	
    - **Triggers callback:** ❌ No
- `ref.listen` (React to change, no rebuild)
    - **Rebuilds UI:** ❌ No	
    - **Triggers callback:** ✅ Yes
## `notifier` in Riverpod
- The key to updating state inside StateNotifierProvider or StateProvider.
- In Riverpod, .notifier gives you access to the object that holds and modifies the state.
- **Why Use `.notifier`?**
    - Because the value of the provider is read-only via `.watch` or `.read`.
    - To change state, you must use `.notifier` to access the underlying controller.
- **Behind the Scenes**<br>
`.notifier` returns a controller object that:
    - Has access to `.state`
    - Can update `.state`
    - Can expose custom methods (like `increment()`)