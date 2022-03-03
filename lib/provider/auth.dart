import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:traccia/models/game_user.dart';

final firebaseAppProvider = Provider<FirebaseApp>(
  (_) => throw UnimplementedError(),
);

final crashlyticsProvider =
    Provider<FirebaseCrashlytics>((_) => throw UnimplementedError());

final Provider<Auth> authProvider = Provider<Auth>(
  (ref) {
    return Auth(ref.read);
  },
);

final Provider<FirebaseFirestore> fireStoreProvider =
    Provider<FirebaseFirestore>(
  (_) => throw UnimplementedError(),
);

final Provider<FirebaseDatabase> databaseProvider =
    Provider<FirebaseDatabase>((ref) => FirebaseDatabase.instance);

final inAppUpdateProvider = FutureProvider.autoDispose<AppUpdateInfo>(
  (_) async => InAppUpdate.checkForUpdate(),
);

enum AuthMethod { gmail, phone, guest }

final remoteConfigProvider =
    FutureProvider<RemoteConfig>((_) => RemoteConfig.instance);

final StreamProvider<bool> userCheckProvider = StreamProvider<bool>(
  (ref) {
    final auth = ref.read(authProvider);
    return auth.userCheck;
  },
);

final AutoDisposeFutureProviderFamily anonymousProvider =
    FutureProvider.autoDispose.family<void, String>(
  (ref, name) async {
    final auth = ref.read(authProvider);

    ref.watch(playerNameNotifier.notifier).updateName(name);
    return auth.signInAnonymous(name: name);
  },
);

final Provider<User> firebaseUserProvider = Provider<User>(
  (ref) {
    final Auth auth = ref.watch(authProvider);
    return auth.currentUser!;
  },
);

final playerNameNotifier = StateNotifierProvider<PlayerName, String>(
  (_) => PlayerName(),
);

class PlayerName extends StateNotifier<String> {
  PlayerName() : super("");

  void updateName(String string) => state = string;
}

final AutoDisposeFutureProvider signOutProvider = FutureProvider.autoDispose(
  (ref) async {
    final Auth auth = ref.read(authProvider);

    await auth.signOut;
  },
);

final gameUserProvider = StreamProvider.autoDispose<GameUser>(
  (ref) => ref.watch(authProvider).gameUser,
);

final updateUserProvider =
    FutureProvider.autoDispose((ref) => ref.read(authProvider).updateUser);

//--Auth
class Auth {
  late FirebaseAuth _auth;
  late FirebaseFirestore firebaseFirestore;
  late CollectionReference userCollection;
  final Reader read;

  Auth(this.read) /* Auth(FirebaseApp app)*/ {
    _auth = FirebaseAuth.instanceFor(app: /*app*/ read(firebaseAppProvider));
    firebaseFirestore = read(fireStoreProvider);
    userCollection = firebaseFirestore.collection('users');
    //firebaseFirestore = FirebaseFirestore.instanceFor(app: app);
  }

  Stream<bool> get userCheck =>
      _auth.authStateChanges().map((event) => event != null);

  User? get currentUser => _auth.currentUser;

  Stream<GameUser> get gameUser =>
      userCollection.doc(currentUser!.uid).snapshots().map(
        (DocumentSnapshot documentSnapshot) {
          Map map = documentSnapshot.data() as Map;
          Map<String, dynamic> json = Map<String, dynamic>.from(map);
          return GameUser.fromJson(json);
        },
      );

  Future get updateUser => userCollection.doc(currentUser!.uid).update(
        {
          "is_active": true,
          "last_played":
              currentUser!.metadata.lastSignInTime!.millisecondsSinceEpoch,
        },
      );

  Future signInAnonymous({String name = "Guest"}) => _auth
      .signInAnonymously()
      .then(
        (_) => userCollection.doc(currentUser!.uid).set(
              GameUser(
                name: name,
                id: 10000000 + Random().nextInt(99999999 - 10000000),
                isActive: true,
                lastPlayed: DateTime.now().millisecondsSinceEpoch,
              ).toJson(),
            ),
      )
      .whenComplete(() => _auth.currentUser!.updateDisplayName(name));

  Future get signOut async => _auth.signOut();
}
