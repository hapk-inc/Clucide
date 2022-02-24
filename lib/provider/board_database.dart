import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:traccia/models/clue_card.dart';
import 'package:traccia/models/player.dart';
import 'package:traccia/models/player_status.dart';
import 'package:traccia/models/round.dart';

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
  late CollectionReference pStatusRef;

  BoardDatabase(this._read) {
    boardId = _read(idNotifierProvider.notifier).state;

    boardDocRef = _read(fireStoreProvider).collection('boards').doc(boardId);
    cardRef = boardDocRef.collection('cards');
    playerRef = boardDocRef.collection('players');
    roundRef = boardDocRef.collection('rounds');
    hiddenRef = boardDocRef.collection('hidden');
    pStatusRef = boardDocRef.collection('player_status');
  }

  Stream<QuerySnapshot> get allRounds {
    //final String? roundId = _read(roundIdProvider).value;
    return roundRef
        .orderBy("created_on", descending: true)
        .limit(5)
        .snapshots();
  }

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

  Stream<QuerySnapshot> get allPlayerStatus => pStatusRef.snapshots();

  Future init(InitBoard initBoard) {
    final FirebaseFirestore firebaseFirestore = _read(fireStoreProvider);
    final WriteBatch writeBatch = firebaseFirestore.batch();
    initBoard
      ..cardMap.forEach(
          (key, value) => writeBatch.set(cardRef.doc(key), value.toJson()))
      ..players.forEach((key, value) => writeBatch
        ..set(playerRef.doc(key), value)
        ..set(pStatusRef.doc(key), const PlayerStatus().toJson()))
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

  Future<List<bool>> get compareHiddenCards async {
    final List<String> ids = _read(suspectsNotifierProvider).idList;
    Future<List<bool>> answer = Future.wait(
      ids.map(
        (e) => hiddenRef.doc(e).get().then((snapshot) => snapshot.exists),
      ),
    );
    return answer;
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

  Future get createRound async {
    final String id = generateID;

    final FirebaseFirestore firebaseFirestore = _read(fireStoreProvider);
    final WriteBatch writeBatch = firebaseFirestore.batch();

    Round round = _read(suspectsNotifierProvider).initRound;

    writeBatch
      ..set(roundRef.doc(id), round.toJson())
      //..update(cardRef.doc(round.place), {'occupied_by': round.asking})
      ..update(boardDocRef, {"round": id});

    return writeBatch.commit();
  }

  String get generateID {
    var r = Random();
    return String.fromCharCodes(
      List.generate(13, (index) => r.nextInt(33) + 89),
    );
  }

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

  Stream<Round> gameRound(String id) => roundRef.doc(id).snapshots().map(
        (snapshot) {
          Map map = snapshot.data() as Map;
          Map<String, dynamic> json = Map<String, dynamic>.from(map);
          Round round = Round.fromJson(json);
          return round;
        },
      );

  Future updatePlayerAnswer(Round round, bool doYouHave) async {
    print("154--Running Player Answer");
    final String roundId = _read(roundIdProvider).value!;

    final answers = round.answers;
    late Round _newRound;
    if (doYouHave) {
      answers.update(round.to!, (value) => true);
      _newRound = round.copyWith(answers: answers);
    } else {
      answers.update(round.to!, (value) => false);
      final String nxtPlayer = _read(playerRoundOrderProvider(round.to!)).first;
      _newRound = nxtPlayer != round.asking
          ? round.copyWith(answers: answers, to: nxtPlayer)
          : round.copyWith(answers: answers);
    }
    print("Last line--169");
    //final String roundId = _read(roundIdProvider).value!;
    return roundRef.doc(roundId).update(_newRound.toJson());
  }

  Future updateSelectedAnswer(String selectedAnswer) {
    final String roundId = _read(roundIdProvider).value!;
    return roundRef.doc(roundId).update({"round_answer": selectedAnswer});
  }

  Future accusing(bool accusing) async {
    final String? id = _read(roundIdProvider).value!;
    if (accusing) {
      return roundRef.doc(id).update(
        {"accusing": accusing},
      );
    }
    final String uid = _read(firebaseUserProvider).uid;
    final playerId = _read(playerRoundOrderProvider(uid)).first;
    return boardDocRef.update(
      {
        "round": null,
        "currentId": playerId,
      },
    );
  }

  Future updateWinner(bool winner) {
    final String uid = _read(firebaseUserProvider).uid;

    if (winner) {
      return pStatusRef.doc(uid).update({"winner": true});
    }
    final FirebaseFirestore firebaseFirestore = _read(fireStoreProvider);
    final WriteBatch writeBatch = firebaseFirestore.batch();
    final playerId = _read(playerRoundOrderProvider(uid)).first;

    writeBatch
      ..update(pStatusRef.doc(uid), {"winner": false, "occupied_by": null})
      ..update(boardDocRef, {
        "round": null,
        "currentId": playerId,
      });
    return writeBatch.commit();
  }
}
