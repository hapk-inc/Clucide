import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final instructionPageController = PageController();

final indexStateProvider = StateNotifierProvider<IndexState, int>(
  (_) => IndexState(),
);

final offsetStateNotifier = ChangeNotifierProvider<OffsetState>(
  (_) => OffsetState(instructionPageController),
);

class IndexState extends StateNotifier<int> {
  IndexState() : super(0);
}

class OffsetState extends ChangeNotifier {
  double _page = 0;

  double get page => _page;

  OffsetState(PageController controller) {
    controller.addListener(
      () {
        _page = controller.page ?? 0;
        notifyListeners();
      },
    );
  }
}
