# <p align="center"> a_basics_of_riverpod </p>

## `Provider` in Riverpod
Provider is used for read-only values, meaning the data never changes during the app's runtime (or at least you don’t want widgets to update reactively when it does).
- **It’s great for:**
    - Constants
    - Services (like AuthService, ThemeService)
    - Derived/computed values
- **Key Concepts:**
    - `Provider<T>`
        - Generic type (T) that defines what type the provider returns
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
## `.state` in Riverpod
- Used to read or write the actual value of a provider, usually inside `.notifier`
- `.state` holds the current value of a provider.
- You can:
    - Read the current state → `final count = ref.watch(counterProvider);`
    - Update the state → `ref.read(counterProvider.notifier).state++;`
- It behaves slightly differently depending on the provider type.
    ```dart
    // Define the Provider
    final counterProvider = StateProvider<int>((ref) => 0);
    // Use in Widget
    final count = ref.watch(counterProvider); // 👈 read state (int)
    ref.read(counterProvider.notifier).state++; // 👈 write state (increment)
    ```
    - How it works:
        - `StateProvider<T>` gives access to a `StateController<T>`
        - You access it with `.notifier`
        - And use `.state` to **read/write** the value
    ```dart
    // Define the Notifier
    class CounterNotifier extends StateNotifier<int> {
        CounterNotifier() : super(0);

        void increment() => state++;      // 👈 update
        int get currentCount => state;    // 👈 read
    }
    ```
## `Consumer` & `ConsumerWidget` (rebuild only what you need)
**What problem do they solve?**
- In Riverpod, watching a provider makes the widget rebuild whenever that provider’s value changes. If you watch in a large parent widget, the entire widget subtree rebuilds.
- `Consumer` and `ConsumerWidget` let you scope that rebuild to just the specific part that needs it.
### Consumer (widget)
- A widget you can drop anywhere inside your build tree to read/watch providers only inside its builder.
- Slicing a tiny part of a big widget to be reactive.
    ```dart
    Consumer(
    builder: (context, ref, child) {
        final count = ref.watch(counterProvider);
        return Row(
        children: [
            Text('Count: $count'),
            if (child != null) child, // <-- this does NOT rebuild
        ],
        );
    },
    // Optional: static child that never rebuilds
    child: Icon(Icons.favorite), 
    );
    ```
    - `builder` gives you ref to `watch/read/listen`.
    - Pass heavy/static widgets via `child` so they don’t rebuild.
        - **The child parameter in Consumer:**
            ```dart
            Consumer(
            builder: (context, ref, child) {
                final count = ref.watch(counterProvider);
                return Row(
                children: [
                    Text('Count: $count'), // REBUILDS when count changes
                    if (child != null) child, // Does NOT rebuild
                ],
                );
            },
            child: Icon(Icons.favorite), // <-- Passed here
            );
            ```
            - **How it's passed:**
                - The child parameter is just a widget you give to the `Consumer`.
                - Flutter stores it as-is, without re-running `builder` for it when state changes.
                - Inside the `builder`, you can reference it via the child argument.
            - **Why it works:**
                - Without `child`: everything in builder runs again on every rebuild caused by ref.watch(...).
                - With `child`:
                    - The `child` widget is built once at the time the `Consumer` itself is built.
                    - On state change, Flutter does not rebuild the `child`, it reuses the same widget instance in memory.
                    - This saves CPU, improves performance, and avoids re-creating heavy widgets (e.g., large images, videos, complex layouts).
            - **What happens under the hood**
                - Here’s what Riverpod + Flutter are doing:
                    1. You call `Consumer(child: someWidget, builder: ...)`.
                    2. Flutter stores child separately from the `builder` closure.
                    3. When a watched provider changes:
                        - Only the builder function runs again.
                        - Flutter passes the original child widget instance into the builder without calling its build method again (unless that child itself depends on something that rebuilds it).
                    4. The rebuilt part is merged into the widget tree with the same child instance, so Flutter does not recreate it.
    - Use multiple `Consumers` to target different reactive areas.
### ConsumerWidget (class)
- A convenience base class for widgets that need ref in build.
- when the entire widget (or most of it) depends on providers.
    ```dart
    class CounterScreen extends ConsumerWidget {
    const CounterScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final count = ref.watch(counterProvider);
        return Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: Center(child: Text('Count: $count')),
        floatingActionButton: FloatingActionButton(
            onPressed: () => ref.read(count erProvider.notifier).state++,
            child: const Icon(Icons.add),
        ),
        );
    }
    }
    ```
