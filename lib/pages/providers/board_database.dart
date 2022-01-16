import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:traccia/model/round.dart';
import '/model/player.dart';
import '/model/clue_card.dart';

import 'auth.dart';
import 'board.dart';
import 'game_id.dart';
import 'init_board.dart';

final AutoDisposeProvider<BoardDatabase> boardDatabaseProvider =
    Provider.autoDispose<BoardDatabase>(
  (ref) => BoardDatabase(ref.read),
);

class BoardDatabase {
  final Reader _read;
  late String boardId;

  late DocumentReference boardDocRef;
  late CollectionReference cardRef;
  late CollectionReference playerRef;
  late CollectionReference roundRef;
  late CollectionReference hiddenRef;

  BoardDatabase(this._read) {
    boardId = _read(idNotifierProvider.notifier).state;

    boardDocRef = _read(firestoreProvider).collection('boards').doc(boardId);
    cardRef = boardDocRef.collection('cards');
    playerRef = boardDocRef.collection('players');
    roundRef = boardDocRef.collection('rounds');
    hiddenRef = boardDocRef.collection('hidden');
  }

  Future get updateWinnerFalse => boardDocRef.update({"winner": false});

  Future<Map> get boardMap => boardDocRef.get().then(
        (DocumentSnapshot snapshot) async {
          Map map = snapshot.data() as Map;
          map['hidden'] = await hiddenCards;
          return map;
        },
      );

  Future<List<String>> get hiddenCards => hiddenRef.get().then(
        (QuerySnapshot querySnapshot) {
          final List<String> list = querySnapshot.docs.fold(
            [],
            (prev, snapshot) {
              prev.add(snapshot.id);
              return prev;
            },
          );
          return list;
        },
      );

  Future init(InitBoard initBoard) {
    final FirebaseFirestore firebaseFirestore = _read(firestoreProvider);
    final WriteBatch writeBatch = firebaseFirestore.batch();
    initBoard
      ..cardMap.forEach(
          (key, value) => writeBatch.set(cardRef.doc(key), value.toJson()))
      ..players
          .forEach((key, value) => writeBatch.set(playerRef.doc(key), value))
      ..hidden.forEach(
          (key, value) => writeBatch.set(hiddenRef.doc(key), value.toJson()));
    writeBatch
      ..set(boardDocRef, {'currentId': initBoard.players.keys.first})
      ..update(
          firebaseFirestore.collection('rooms').doc(boardId), {"start": true});

    return writeBatch.commit();
  }

  Stream<String> get currentId => boardDocRef.snapshots().map(
        (DocumentSnapshot snapshot) => snapshot.get('currentId') as String,
      );

  Stream<String?> placeOccupied(String id) => cardRef.doc(id).snapshots().map(
        (snapshot) {
          Map _m = snapshot.data() as Map;
          String? occupied =
              _m.containsKey('occupied_by') ? _m['occupied_by'] : null;
          return occupied;
        },
      );

  Future<Map<String, ClueCard>> get cards => cardRef.get().then(
        (snapshot) {
          final docs = snapshot.docs;
          return docs.fold<Map<String, ClueCard>>(
            {},
            (prevMap, eDoc) {
              final map = Map<String, dynamic>.from(eDoc.data() as Map);
              final ClueCard clueCard = ClueCard.fromJson(map);
              final a = eDoc.id;
              prevMap[a] = clueCard;
              return prevMap;
            },
          );
        },
      );

  Stream<String?> get roundId {
    late BehaviorSubject<String?> subject;
    subject = BehaviorSubject(
      onListen: () => boardDocRef.snapshots().listen(
        (snapshot) {
          if (!snapshot.exists) {
            subject.addError("Board not exist");
          } else {
            Map map = snapshot.data() as Map;
            if (map.containsKey('round')) {
              String? id = map['round'] as String?;
              subject.add(id);
            }
          }
        },
      ),
    );
    return subject.stream;
  }

  Future get createRound async {
    final String id = generateID;

    final FirebaseFirestore firebaseFirestore = _read(firestoreProvider);
    final WriteBatch writeBatch = firebaseFirestore.batch();

    Round round = _read(suspectsNotifierProvider).initRound;

    writeBatch
      ..set(roundRef.doc(id), round.toJson())
      ..update(cardRef.doc(round.place), {'occupied_by': round.asking})
      ..update(boardDocRef, {"round": id});

    return writeBatch.commit();
  }

  String get generateID {
    var r = Random();
    return String.fromCharCodes(
      List.generate(13, (index) => r.nextInt(33) + 89),
    );
  }

