import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateNotifierProvider idNotifierProvider =
    StateNotifierProvider<IdNotifier, String?>((_) => IdNotifier());

class IdNotifier extends StateNotifier<String?> {
  IdNotifier() : super(null);
}
