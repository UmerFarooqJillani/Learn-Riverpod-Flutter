# <p align="center"> c_api_database_and_advanced_concepts </p>

## What is AsyncValue<T>?
- A tiny wrapper that represents one of three states:
    - AsyncLoading<T> → still loading
    - AsyncData<T> → data available
    - AsyncError<T> → failed (has error + stackTrace)
### Useful properties/methods:
1. Handle all states with `.when`
    - .when forces you to cover all states (loading/data/error) → fewer mistakes.
    ```dart
    final appVersionProvider = FutureProvider<String>((ref) async {
    // simulate network
    await Future.delayed(const Duration(milliseconds: 400));
    // throw Exception('Server down'); // uncomment to see error state
    return '1.0.3';
    });

    class VersionTile extends ConsumerWidget {
    const VersionTile({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final asyncVersion = ref.watch(appVersionProvider);

        return asyncVersion.when(
        data: (v) => ListTile(title: Text('Version: $v')),
        loading: () => const ListTile(title: Text('Version: ...'), trailing: CircularProgressIndicator()),
        error: (e, st) => ListTile(
            title: const Text('Failed to load version'),
            subtitle: Text('$e'),
            trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(appVersionProvider), // retry
            ),
        ),
        );
    }
    }
    ```
2. Use booleans (`hasError`, `isLoading`) for quick checks
    - Quick and readable for small widgets.
    ```dart
    final profileProvider = FutureProvider<Profile>((ref) async => fetchProfile());

    class ProfileHeader extends ConsumerWidget {
    const ProfileHeader({super.key});
    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final asyncProfile = ref.watch(profileProvider);

        if (asyncProfile.isLoading) {
        return const CircularProgressIndicator();
        }
        if (asyncProfile.hasError) {
        return Text('Oops: ${asyncProfile.error}');
        }

        final p = asyncProfile.requireValue; // safe: not loading/error
        return Text('Hello, ${p.name}');
    }
    }
    ```
3. Producing errors safely with `AsyncValue.guard`
    - AsyncValue.guard replaces manual **try/catch** by converting thrown errors to AsyncError(e, stackTrace) automatically.
    ```dart
    final userProvider = AsyncNotifierProvider<UserNotifier, User>(UserNotifier.new);

    class UserNotifier extends AsyncNotifier<User> {
    @override
    Future<User> build() async {
        // initial load
        return _fetchUser();
    }

    Future<void> refreshUser() async {
        // shows loading spinner (and preserves previous UI if you want—see tip below)
        state = const AsyncLoading();
        state = await AsyncValue.guard(_fetchUser); // catches errors -> AsyncError
    }

    Future<User> _fetchUser() async {
        await Future.delayed(const Duration(milliseconds: 400));
        // throw Exception('Network error');
        return const User(id: '1', name: 'Anam');
    }
    }
    ```
4. Showing errors as side-effects (SnackBar / Dialog) using `ref.listen`
    - Sometimes you don’t want to render the error in the widget tree—you want a toast/snackbar. Use ref.listen:
    ```dart
    class UserScreen extends ConsumerStatefulWidget {
    const UserScreen({super.key});
    @override
    ConsumerState<UserScreen> createState() => _UserScreenState();
    }

    class _UserScreenState extends ConsumerState<UserScreen> {
    @override
    void initState() {
        super.initState();
        ref.listen(userProvider, (prev, next) {
        if (next.hasError) {
            final msg = next.error.toString();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
        }
        });
    }

    @override
    Widget build(BuildContext context) {
        final userAsync = ref.watch(userProvider);
        return userAsync.when(
        data: (u) => Text('Hello ${u.name}'),
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Tap retry'),
        );
    }
    }
    ```
5. Preserve previous data while reloading (better UX)
    - When you re-fetch, you may want to keep showing stale data with a small spinner.
    ```dart
    Future<void> refreshUser() async {
    // Keep old data visible, but mark as loading
    final prev = state.valueOrNull;
    state = AsyncValue<User>.loading(previous: state.asData); // keep previous
    state = await AsyncValue.guard(_fetchUser);
    }

    final async = ref.watch(userProvider);
    final isRefreshing = async.isLoading && async.hasValue; // refreshing on top of data

    ```
## Networking & APIs
- Networking simply means your Flutter app talks to the internet to:
    - Fetch data (GET)
    - Send data (POST, PUT, DELETE)
    - Work with APIs (like weather data, login, user profiles, etc.)
- **Example:**
    - You open your app → it calls `https://api.openweathermap.org/...` → gets JSON like `{ "temp": 30 }` → shows **Temperature: 30°C** on screen.
    
