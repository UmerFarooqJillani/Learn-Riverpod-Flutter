import 'package:a_basics_of_riverpod/n/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main(){
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodosScreen(),
    );
  }
}
class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);
    final notifier = ref.read(todosProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: ListView(
        children: [
          for (final t in todos)
            CheckboxListTile(
              value: t.done,
              title: Text(t.title),
              onChanged: (_) => notifier.toggle(t.id),
              secondary: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => notifier.remove(t.id),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.add('New task ${todos.length + 1}'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
