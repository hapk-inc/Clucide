import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:traccia/models/game_user.dart';
import 'package:traccia/models/room.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/game_id.dart';

final AutoDisposeProvider<RoomDatabase> roomDatabaseProvider =
    Provider.autoDispose<RoomDatabase>(
  (ref) {
    return RoomDatabase(ref.read);
  },
);

const String _players = 'players';
const String _isActive = "isActive";

class RoomDatabase {
  late CollectionReference roomCollection;
  late FirebaseFirestore firestore;
  final Reader read;

  RoomDatabase(this.read) {
    firestore = read(firestoreProvider);
    roomCollection = firestore.collection('rooms');
  }
  //final String? id;

  /*RoomDatabase(FirebaseFirestore firebaseFirestore, {this.id}) {
    firestore = firebaseFirestore;
    reference = firebaseFirestore.collection('rooms');
  }*/

  /*Future<String> createRoom(User user, GameUser gameUser) async =>
      reference.add(
        <String, dynamic>{
          "room_code": 100000 + Random.secure().nextInt(999999 - 100000),
          "creator": user.uid,
          "creator_name": gameUser.name,
        },
      ).then((value) => value.id);*/

  Future<String> get createRoom {
    final String uid = read(firebaseUserProvider).uid;
    final GameUser user = read(gameUserProvider).value!;
    int newCode = 100000 + Random.secure().nextInt(999999 - 100000);
    return roomCollection
        .add(
          Room(
            roomCode: newCode,
            creator: uid,
            creatorName: user.name,
          ).toJson(),
        )
        .then((value) => value.id);
  }

/* Future joinRoom(User user, GameUser gameUser) =>
      reference.doc(id).collection(_players).doc(user.uid).set(
            joinUser(gameUser.name),
          );*/
  Future get joinRoom {
    final String uid = read(firebaseUserProvider).uid;
    final GameUser user = read(gameUserProvider).value!;
    final String roomId = read(idNotifierProvider.notifier).state;
    final WriteBatch writeBatch = firestore.batch();
    writeBatch
      ..update(firestore.collection('users').doc(uid), {'playing': roomId})
      ..set(
        roomCollection.doc(roomId).collection(_players).doc(uid),
        {
          "isActive": true,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "name": user.name
        },
      );
    return writeBatch.commit();
  }

  Future<Room> get room {
    final String roomId = read(idNotifierProvider.notifier).state;
    return roomCollection.doc(roomId).get().then(
      (value) {
        Map map = value.data() as Map;
        Map<String, dynamic> json = Map<String, dynamic>.from(map);
        Room room = Room.fromJson(json);
        return room;
      },
    );
  }

  Stream<Map> get players {
    late BehaviorSubject<Map> behaviorSubject;
    final String roomId = read(idNotifierProvider.notifier).state;

    behaviorSubject = BehaviorSubject<Map>(
      onListen: () => roomCollection
          .doc(roomId)
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

  Future joinAnonymous(String user) {
    final String id = read(idNotifierProvider.notifier).state;

    return roomCollection.doc(id).collection(_players).add(joinUser(user));
  }

  joinUser(String user) => <String, dynamic>{
        "isActive": true,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "name": user
      };

  Future<String?> validateCode(int code) =>
      roomCollection.where('room_code', isEqualTo: code).get().then(
        (QuerySnapshot querySnapshot) {
          return querySnapshot.docs.isEmpty
              ? null
              : querySnapshot.docs.first.id;
        },
      );

  Stream<bool> get startRoom {
    late BehaviorSubject<bool> behaviorSubject;
    final String roomId = read(idNotifierProvider.notifier).state;

    behaviorSubject = BehaviorSubject<bool>(
      onListen: () => roomCollection.doc(roomId).snapshots().listen(
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
}
