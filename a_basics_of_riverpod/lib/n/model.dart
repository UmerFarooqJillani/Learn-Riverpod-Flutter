class Todo {
  final String id;
  final String title;
  final bool done;
  const Todo({required this.id, required this.title, this.done = false});

  Todo copyWith({String? id, String? title, bool? done}) => Todo(
    id: id ?? this.id,
    title: title ?? this.title,
    done: done ?? this.done,
  );
}
