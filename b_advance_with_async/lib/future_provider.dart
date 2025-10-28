import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//---------- Provider (VM)-----------------------------

final myProvider = FutureProvider<int>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  throw "Check The Internet Connection";
  // return 3;
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Future Provider"), centerTitle: true),
        body: Consumer(
          builder: (context, ref, child) {
            final pro = ref.watch(myProvider);
            return Center(
              child: pro.when(
                data: (data) => Text(data.toString()),
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
