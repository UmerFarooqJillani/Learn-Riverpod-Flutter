import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//------------------------------- Provider ---------------------------------
final appNameProvider = Provider<String>((ref) {
  return "Kidlings Club App";
});

final counterProvider = StateProvider<int>((ref) => 0);
//------------------------------- UI ---------------------------------
void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appName = ref.watch(appNameProvider);
    return Text(appName);
  }
}
