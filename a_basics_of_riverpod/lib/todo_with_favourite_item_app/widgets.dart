import 'package:flutter/material.dart';

Future<void> showTodoPopup(
  BuildContext context, {
  String? existingTitle,
  String? existingDescription,
  required void Function(String title, String description) onSave,
  /*
  -> onSave
    - onSave is a parameter name, not the function itself.
    - The type of onSave is: "a function that takes two strings and returns nothing".
    - You provide the actual function when you call showTodoPopup
  -> How it's work:
    -> Start
      - User types something in the Title and Description fields.
      - User presses the Save button inside the popup.
    -> Under the hood
      - Inside the Save button, this happens:
      - onSave(titleController.text, descriptionController.text);
        - Meaning: The function you passed in (your logic) gets called,
        - and the two strings from the text fields are handed over.
  */
}) {
  final titleController = TextEditingController(text: existingTitle ?? "");
  final descriptionController = TextEditingController(text: existingDescription ?? "");

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
