// Define your state (the Provider)
// counter_provider.dart (you can also put this at top of main.dart for now)
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a simple integer count. Default = 0
final counterProvider = StateProvider<int>((ref) => 0);
