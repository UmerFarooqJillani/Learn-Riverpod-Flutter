import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final greetingProvider = Provider((ref) => 'Hello from default!');

class GreetingText extends ConsumerWidget {
  const GreetingText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(ref.watch(greetingProvider));
  }
}

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: Column(
          children: [
            // Normal value
            const GreetingText(),

            // Scoped override
            ProviderScope(
              overrides: [
                greetingProvider.overrideWithValue('Hello from override!'),
              ],
              child: const GreetingText(),
            ),
          ],
        ),
      ),
    ),
  );
}
