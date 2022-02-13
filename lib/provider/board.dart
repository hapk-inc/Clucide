import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traccia/models/clue_card.dart';
import 'package:traccia/models/player.dart';
import 'package:traccia/models/round.dart';
import 'package:traccia/provider/auth.dart';

import 'board_database.dart';

const List<String> persons = [
  ...["adam", "cheng", "emily"],
  ...["ken", "regina", "richard"]
];

const List<String> weapons = [
  ...["gun", "knife", "plug"],
  ...["saw", "shovel", "syringe"]
];

const List<String> groundFloor = ["parking", "lift", "restroom"];
const List<String> firstFloor = ["supermarket", "clothing", "electronics"];
const List<String> secondFloor = ["theatre", "bowling", "restaurant"];

const List<String> places = [...groundFloor, ...firstFloor, ...secondFloor];

final currentIDProvider = StreamProvider.autoDispose<String>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.currentId;
  },
);

enum RoundStatus {
  teacher,
  student,
  studentAnswered,
  teacherStudent,
  teacherStudentAnswered,
  //noAction
}

final roundStatusProvider = Provider.autoDispose.family<RoundStatus?, Round>(
  (ref, r) {
    final String uid = ref.read(firebaseUserProvider).uid;
    if (r.asking == uid || r.to == uid) {
      if (r.asking == r.to) {
        return r.answers[uid] == null
            ? RoundStatus.teacherStudent
            : RoundStatus.teacherStudentAnswered;
      } else {
        return r.asking == uid
            ? RoundStatus.teacher
            : r.answers[uid] == null
                ? RoundStatus.student
                : RoundStatus.studentAnswered;
      }
    }
    return null;
  },
);

final AutoDisposeFutureProvider<Map<String, Player>> playersProvider =
    FutureProvider.autoDispose<Map<String, Player>>(
  (ref) => ref.read(boardDatabaseProvider).players,
);

final AutoDisposeFutureProvider<Map<String, ClueCard>> cardsProvider =
    FutureProvider.autoDispose<Map<String, ClueCard>>(
  (ref) {
    final BoardDatabase boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.cards;
  },
);

final mePlayerProvider = FutureProvider.autoDispose(
  (ref) async {
    final players = await ref.read(boardDatabaseProvider).players;
    final String uid = ref.watch(firebaseUserProvider).uid;
    return players[uid];
  },
);

final suspectsNotifierProvider =
    ChangeNotifierProvider((ref) => SuspectNotifier(ref.read));

final createRoundProvider = FutureProvider.autoDispose(
  (ref) => ref.read(boardDatabaseProvider).createRound,
);

final AutoDisposeStreamProvider<String?> roundIdProvider =
    StreamProvider.autoDispose<String?>(
  (ref) {
    final BoardDatabase boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.roundId;
  },
);

final gameRoundProvider = StreamProvider.autoDispose<Round?>(
  (ref) {
    final roundId = ref.watch(roundIdProvider).value;

    return roundId == null
        ? Stream.value(null)
        : ref.watch(boardDatabaseProvider).gameRound(roundId);
  },
);

final playerRoundOrderProvider =
    Provider.autoDispose.family<List<String>, String>(
  (ref, id) {
    final Map<String, Player> players = ref.watch(playersProvider).value!;
    if (players.length == 1) return [id];
    final List<String> ids = players.keys.toList();
    final int userIndex = ids.indexOf(id);
    return [
      ...ids.getRange(userIndex + 1, ids.length),
      if (userIndex != 0) ...ids.getRange(0, userIndex)
    ];
  },
);

final AutoDisposeFutureProvider<Map> boardRefProvider =
    FutureProvider.autoDispose<Map>(
  (ref) => ref.read(boardDatabaseProvider).boardMap,
);

final allRoundsProvider =
    StreamProvider((ref) => ref.read(boardDatabaseProvider).allRounds);

final allPlayerStatusProvider = StreamProvider.autoDispose(
    (ref) => ref.read(boardDatabaseProvider).allPlayerStatus);

final AutoDisposeFutureProvider<List<bool>> compareHiddenCardsProvider =
    FutureProvider.autoDispose<List<bool>>(
  (ref) => ref.read(boardDatabaseProvider).compareHiddenCards,
);

final updateWinnerProvider = FutureProvider.autoDispose.family<void, bool>(
  (ref, winner) => ref.read(boardDatabaseProvider).updateWinner(winner),
);

