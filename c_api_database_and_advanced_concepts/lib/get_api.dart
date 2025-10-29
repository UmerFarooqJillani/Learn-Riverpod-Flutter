/*
-> API: https://jsonplaceholder.typicode.com/posts
-> object: 
    {
     "userId": 1,
     "id": 1,
     "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
     "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
    },
-> Import Package (Dart):   http: ^1.5.0

*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';

//-------------------- VM -----------------------------------------
class GetApi {
  final int userId;
  final int id;
  final String title;
  final String body;

  const GetApi({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory GetApi.fromjson(Map<String, dynamic> json) {
    return GetApi(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

final myProvider = FutureProvider<List<GetApi>>((ref) async {
  try {
    final response = await get(
      Uri.parse("https://jsonplaceholder.typicode.com/posts"),
      // final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"),
    );
    if (response.statusCode == 200) {
      // Status == 200 == OK
      final List<dynamic> data = jsonDecode(response.body);    // used te dart:convert to decode
      List<GetApi> getList = data.map((e) => GetApi.fromjson(e)).toList();
      return getList;
    } else {
      throw "Something went Wrong";
    }
  }on ClientException
  {
    throw "No Internet";
  }
  catch (e) {
    rethrow;
  }
});
// ---------------- Starting point ----------------------------
void main() {
  runApp(ProviderScope(child: MyApp()));
}

//------------------ UI -----------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Initial Build");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Future Provider"), centerTitle: true),
        body: Consumer(
          builder: (context, ref, child) {
            debugPrint("Build");
            final pro = ref.watch(myProvider);
            return Center(
              child: pro.when(
                skipLoadingOnRefresh: false,
                data: (data) => ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                      leading: Text(item.id.toString()),
                      title: Text(item.title),
                      subtitle: Text(item.body),
                    );
                  },
                ),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
