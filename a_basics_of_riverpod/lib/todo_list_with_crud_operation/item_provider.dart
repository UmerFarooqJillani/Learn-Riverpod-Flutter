import 'package:a_basics_of_riverpod/todo_list_with_crud_operation/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemProvider = StateNotifierProvider<ItemNotifier, List<Item>>((ref) {
  return ItemNotifier();
});

class ItemNotifier extends StateNotifier<List<Item>> {
  ItemNotifier() : super([]);

  void addItem(String name) {
    final item = Item(id: DateTime.now().toString(), name: name);
    state = [...state, item]; // add in the list
  }

  void deleteItem(String id) {
    // state.removeWhere((element) => element.id == id,);
    // state = state.toList();
    //------------------------------------------
    state = state
        .where((element) => element.id != id)
        .toList(); // where id not-equal add, if id equal not-add in new list
  }

  void updateItem(String id, String name) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(name: name); // ✅ Return the new updated item
      } else {
        return item; // Return unchanged items
      }
    }).toList();
  }
}
