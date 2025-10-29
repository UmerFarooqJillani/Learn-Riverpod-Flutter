import 'package:d_testing/provider_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('App name provider should return the correct name', () {
    // 1️⃣ Create a ProviderContainer
    final container = ProviderContainer();

    // 2️⃣ Read the provider (no widgets needed)
    final appName = container.read(appNameProvider);

    // 3️⃣ Check if the value is correct
    expect(appName, "Kidlings Club App");

    // 4️⃣ Cleanup
    container.dispose();
  });
  //----------------------------------------------------------------------
  // use the another file (Recommeded)
  //----------------------------------------------------------------------
  test('Counter increments correctly', () {
    final container = ProviderContainer();

    // Read initial value
    expect(container.read(counterProvider), 0);

    // Increase state
    container.read(counterProvider.notifier).state++;

    // Check updated value
    expect(container.read(counterProvider), 1);

    container.dispose();
  });
}