### APIs? 
- An API (Application Programming Interface), is a set of defined rules and protocols that allow different software applications to communicate with each other. 
- It acts as an intermediary, enabling one piece of software to request services or data from another, without needing to understand the internal workings of that other system. 
#### Working with APIs
- Working with APIs in Flutter involves making HTTP requests to a server and processing the responses. Flutter provides a number of libraries for making HTTP requests, including dart:io and http.
- The `http` library is a popular choice for making HTTP requests in Flutter, as it is easy to use and provides support for HTTP methods such as GET, POST, PUT, DELETE, and more.
### What do you need to perform network calls?<br>
In Flutter, you usually use the http package (official and simple).
- pubspec.yaml: `http: ^1.2.1`
### Basic Example (Fetch Data from the Internet)<br>
**sample JSON API:**
```link
https://jsonplaceholder.typicode.com/todos/1
```
**It's return:**
```json
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```
**code:**<br>
- `Parsing` in Flutter, refers to the process of converting data from one format into a usable form within your application.
    - Example:
        ```dart
            String intString = "123";
            int number = int.parse(intString); // number will be 123

            String doubleString = "123.45";
            double decimal = double.parse(doubleString); // decimal will be 123.45
        ``` 
```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Step 1: Store fetched data
  String title = 'Loading...';

  // Step 2: Create async function to call API
  Future<void> fetchTodo() async {
    // Make GET request
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));

    // Check status code
    if (response.statusCode == 200) {
      // Convert JSON string to Map
      final data = json.decode(response.body);
      setState(() {
        title = data['title'];
      });
    } else {
      setState(() {
        title = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTodo(); // Call API on app start
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Networking Example')),
        body: Center(child: Text(title)),
      ),
    );
  }
}
```
### Let’s break it down
- `import 'package:http/http.dart' as http;` (Imports the HTTP library)
    - Why:
        - So you can use `http.get`, `http.post`, etc.
- `Uri.parse(url)` (Converts String → Uri)
    - Why:
        - The `http` library only accepts `Uri` type.
- `await http.get(...)` (Makes an asynchronous request)
    - Why:
        - It waits for the server’s response
- `response.body` (The body (text) returned by the API)
    - Why: 
        -  Usually a JSON string  
- `json.decode()` (Converts JSON → Map<String, dynamic>)
    - Why: 
        - Makes it usable in Dart
### Understanding HTTP Methods (Basic API operations)
- `GET` (Fetch data)
    - Example: 
        -  `http.get(Uri.parse('https://...'))`
- `POST` (Send new data)
    - Example: 
        -  `http.post(Uri.parse('https://...'), body: {...})`
            ```dart
            final response = await http.post(
              Uri.parse('https://jsonplaceholder.typicode.com/posts'),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({
                'title': 'Hello',
                'body': 'This is my first post',
                'userId': 1,
              }),
            );
            ```
- `PUT` (Update existing data)
    - Example: 
        -  `http.put(Uri.parse('https://...'), body: {...})`
- `Delete` (Delete data)
    - Example: 
        -  `http.delete(Uri.parse('https://...'))`
### Parsing JSON into Models (Recommended in real projects)
```dart
class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}
```
**Then:**
```dart
final data = json.decode(response.body);
final todo = Todo.fromJson(data);
print(todo.title);
```
### Use FutureBuilder to show async data in UI
```dart
Future<Todo> fetchTodo() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
  if (response.statusCode == 200) {
    return Todo.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load todo');
  }
}
// ----------------------- UI ---------------------------
FutureBuilder<Todo>(
  future: fetchTodo(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return Text('Todo: ${snapshot.data!.title}');
    }
  },
)
```
### Handling Errors and Timeouts
- AsyncValue.guard replaces manual **try/catch** by converting thrown errors to AsyncError(e, stackTrace) automatically.
```dart
try {
  final response = await http
      .get(Uri.parse('https://api.fakeurl.com'),)
      .timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    print('Data: ${response.body}');
  } else {
    print('Server error: ${response.statusCode}');
  }
} on TimeoutException {
  print('⏳ Request timed out');
} catch (e) {
  print('❌ Error: $e');
}
```
## `Dio` package
- Dio is a powerful HTTP client for Flutter & Dart, it’s like http but with more control.
- Features:
  - Base URL configuration
  - Automatic JSON parsing
  - Interceptors (for logging, tokens, retry, etc.)
  - Timeout control
  - Cancelable requests
  - Multipart uploads
  - Built-in FormData
  - Global error handling
### Why `Dio` instead of `http`?
- `http` is simple (good for learning).
  - ❌ No Interceptors
  - Limited Timeout
  - ❌ No Global base URL
  - ❌ No Retry policy
  - ❌ No Upload/download progress
  - ❌ No Request cancellation
- `dio` is professional-grade (used in large apps, APIs, admin panels, mobile dashboards, etc.)
  - ✅ Yes Interceptors
  - ✅ Flexible Timeout
  - ✅ Built-in Global base URL
  - ✅ Easy via Interceptors Retry policy
  - ✅ Built-in Upload/download progress
  - ✅ Built-in Request cancellation