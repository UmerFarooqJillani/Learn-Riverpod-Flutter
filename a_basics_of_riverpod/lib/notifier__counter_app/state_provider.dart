import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final counterProvider = NotifierProvider<Counter, int>(Counter.new);

// Notifier
class Counter extends Notifier<int> {
  @override
  int build() {
    // initial state
    return 0;
  }

  void increment() => state++;
  void decrement() => state--;
}
