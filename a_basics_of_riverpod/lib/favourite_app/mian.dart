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
                PopupMenuButton<FilterType>(
                  padding: EdgeInsets.only(right: 9),
                  onSelected: (value) {
                    ref.read(filterProvider.notifier).state = value;
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: FilterType.all,
                      child: Text("All items"),
                    ),
                    PopupMenuItem(
                      value: FilterType.favourite,
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
                // final filter = ref.watch(filterProvider);

                return ListTile(
                  onLongPress: () {
                    ref.read(selectedProvider.notifier).state = [
                      itemDetails.id,
                      ...selectedItem,
                    ];
                  },
                  onTap: () {
                    if (selectedItem.isNotEmpty) {
                      if (selectedItem.contains(itemDetails.id)) {
                        ref.read(selectedProvider.notifier).state = selectedItem
                            .where((element) => element != itemDetails.id)
                            .toList();
                      } else {
                        ref.read(selectedProvider.notifier).state = [
                          itemDetails.id,
                          ...selectedItem,
                        ];
                      }
                    }
                  },
                  title: Text(itemDetails.name),
                  leading: selectedItem.isEmpty
                      ? IconButton(
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
                        )
                      : selectedItem.contains(itemDetails.id)
                      ? Icon(Icons.check_circle, color: Colors.red)
                      : Icon(Icons.circle_outlined),
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
          ref.read(selectedProvider.notifier).state = [];
        },
        backgroundColor: Colors.blue[400],
        hoverColor: Colors.blue[300],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
