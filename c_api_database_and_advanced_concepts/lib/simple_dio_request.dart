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

  // Step 1: Create Dio object
  final Dio dio = Dio();

  // Step 2: Function to call API
  Future<void> fetchData() async {
    try {
      // API endpoint
      final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');

      // Step 3: Check if successful
      if (response.statusCode == 200) {
        // Response data is automatically converted to a Map
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
