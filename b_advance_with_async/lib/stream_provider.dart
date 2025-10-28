import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

//---------- Provider (VM)-----------------------------
final myProvider = StreamProvider<double>((ref) async* {
  final random = Random();
  double currentPrice = 100.0;

  while (true) {
    await Future.delayed(Duration(seconds: 1));

    currentPrice += random.nextDouble() *4 - 2; // Random change Between -2 and +2
    // throw "error";
    yield double.parse(currentPrice.toStringAsFixed(2));
  }
});
// ---------------- Starting point ----------------------------
void main() {
  runApp(ProviderScope(child: MyApp()));
}

//------------------ UI -----------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Initial Build");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Future Provider"), centerTitle: true),
        body: Consumer(
          builder: (context, ref, child) {
          debugPrint("Build");
            final pro = ref.watch(myProvider);
            return Center(
              child: pro.when(
                data: (data) => Text(data.toStringAsFixed(2).toString()),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
