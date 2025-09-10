import 'package:flutter/material.dart';

Future<void> showTodoPopup(
  BuildContext context, {
  String? existingTitle,
  String? existingDescription,
  required void Function(String title, String description)
  onSave, // callback fnc
}) {
  final titleController = TextEditingController(text: existingTitle ?? "");
  final descriptionController = TextEditingController(
    text: existingDescription ?? "",
  );

  return showDialog(
    context: context,
    // barrierDismissible: false, // user must press save/close
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text(existingTitle == null ? "Create Task" : "Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              maxLines: 1,
              decoration: const InputDecoration(helperText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(helperText: "Description"),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () {
              onSave(
                titleController.text,
                descriptionController.text,
              ); // call-back fnc
              Navigator.of(context).pop(); // close popup
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
