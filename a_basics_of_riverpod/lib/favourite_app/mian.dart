import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:a_basics_of_riverpod/favourite_app/state_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("1- app build");
    final node = ref.watch(itemProvider);
    final selectedItem = ref.watch(selectedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: selectedItem.isEmpty
            ? const Text("Favourite")
            : Text("${selectedItem.length} selected"),

        actions: [
          if (selectedItem.isEmpty)
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                PopupMenuButton(
                  padding: EdgeInsets.only(right: 9),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "Delete", child: Text("All items")),
                    PopupMenuItem(
                      value: "Edit",
                      child: Text("Favourite items"),
                    ),
                  ],
                ),
              ],
            ),
          if (selectedItem.isNotEmpty)
            IconButton(
              onPressed: () {
                ref.read(itemProvider.notifier).removeItem(selectedItem);
                ref.read(selectedProvider.notifier).state = [];
              },
              icon: Icon(Icons.delete),
            ),
        ],
      ),
      body: node.isEmpty
          ? Center(
              child: Text(
                "No Data Found",
                style: TextStyle(fontSize: 30, color: Colors.black26),
              ),
            )
          : ListView.builder(
              itemCount: node.length,
              itemBuilder: (context, index) {
                final itemDetails = node[index];
                return ListTile(
                  onLongPress: () {
                    
                  },
                  onTap: () {

                  },
                  title: Text(itemDetails.name),
                  leading: IconButton(
                    onPressed: () {
                      ref
                          .read(itemProvider.notifier)
                          .updateItem(
                            itemDetails.id,
                            itemDetails.name,
                            !itemDetails.favourite,
                          );
                    },

                    icon: Icon(
                      Icons.star,
                      color: itemDetails.favourite
                          ? Colors.amber
                          : Colors.black26,
                    ),
                  ),
                  trailing: Text(
                    "${itemDetails.id.hour}:${itemDetails.id.minute}  ${itemDetails.id.day}/${itemDetails.id.month}/${itemDetails.id.year}",
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(itemProvider.notifier).addItem("");
        },
        backgroundColor: Colors.blue[400],
        hoverColor: Colors.blue[300],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
