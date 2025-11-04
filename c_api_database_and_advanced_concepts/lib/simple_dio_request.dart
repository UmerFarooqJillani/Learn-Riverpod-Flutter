import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MaterialApp(home: DioExample()));
}

class DioExample extends StatefulWidget {
  const DioExample({super.key});

  @override
  State<DioExample> createState() => _DioExampleState();
}

class _DioExampleState extends State<DioExample> {
  String title = "Loading...";

  // Step 1: Create Dio object HTTP client.
  final Dio dio = Dio();

  // Step 2: Function to call API
  Future<void> fetchData() async {
    try {
      // API endpoint (Makes an API call and waits for the result.)
      final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');

      // Step 3: Check if successful
      if (response.statusCode == 200) {
        // Response data is automatically converted to a Map (Contains your JSON response.)
        final data = response.data;

        setState(() {
          title = data['title']; // get "title" key from JSON
        });
      } else {
        setState(() {
          title = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        title = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // run API when app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dio Example')),
      body: Center(child: Text(title)),
    );
  }
}
// ------------------- POST Request -------------------
// Future<void> sendData() async {
//   try {
//     final response = await dio.post(
//       'https://jsonplaceholder.typicode.com/posts',
//       data: {
//         'title': 'Hello World',
//         'body': 'This is my first post',
//         'userId': 1,
//       },
//     );

//     print(response.data); // prints JSON response
//   } catch (e) {
//     print('Error: $e');
//   }
// }
// ------------------- POST Request -------------------
