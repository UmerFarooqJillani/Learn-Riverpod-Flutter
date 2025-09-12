class Items {
  final String name;
  final DateTime id;
  final bool favourite;
  final String description;
  const Items({required this.name, required this.id, this.favourite = false, required this.description});

  Items copyWith({String? name, DateTime? id, bool? favourite, String? description}) {
    return Items(
      name: name ?? this.name,
      id: id ?? this.id,
      favourite: favourite ?? this.favourite,
      description: description ?? this.description,
    );
  }
}
