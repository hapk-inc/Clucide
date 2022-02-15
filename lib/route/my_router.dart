import 'package:auto_route/auto_route.dart';
import 'package:traccia/pages/winner.dart';
import '/pages/game_board.dart';
import '/main.dart';
import '/pages/app_update.dart';
import '/pages/dashboard.dart';
import '/pages/game_room.dart';
import '/pages/login.dart';
import '/pages/no_internet.dart';
import '/pages/splash.dart';

//const list = [SplashPage];

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(page: SplashPage),
    AutoRoute(page: LoginPage),
    AutoRoute(page: AppUpdatePage),
    AutoRoute(page: NoInternetPage),
    AutoRoute(
      page: AppStackPage,
      //initial: true,
      path: '/',
      children: [
        AutoRoute(path: '', page: DashboardPage),
        AutoRoute(path: 'room', page: GameRoomPage),
        AutoRoute(path: 'game_board', page: GameBoardPage),
        AutoRoute(path: 'winner', page: WinnerPage),
      ],
    ),
  ],
)

//flutter packages pub run build_runner build --delete-conflicting-outputs

//for freezed
//flutter pub run build_runner build
//release
//flutter build appbundle --flavor dev
class $MyRouter {}