class SuspectNotifier extends ChangeNotifier {
  final Reader _read;
  SuspectNotifier(this._read, [_person = ""]);

  String? _person;
  String? _weapon;
  String? _place;

  String? get place => _place;

  String? get weapon => _weapon;

  String? get person => _person;

  List<String> get idList => [_person ?? "", _weapon ?? "", _place ?? ""];

  Round get initRound {
    String uid = _read(firebaseUserProvider).uid;
    final List<String> playerIds = _read(playerRoundOrderProvider(uid));

    return Round(
      place: _place!,
      clues: idList,
      asking: uid,
      to: playerIds.first,
      answers: playerIds.fold(<String, bool?>{}, (map, id) {
        map[id] = null;
        return map;
      }),
      createdOn: DateTime.now().millisecondsSinceEpoch,
    );
  }

  setCard(String key, CardType type) {
    switch (type) {
      case CardType.person:
        _person = key;
        break;
      case CardType.weapon:
        _weapon = key;
        break;
      case CardType.place:
        _place = key;
        break;
    }
    notifyListeners();
  }
}

final updateRoundAnswerProvider =
    FutureProvider.autoDispose.family<void, String>(
  (ref, id) {
    final boardDatabase = ref.read(boardDatabaseProvider);

    return boardDatabase.updateSelectedAnswer(id);
  },
);
/*

final roundNotifierProvider =
    ChangeNotifierProvider.autoDispose((ref) => RoundNotifier((ref.read)));
*/
/*
class RoundNotifier extends ChangeNotifier {
  final Reader _reader;

  RoundNotifier(this._reader);

  */ /*bool _openClueChoice = false;
  bool _roundOver = false;
  bool _roundAnswered = false;
  Round? _gameRound;
  String? _selectedAnswer;

  String? get selectedAnswer => _selectedAnswer;

  void get updateSelectedAnswer {
    _reader(boardDatabaseProvider).updateSelectedAnswer(_selectedAnswer!);
  }

  set selectedAnswer(String? value) {
    if (value == null || _selectedAnswer == value) return;
    _selectedAnswer = value;
    notifyListeners();
  }

  bool get openClueChoice => _openClueChoice;

  Round? get gameRound => _gameRound;

  set gameRound(Round? value) {
    if (value == null || _gameRound == value) return;
    _gameRound = value;
    validateRound(_gameRound!);
    notifyListeners();
  }

  void validateRound(Round round) {
    print("158--Notifier Running validate Round");
    String uid = _reader(firebaseUserProvider).uid;
    _roundOver =
        round.roundAnswer != null || !round.answers.containsValue(null);
    notifyListeners();
    if (!_roundOver) {
      if (round.asking == uid) {
        if (!round.answers.containsValue(true)) {
          Map<String, Player> players =
              Map<String, Player>.from(_reader(playersProvider).value ?? {});

          List<String> studentCards = players[round.to]!.clues;

          bool doYouHave =
              round.clues.any((clue) => studentCards.contains(clue));
          _reader(boardDatabaseProvider).updatePlayerAnswer(round, doYouHave);
        }
      }
    }
  }

  bool get roundOver => _roundOver;

  bool get roundAnswered => _roundAnswered;*/ /*
}*/

final accusingProvider = FutureProvider.autoDispose.family<void, bool>(
  (ref, accusing) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.accusing(accusing);
  },
);

enum PersonAnswer { yes, no, verified, inDoubt }

final playerClueNotifier =
    ChangeNotifierProvider<PlayerClues>((_) => PlayerClues());

class PlayerClues extends ChangeNotifier {
  Map<String, Map<String, PersonAnswer>> _pClues = {};

  Map<String, Map<String, PersonAnswer>> get pClues => _pClues;

  void update(String key, String user, PersonAnswer answer) {
    _pClues.update(
      key,
      (value) {
        value.update(
          user,
          (value) => answer,
          ifAbsent: () => answer,
        );
        return value;
      },
      ifAbsent: () => {user: answer},
    );
    notifyListeners();
  }

  List<String> playerVerifiedClues(String playerId) {
    final a = _pClues.values
        .where((element) => element.containsKey(playerId))
        .where((element) => element[playerId] == PersonAnswer.verified)
        .toList();

    return _pClues.keys.where((_id) => a.contains(_pClues[_id])).toList();
  }
}
