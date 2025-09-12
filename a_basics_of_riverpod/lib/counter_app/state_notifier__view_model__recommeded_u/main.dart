import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/// ------------------------------
/// ViewModel: CounterNotifier
/// ------------------------------
import 'package:a_basics_of_riverpod/counter_app/state_notifier__view_model__recommeded_u/counter_notifier.dart';
/// ------------------------------

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// ------------------------------
/// App root
/// ------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
/// ------------------------------
/// debugPrint('1. [MyApp] build');
//    debugPrint() is just like print(), but:
//      - It truncates very long messages to avoid flooding logs.
//      - It’s optimized for Flutter’s debug console.
//      - We use it for debugging/logging purposes only (to track what code runs).
/// ------------------------------
    debugPrint('1. [MyApp] build');
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterScreen(),
    );
  }
}

/// ------------------------------
/// Screen using ConsumerWidget
/// ------------------------------
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('2. [CounterScreen] build (Whole screen)');

    //--------------(01)--------------------
    // Reactive read: this widget rebuilds when counter changes
    // - When i used the entire screen rebuilds
    // final count = ref.watch(counterProvider);
    //--------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Counter (Consumer child demo)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            //--------------(01)--------------------
            // Text(
            //   'Count: $count',
            //   style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            // ),
            //--------------------------------------
            Consumer(
              builder: (context, ref, _) {
                debugPrint('3. [Consumer builder] rebuild (counter)');
                final count = ref.watch(counterProvider);
                return Text('Count: $count');
              },
            ),
            const SizedBox(height: 20),

            /// ------------------------------
            /// Consumer with `child` optimization
            /// The `child` is built ONCE and reused.
            /// Only the Text inside builder rebuilds.
            /// ------------------------------
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Consumer(
                  // The `child` here is a heavy/static widget that does not rebuild
                  child: const HeavyStaticIcon(),
                  builder: (context, ref, child) {
                    debugPrint('4. [Consumer builder] rebuild (card)');
                    final value = ref.watch(
                      counterProvider,
                    ); // triggers rebuild

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reactive value: $value',
                          style: const TextStyle(fontSize: 18),
                        ),
                        if (child != null) child, // <-- does NOT rebuild
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Open your console: you\'ll see the Consumer builder rebuilds, '
              'but HeavyStaticIcon does not.',
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'dec',
                  onPressed: () {
                    debugPrint('[onPressed] decrement');
                    ref.read(counterProvider.notifier).decrement();
                  },
                  label: const Text('Decrement'),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'inc',
                  onPressed: () {
                    debugPrint('[onPressed] increment');
                    ref.read(counterProvider.notifier).increment();
                  },
                  label: const Text('Increment'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class HeavyStaticIcon extends StatelessWidget {
  const HeavyStaticIcon({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('5. [HeavyStaticIcon] build (should build only once)');
    // Simulate something heavier (image, vector, etc.)
    return const Icon(Icons.favorite, color: Colors.pink, size: 32);
  }
}
