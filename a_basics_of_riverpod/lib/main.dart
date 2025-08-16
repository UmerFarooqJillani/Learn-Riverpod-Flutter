// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1) A StateProvider holds a simple mutable value (an int here).
final counterProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(
    // 2) ProviderScope is the root container that stores all providers’ state.
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CounterScreen());
  }
}

// 3) Use ConsumerWidget to get a WidgetRef (named `ref`) for interacting with providers.
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4) ref.watch subscribes the widget to counterProvider changes (rebuilds when it changes)
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Counter')),
      body: Center(
        child: Text(
          'Count: $count',
          style: const TextStyle(fontSize: 32),
        ),
        // ---------------------------------------------------------------------
        // child: Consumer(
        //   builder: (context, ref, child) {
        //     final count = ref.watch(counterProvider);
        //     return Row(
        //       children: [
        //         Text('Count: $count'),
        //         if (child != null) child, // <-- this does NOT rebuild
        //       ],
        //     );
        //   },
        //   // Optional: static child that never rebuilds
        //   child: Icon(Icons.favorite),
        // ),
        // ------------------------------------------------------------------------
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Increment
          FloatingActionButton(
            heroTag: 'inc',
            onPressed: () {
              // 5) ref.read gets the controller (notifier) without subscribing the UI.
              //    .state is the actual int value—so we can write to it.
              ref.read(counterProvider.notifier).state++;
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          // Decrement
          FloatingActionButton(
            heroTag: 'dec',
            onPressed: () {
              ref.read(counterProvider.notifier).state--;
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 12),
          // Reset
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () {
              ref.read(counterProvider.notifier).state = 0;
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
