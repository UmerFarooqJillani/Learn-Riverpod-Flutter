class Items {
  final String name;
  final DateTime id;
  final bool favourite;
  const Items({required this.name, required this.id, this.favourite = false});

  Items copyWith({String? name, DateTime? id, bool? favourite}) {
    return Items(
      name: name ?? this.name,
      id: id ?? this.id,
      favourite: favourite ?? this.favourite,
    );
  }
}

// class Favourite {
//   final List<Items> allItems;
//   final List<Items> filteredItems;
//   final String search;

//   const Favourite({
//     required this.allItems,
//     required this.filteredItems,
//     required this.search,
//   });

//   Favourite copyWith({
//     List<Items>? allItems,
//     List<Items>? filteredItems,
//     String? search,
//   }) {
//     return Favourite(
//       allItems: allItems ?? this.allItems,
//       filteredItems: filteredItems ?? this.filteredItems,
//       search: search ?? this.search,
//     );
//   }
// }
