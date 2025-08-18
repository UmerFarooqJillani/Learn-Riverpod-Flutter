// Build the UI that reads & writes state
// counter_screen.dart (or inside main.dart for this demo)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counter_provider.dart';

void main() {
  runApp(
    // 2) ProviderScope is the root container that stores all providers’ state.
    ProviderScope(child: MaterialApp(home: CounterScreen())),
  );
}

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  Widget getText(int count) {
    if (count <= 0) {
      count = 0;
      return Text(
        'Count: $count',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      );
    } else {
      return Text(
        'Count: $count',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Read reactively: rebuilds when counterProvider changes
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Counter')),
      body: Center(child: getText(count)),    // call the getText() function
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 2) Decrement: write via .notifier.state
          FloatingActionButton(
            heroTag: 'dec',
            onPressed: () {
              ref.read(counterProvider.notifier).state--;
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 12),
          // 3) Increment
          FloatingActionButton(
            heroTag: 'inc',
            onPressed: () {
              ref.read(counterProvider.notifier).state++;
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
