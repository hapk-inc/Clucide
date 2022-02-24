import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:traccia/route/my_router.gr.dart';

import 'provider/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  final crashlytics = FirebaseCrashlytics.instance;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = crashlytics.recordFlutterError;

  runApp(
    ProviderScope(
      overrides: [
        crashlyticsProvider.overrideWithValue(crashlytics),
        firebaseAppProvider.overrideWithValue(app),
        fireStoreProvider
            .overrideWithValue(FirebaseFirestore.instanceFor(app: app)),
      ],
      //observers: [],
      child: const MyApp(),
    ),
  );
}

final myRouter = MyRouter();

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PageRouteInfo userCheck() => ref.watch(userCheckProvider).when(
          data: (data) => !data
              ? const LoginRoute()
              : ref.watch(gameUserProvider).when(
                    data: (_) {
                      ref.watch(updateUserProvider);
                      return const AppStackRoute();
                    },
                    error: (error, stackTrace) {
                      //FirebaseCrashlytics.instance
                      ref
                          .read(crashlyticsProvider)
                          .recordError(error, stackTrace,
                              reason: 'Game User Error',
                              // Pass in 'fatal' argument
                              fatal: true);
                      return const NoInternetRoute();
                    },
                    loading: () => const SplashRoute(),
                  ),
          error: (error, stackTrace) {
            ref.read(crashlyticsProvider).recordError(
                  error, stackTrace,
                  reason: 'User Check Error',
                  // Pass in 'fatal' argument
                  fatal: true,
                );
            return const NoInternetRoute();
          },
          loading: () => const SplashRoute(),
        );

    return MaterialApp.router(
      // routerDelegate: myRouter.delegate(),
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: GoogleFonts.poppins(color: Colors.black87),
          bodyText2: GoogleFonts.poppins(color: Colors.black54),
          button: GoogleFonts.poppins(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ),
      ),
      routeInformationParser: myRouter.defaultRouteParser(),
      routerDelegate: /*myRouter.delegate()*/
          AutoRouterDelegate.declarative(
        myRouter,
        routes: (_) => [
          if (kDebugMode)
            userCheck()
          else
            ref.watch(inAppUpdateProvider).when(
                  data: (value) => value.updateAvailability ==
                          UpdateAvailability.updateAvailable
                      ? const AppUpdateRoute()
                      : userCheck(),
                  error: (error, stackTrace) {
                    //FirebaseCrashlytics.instance
                    ref.read(crashlyticsProvider).recordError(error, stackTrace,
                        reason: 'App Update Error',
                        // Pass in 'fatal' argument
                        fatal: true);
                    return const NoInternetRoute();
                  },
                  loading: () => const SplashRoute(),
                ),
        ],
      ),
    );
  }
}

class AppStackPage extends StatelessWidget {
  const AppStackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyRouterScreen();
  }
}
