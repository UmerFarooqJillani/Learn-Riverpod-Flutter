import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//--------------------------------------------
// Using dependencies inside build()
//-----------------------------(notifier)------------------------------------------------
final multiplierProvider = StateProvider<int>((_) => 2);

final multipliedCounterProvider =
    NotifierProvider<MultipliedCounter, int>(MultipliedCounter.new);

class MultipliedCounter extends Notifier<int> {
  @override
  int build() {
    final base = 1;                         // local initial
    final mul = ref.watch(multiplierProvider); // dependency
    return base * mul;  // if multiplier changes, build() re-runs
  }

  void bump() => state = state + ref.read(multiplierProvider);
}

//-------------------------------(UI)----------------------------------------------
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifier + build() depe ndency demo',
      debugShowCheckedModeBanner: false,
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends ConsumerWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[DemoScreen] build');

    // Reactive reads
    final multiplier = ref.watch(multiplierProvider);
    final value = ref.watch(multipliedCounterProvider);

    // For actions (no rebuild needed on these lines)
    final counter = ref.read(multipliedCounterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod v2: Notifier + dependencies')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('1) Change the multiplier'),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    final m = ref.read(multiplierProvider);
                    if (m > 1) ref.read(multiplierProvider.notifier).state = m - 1;
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      'Multiplier: $multiplier',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    final m = ref.read(multiplierProvider);
                    ref.read(multiplierProvider.notifier).state = m + 1;
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text('2) Counter value (Notifier state)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: When multiplier changes, Notifier.build() runs again\n'
                    'and the counter is reinitialized to base * multiplier.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),

            const Text('3) Actions'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: counter.bump,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Bump (+multiplier)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