  Future<Map<String, Player>> get players =>
      playerRef.orderBy('player_no').get().then(
        (snapshots) {
          final docs = snapshots.docs;

          Map<String, Player> pMap = docs.fold(
            <String, Player>{},
            (map, snap) {
              Player p = Player.fromJson(
                  Map<String, dynamic>.from(snap.data() as Map));
              map[snap.id] = p;
              return map;
            },
          );
          return pMap;
        },
      );

  Stream<Round> round(String id) => roundRef.doc(id).snapshots().map(
        (snapshot) {
          Map map = snapshot.data() as Map;
          Map<String, dynamic> json = Map<String, dynamic>.from(map);
          Round round = Round.fromJson(json);
          return round;
        },
      );

  Future accusing(bool accusing) async {
    final String? id = await _read(roundIdProvider.future);
    if (accusing) {
      return roundRef.doc(id).update(
        {"accusing": accusing},
      );
    }
    final playerId = _read(suspectsNotifierProvider).nextActive;
    return boardDocRef.update(
      {
        "round": null,
        "currentId": playerId,
      },
    );
  }

  Future updateAnswer(bool answer) async {
    final FirebaseFirestore firebaseFirestore = _read(firestoreProvider);

    final String? id = await _read(roundIdProvider.future);
    final DocumentReference documentReference = roundRef.doc(id);
    return firebaseFirestore.runTransaction(
      (transaction) async {
        final DocumentSnapshot snapshot =
            await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        Map map = snapshot.data() as Map;
        Map<String, dynamic> json = Map<String, dynamic>.from(map);
        Round round = Round.fromJson(json);
        final user = _read(firebaseUserProvider);
        round.answers.update(user.uid, (_) => answer);
        if (!answer) {
          String? _to = _read(suspectsNotifierProvider).nextPlayer;
          if (_to == round.asking) _to = null;
          round = round.copyWith(to: _to);
        }

        return transaction.update(documentReference, round.toJson());
      },
    );
  }

  Future updateRoundAnswer(String cardId) async {
    final String? id = await _read(roundIdProvider.future);
    return roundRef.doc(id).update({"round_answer": cardId});
  }

  Future emptyPlaceOccupied(String id) =>
      cardRef.doc(id).update({"occupied_by": null});

  Future<List<bool>> get compareHiddenCards async {
    final List<String> ids = _read(suspectsNotifierProvider).idList;
    Future<List<bool>> answer = Future.wait(
      ids.map(
        (e) => hiddenRef.doc(e).get().then((snapshot) => snapshot.exists),
      ),
    );
    return answer;
  }

  Future updateWinner(bool winner) {
    final String user = _read(firebaseUserProvider).uid;

    final FirebaseFirestore firebaseFirestore = _read(firestoreProvider);
    final WriteBatch writeBatch = firebaseFirestore.batch();

    if (winner) {
      writeBatch.update(
        boardDocRef,
        {
          "winner": true,
          "round": null,
        },
      );
    } else {
      final playerId = _read(suspectsNotifierProvider).nextPlayer;
      final String place = _read(placeOccupiedNotifier.notifier).state;
      writeBatch
        ..update(playerRef.doc(user), {"isActive": false})
        ..update(cardRef.doc(place), {"occupied_by": null})
        ..update(
          boardDocRef,
          {
            "round": null,
            "currentId": playerId,
          },
        );
    }
    return writeBatch.commit();
  }

  Stream<bool> get gameWinner {
    late BehaviorSubject<bool> subject;
    subject = BehaviorSubject(
      onListen: () => boardDocRef.snapshots().listen(
        (DocumentSnapshot snapshot) {
          Map map = snapshot.data() as Map;
          if (map.containsKey('winner')) {
            subject.add(map['winner']);
            subject.close();
          }
        },
      ),
    );

    return subject.stream;
  }

  Stream<List<String>> get inActivePlayer {
    late BehaviorSubject<List<String>> subject;
    subject = BehaviorSubject(
      onListen: () =>
          playerRef.where("isActive", isEqualTo: false).snapshots().listen(
        (QuerySnapshot querySnapshot) {
          final docs = querySnapshot.docs;
          final List<String> ids = docs.fold(
            [],
            (prev, snapshot) {
              prev.add(snapshot.id);
              return prev;
            },
          );
          if (ids.isNotEmpty) {
            subject.add(ids);
          }
        },
      ),
    );
    return subject.stream;
  }
}
