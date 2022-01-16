import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ChangeNotifierProvider<PageNotifier> pageProvider =
    ChangeNotifierProvider<PageNotifier>(
  (_) => PageNotifier(),
);

class PageNotifier extends ChangeNotifier {
  late List<Page> _pages = [];

  List<Page> get pages => List.unmodifiable(_pages);

  bool handlePopPage(Route<dynamic> route, dynamic result) {
    final bool success = route.didPop(result);

    _pages.removeLast();
    notifyListeners();
    return success;
  }

  addNext(Page page) {
    _pages.add(page);
    notifyListeners();
  }

  replaceAll(Page page) {
    _pages = [page];
    notifyListeners();
  }

  replace(Page page) {
    _pages.add(page);
    _pages.removeAt(_pages.length - 2);
    notifyListeners();
  }
}

class MyPage<T> extends Page<T> {
  final Widget child;

  MyPage(this.child, {Object? arguments})
      : super(key: ValueKey(child), arguments: arguments);

  @override
  Route<T> createRoute(BuildContext context) =>
      MaterialPageRoute(builder: (_) => child, settings: this);
}

/*  @override
  Route<T> createRoute(BuildContext context) => child.toString() == "HowToPlay"
      ? PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
          settings: this,
        )
      : MaterialPageRoute(builder: (context) => child, settings: this);*/

/*  @override
  Route<T> createRoute(BuildContext context) => child == HowToPlay()
      ? SlideRightRoute(page: child)
      : MaterialPageRoute(builder: (context) => child, settings: this);*/

/*class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}*/
