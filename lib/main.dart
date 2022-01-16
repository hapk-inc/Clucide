import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/auth_check.dart';
import 'pages/providers/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  runApp(
    ProviderScope(
      overrides: [
        firebaseAppProvider.overrideWithValue(app),
        firestoreProvider
            .overrideWithValue(FirebaseFirestore.instanceFor(app: app)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Clucide",
        theme: ThemeData(
          textTheme: TextTheme(
            bodyText1: GoogleFonts.poppins(),
            bodyText2: GoogleFonts.poppins(),
          ),
        ),
        home: const AuthCheck(),
      );
}
