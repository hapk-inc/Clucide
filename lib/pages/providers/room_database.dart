import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '/model/game_user.dart';
import '/model/room.dart';

import 'auth.dart';
import 'game_id.dart';

final AutoDisposeProvider<RoomDatabase> roomDatabaseProvider =
    Provider.autoDispose<RoomDatabase>(
  (ref) {
    final db = ref.read(firestoreProvider);
    final String? id = ref.read(idNotifierProvider.notifier).state;
    return RoomDatabase(db, id: id);
  },
);

const String _players = "players";
const String _isActive = "isActive";

class RoomDatabase {
  late CollectionReference reference;
  late FirebaseFirestore firestore;
  final String? id;

  RoomDatabase(FirebaseFirestore firebaseFirestore, {this.id}) {
    firestore = firebaseFirestore;
    reference = firebaseFirestore.collection('rooms');
  }

  Stream<bool> get startRoom {
    late BehaviorSubject<bool> behaviorSubject;
    behaviorSubject = BehaviorSubject<bool>(
      onListen: () => reference.doc(id).snapshots().listen(
        (DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            Map map = documentSnapshot.data() as Map;
            if (map.containsKey('start')) {
              bool start = documentSnapshot.get('start') as bool;
              behaviorSubject.add(start);
              if (start) {
                behaviorSubject.close();
              }
            }
          }
        },
      ),
    );
    return behaviorSubject.stream;
  }

  Stream<Map> get players {
    late BehaviorSubject<Map> behaviorSubject;
    behaviorSubject = BehaviorSubject<Map>(
      onListen: () => reference
          .doc(id)
          .collection(_players)
          .where(_isActive, isEqualTo: true)
          //.orderBy('timestamp')
          .limit(6)
          .snapshots()
          .listen(
        (QuerySnapshot snapshot) {
          final list = snapshot.docs;

          final Map _map = list.fold<Map>(
            {},
            (previousValue, element) {
              previousValue[element.id] = element.data();
              return previousValue;
            },
          );
          behaviorSubject.add(_map);
        },
      ),
    );
    return behaviorSubject.stream;
  }

  Future<String?> validateCode(int code) =>
      reference.where('room_code', isEqualTo: code).get().then(
        (QuerySnapshot querySnapshot) {
          return querySnapshot.docs.isEmpty
              ? null
              : querySnapshot.docs.first.id;
        },
      );

  Future<String> createRoom(User user, GameUser gameUser) async =>
      reference.add(
        <String, dynamic>{
          "room_code": 100000 + Random.secure().nextInt(999999 - 100000),
          "creator": user.uid,
          "creator_name": gameUser.name,
        },
      ).then((value) => value.id);

  static String get randomGuestName =>
      "Guest${1000 + Random().nextInt(9999 - 1000)}";

  Future joinRoom(User user, GameUser gameUser) =>
      reference.doc(id).collection(_players).doc(user.uid).set(
            joinUser(gameUser.name),
          );

  Future joinAnonymous(String user) =>
      reference.doc(id).collection(_players).add(joinUser(user));

  joinUser(String user) => <String, dynamic>{
        "isActive": true,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "name": user
      };

  Future<Room> get room => reference.doc(id).get().then(
        (value) {
          Map map = value.data() as Map;
          Map<String, dynamic> json = Map<String, dynamic>.from(map);
          Room room = Room.fromJson(json);
          return room;
        },
      );
}
