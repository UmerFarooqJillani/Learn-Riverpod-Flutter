import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_basics_of_riverpod/todo_with_favourite_item_app/model.dart';

final itemProvider = StateNotifierProvider<ItemsNotifier, List<Items>>((ref) {
  return ItemsNotifier();
});

class ItemsNotifier extends StateNotifier<List<Items>> {
  ItemsNotifier() : super([]);

  void addItem(String name, String description){
    // add item
    final item = Items(name: name, id: DateTime.now(), favourite: false, description: description);
    state = [item, ...state];
    return;
  }

  void removeItem(List<DateTime> id) {
    // Remove item
    //-------------------------------------------
    /*
    -> problem: 
       For N items, you create new lists N times.
    */
    // for (int i = 0; i < id.length; i++) {
    //   state = state.where((element) => element.id != id[i]).toList();
    // }
    //--------------------------------------------
    final idSet = id.toSet();
    state = state.where((item) => !idSet.contains(item.id)).toList();
    //---------------------------------------------
    return;
  }

  void updateItem(DateTime id, String name, bool favourite, String description){
    // Update item
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(name: name, favourite: favourite, description: description);
      } else {
        return e;
      }
    }).toList();
  }
}

// -------------------------
final selectedProvider = StateProvider<List<DateTime>>((ref) => []);

// -------------------------
enum FilterType { all, favourite }

final filterProvider = StateProvider<FilterType>((ref) => FilterType.all);

// -------------------------
final searchQueryProvider = StateProvider<String>((ref) => "");

final visibleItemsProvider = Provider<List<Items>>((ref) {
  final allItems = ref.watch(itemProvider);
  final filter = ref.watch(filterProvider);
  final query = ref.watch(searchQueryProvider);

  // Step 1: filter by favourites
  var items = filter == FilterType.all
      ? allItems
      : allItems.where((item) => item.favourite).toList();

  // Step 2: filter by search
  if (query.isNotEmpty) {
    items = items
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  return items;
});

