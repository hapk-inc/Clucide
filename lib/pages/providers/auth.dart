import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/model/game_user.dart';

final firebaseAppProvider =
    Provider<FirebaseApp>((_) => throw UnimplementedError());

final Provider<Auth> authProvider = Provider<Auth>(
  (ref) {
    final FirebaseApp app = ref.read(firebaseAppProvider);
    return Auth(app);
  },
);

final Provider<FirebaseFirestore> firestoreProvider =
    Provider<FirebaseFirestore>((_) => throw UnimplementedError());

final AutoDisposeFutureProviderFamily updateNameProvider =
    FutureProvider.autoDispose.family<void, String>(
  (ref, name) => ref.read(authProvider).updateName(name),
);

final AutoDisposeStreamProvider<bool> userCheckProvider =
    StreamProvider.autoDispose<bool>(
  (ref) {
    final auth = ref.read(authProvider);
    return auth.userCheck;
  },
);

final AutoDisposeFutureProviderFamily anonymousProvider =
    FutureProvider.autoDispose.family<void, String>(
  (ref, name) async {
    final auth = ref.read(authProvider);
    await auth.signInAnonymous(name: name);
  },
);

final AutoDisposeProvider<User> firebaseUserProvider =
    Provider.autoDispose<User>(
  (ref) {
    final Auth auth = ref.watch(authProvider);
    return auth.currentUser!;
  },
);

final AutoDisposeFutureProvider<GameUser?> gameUserProvider =
    FutureProvider.autoDispose<GameUser?>(
  (ref) {
    return ref.watch(authProvider).gameUser;
  },
);

final AutoDisposeFutureProvider signOutProvider = FutureProvider.autoDispose(
  (ref) async {
    final Auth auth = ref.read(authProvider);
    await auth.signOut;
  },
);

class Auth {
  final FirebaseApp firebaseApp;

  late FirebaseAuth _auth;
  late FirebaseFirestore firebaseFirestore;

  Auth(this.firebaseApp) {
    _auth = FirebaseAuth.instanceFor(app: firebaseApp);
    firebaseFirestore = FirebaseFirestore.instanceFor(app: firebaseApp);
  }

  Stream<bool> get userCheck =>
      _auth.authStateChanges().map((event) => event != null);

  User? get currentUser => _auth.currentUser;

  Future signInAnonymous({String name = ""}) =>
      _auth.signInAnonymously().then((_) => updateName(name));

  Future get signOut async => _auth.signOut();

  Future userInit(String name) =>
      firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).set(
        {"name": name},
      );

  Future updateName(String name) async {
    await _auth.currentUser!.updateDisplayName(name);
    await userInit(name);
  }

  Future<GameUser?> get gameUser => firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then(
        (DocumentSnapshot snapshot) {
          if (!snapshot.exists) return null;
          Map map = snapshot.data() as Map;
          Map<String, dynamic> json = Map<String, dynamic>.from(map);
          return GameUser.fromJson(json);
        },
      );
}
