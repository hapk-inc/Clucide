import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../models/clue_card.dart';
import '../models/player.dart';
import '../models/player_status.dart';
import 'auth.dart';
import 'game_id.dart';
import 'init_board.dart';

final AutoDisposeProvider<BoardDatabase> boardDatabaseProvider =
    Provider.autoDispose<BoardDatabase>(
  (ref) => BoardDatabase(ref.read),
);

class BoardDatabase {
  final Reader read;
  late DatabaseReference boardRef;
  late String myId;

  BoardDatabase(this.read) {
    final String roomId = read(idNotifierProvider.notifier).state;
    boardRef = read(databaseProvider).ref().child('boards').child(roomId);
    myId = read(firebaseUserProvider).uid;
  }

  Future initBoard(CreateBoard board) {
    final Map cards = Map.from(board.cardMap);
    cards.updateAll((key, value) => (value as ClueCard).toJson());
    return boardRef.set(
      {
        "currentId": myId,
        "metaData": {
          "cards": cards,
          "players": board.players,
          "hidden": board.hidden.keys.toList()
        },
        "p_status": board.players.keys.fold<Map>(
          {},
          (init, key) {
            init[key] = const PlayerStatus().toJson();
            return init;
          },
        )
      },
    );
    //return Future.value(0);
  }

  Future<Map<String, ClueCard>> get cards =>
      boardRef.child('metaData/cards').once().then(
        (DatabaseEvent databaseEvent) {
          if (databaseEvent.snapshot.exists) {
            Map map = databaseEvent.snapshot.value as Map;
            map.updateAll((key, value) {
              Map _m = value as Map;
              Map<String, dynamic> json = Map<String, dynamic>.from(_m);
              ClueCard card = ClueCard.fromJson(json);
              return card;
            });
            return Map<String, ClueCard>.from(map);
          } else {
            return {};
          }
        },
      );

  Future<Map> get boardPlayers =>
      boardRef.child('metaData/players').once().then(
        (DatabaseEvent databaseEvent) {
          if (databaseEvent.snapshot.exists) {
            Map map = databaseEvent.snapshot.value as Map;
            map.updateAll((key, value) {
              Map _m = value as Map;
              Map<String, dynamic> json = Map<String, dynamic>.from(_m);
              Player player = Player.fromJson(json);
              return player;
            });
            return map;
          } else {
            return {};
          }
        },
      );

  Stream<PlayerStatus> status(String id) {
    late BehaviorSubject<PlayerStatus> behaviorSubject;
    behaviorSubject = BehaviorSubject<PlayerStatus>(
      onListen: () => boardRef.child('p_status').child(id).onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.exists) {
            Map map = event.snapshot.value as Map;
            if (!map.containsKey('winner')) {
              Map<String, dynamic> json = Map<String, dynamic>.from(map);
              PlayerStatus status = PlayerStatus.fromJson(json);
              behaviorSubject.add(status);
            }
          }
        },
      ),
    );
    return behaviorSubject.stream;
  }

  Stream<String> get currentId => boardRef
      .child('currentId')
      .onValue
      .map((event) => event.snapshot.value as String);

  Stream<String?> get roundId {
    late BehaviorSubject<String?> subject;
    subject = BehaviorSubject(
      onListen: () => boardRef.child('roundId').onValue.listen(
        (DatabaseEvent event) {
          if (!event.snapshot.exists) {
          } else {
            String _id = event.snapshot.value as String;
            subject.add(_id);
          }
        },
      ),
    );
    return subject.stream;
  }
}