### When to use `Consumer` vs `ConsumerWidget`
- **ConsumerWidget:** your whole screen (or widget) is reactive; you like a clean build signature with WidgetRef.
- **Consumer:** you only want a small section to rebuild; great inside large layouts.
- **Pro tip:** In a big screen, it’s common to use ConsumerWidget at the top and small Consumer blocks deeper down to localize rebuilds.
### `ConsumerStatefulWidget` / `ConsumerState`
- If you need initState, dispose, animations, controllers and access to ref in a stateful widget.
```dart
class PlayerBar extends ConsumerStatefulWidget {
  const PlayerBar({super.key});
  @override
  ConsumerState<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends ConsumerState<PlayerBar> {
  @override
  void initState() {
    super.initState();
    // You can use ref.listen here, etc.
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(playerProvider);
    return IconButton(
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: () => ref.read(playerProvider.notifier).toggle(),
    );
  }
}
```
- **what to use when:** 
    - Simple screen fully reactive? → `ConsumerWidget`
    - Tiny part only should rebuild? → `Consumer`
    - You need `initState`/`dispose`/`AnimationController`? → `ConsumerStatefulWidget`

## `StateNotifier & StateNotifierProvider` Vs. `Notifier & NotifierProvider`
### What are `StateNotifier` and `StateNotifierProvider`?
- `StateNotifier<T>`: a tiny class that owns a piece of state of type T and exposes methods that can update that state.
- `StateNotifierProvider<Notifier, T>`: the Riverpod bridge that
    - creates your StateNotifier,
    - exposes its current state (T) to the widget tree,
    - makes widgets rebuild when state changes.
- Think of `StateNotifier` as your **ViewModel (MVVM)**, and `StateNotifierProvider` as the connector to the **UI**.
#### Why use them (vs StateProvider)?
Use StateNotifierProvider when you need:
- Multiple related fields (not just an int/bool)
- Methods with logic (validation, branching, async pipeline)
- Immutable pattern (new objects on change)
- Testable, reusable business logic (no BuildContext)
#### How it works `under the hood`
1. Your `StateNotifier` stores a state field (type T).
2. When you assign a new value to `state`, Riverpod notifies listeners → widgets that are `ref.watch(...)` get rebuilt.
3. The `StateNotifierProvider` is listening; it emits(produce) the new value to Riverpod.
4. Any widgets that `ref.watch(theProvider)` will rebuild with the new state.<br>
- ⚠️ **Important:** Always set a new instance (don’t mutate existing `state` in-place), otherwise listeners might not be `notified`.
    1. What does it mean?
        - Whenever you assign a new value to state, Riverpod notifies listeners → widgets that are ref.watch(...) get rebuilt.
        - But if you change the existing state object directly (mutate in place), Riverpod doesn’t know that something changed — so no rebuild happens.
    2. Example with numbers (simple)
        - Imagine you have:
            ```dart
            class CounterNotifier extends StateNotifier<int> {
            CounterNotifier() : super(0);

            void increment() {
                state++; // ❌ Wrong
            }
            }
            ```
        Here, state++ changes the same integer in-place, Riverpod might not trigger rebuild because it expects a new value.
        - **Correct way:**
            ```dart
            void increment() {
            state = state + 1; // ✅ New instance of int assigned
            }
            ```
    3. Example with Lists (important for beginners)
        - Wrong way (mutating existing list)
            ```dart
            class TodoNotifier extends StateNotifier<List<String>> {
            TodoNotifier() : super([]);

            void addTodo(String todo) {
                state.add(todo); // ❌ Mutates the same list
                // Riverpod won't notify listeners because "state" still points to the same List object
            }
            }
            ``` 
        - **Correct way (create new list instance)**
            ```dart
            void addTodo(String todo) {
            state = [...state, todo]; // ✅ Creates a new List with old + new item
            }
            ``` 
        Now Riverpod sees that state is a new object, so it notifies listeners.
    4. Under the Hood
        1. StateNotifier has a state field.
        2. When you do state = somethingNew, Riverpod internally:
            - Compares old vs new object.
            - Marks provider as changed.
            - Notifies all listeners (ref.watch).
        3. If you mutate the old object, Riverpod doesn’t detect a new reference, so it skips notification.
    5. Real-world analogy<br>
        Think of state like a juice glass:
        - If you change juice inside the same glass secretly → nobody knows. (no rebuild) ❌
        - If you replace the glass with a new one → everyone sees the change. (rebuild) ✅
    6. Why `state++` works fine with `int`
        - In Dart, int is an immutable value type (like double, bool).
            ```dart 
            state++;
            ```
        - It’s actually syntactic sugar for:
            ```dart 
            state = state + 1;
            ```
        - **Meaning:** it does not mutate the existing int in place (since you can’t modify an int anyway).
        - Instead, it creates a new int and reassigns it to state.
        - So Riverpod sees state getting a new value, and listeners get notified
### What are `Notifier` & `NotifierProvider`?


