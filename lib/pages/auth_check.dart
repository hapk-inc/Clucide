import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard.dart';
import 'login.dart';
import 'providers/auth.dart';
import 'providers/pages.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final heroController = MaterialApp.createMaterialHeroController();

class AuthCheck extends ConsumerWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wPage = ref.watch(pageProvider);

    ref.listen<AsyncValue<bool>>(
      userCheckProvider,
      (_, asyncV) {
        asyncV.whenData(
          (_auth) {
            if (_auth) ref.refresh(firebaseUserProvider);
            wPage.replaceAll(
              MyPage(_auth ? const Dashboard() : const Login()),
            );
          },
        );
      },
    );
    return WillPopScope(
      onWillPop: () async => !await _navigatorKey.currentState!.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        pages: wPage.pages.isEmpty ? [MyPage(const Splash())] : wPage.pages,
        onPopPage: wPage.handlePopPage,
        observers: [heroController],
      ),
    );
  }
}
