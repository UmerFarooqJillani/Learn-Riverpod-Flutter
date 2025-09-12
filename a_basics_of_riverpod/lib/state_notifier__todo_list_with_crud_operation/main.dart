import 'package:a_basics_of_riverpod/state_notifier__todo_list_with_crud_operation/item_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // debugPrint("1- Create App");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Todo List"), centerTitle: true),
        body: Consumer(
          builder: (context, ref, child) {
            final item = ref.watch(itemProvider);
            // debugPrint("2- consumer call");
            return item.isEmpty
                ? Center(
                    child: Text(
                      "No Data Found",
                      style: TextStyle(fontSize: 30, color: Colors.black26),
                    ),
                  )
                : ListView.builder(
                    itemCount: item.length,
                    itemBuilder: (context, index) {
                      final itemDetails = item[index];
                      return ListTile(
                        onTap: () {
                          debugPrint("tap item: ${itemDetails.id}");
                          ref.read(itemProvider.notifier).updateItem(itemDetails.id, "Updated");
                        },
                        title: Text(itemDetails.name),
                        trailing: IconButton(
                          onPressed: () {
                            ref
                                .read(itemProvider.notifier)
                                .deleteItem(itemDetails.id);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref.read(itemProvider.notifier).addItem("hello : 01");
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
