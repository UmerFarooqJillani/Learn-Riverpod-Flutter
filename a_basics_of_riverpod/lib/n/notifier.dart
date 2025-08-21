import 'package:a_basics_of_riverpod/n/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodosNotifier extends StateNotifier<List<Todo>> {
  TodosNotifier() : super(const []);

  void add(String title) {
    final newTodo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
    );
    state = [...state, newTodo]; // new list
  }

  void toggle(String id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
        .toList();
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>(
  (ref) => TodosNotifier(),
);
