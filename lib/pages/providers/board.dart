import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traccia/model/round.dart';
import 'package:traccia/pages/providers/auth.dart';
import '/model/player.dart';
import '/model/clue_card.dart';

import 'board_database.dart';

const List<String> persons = [
  ...["adam", "cheng", "emily"],
  ...["ken", "regina", "richard"]
];

const List<String> weapons = [
  ...["gun", "knife", "plug"],
  ...["saw", "shovel", "syringe"]
];

const List<String> places = [
  ...["parking", "lift", "supermarket"],
  ...["restroom", "clothing", "electronics"],
  ...["theatre", "bowling", "restaurant"]
];

final AutoDisposeFutureProvider<Map<String, ClueCard>> cardsProvider =
    FutureProvider.autoDispose<Map<String, ClueCard>>(
  (ref) {
    final BoardDatabase boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.cards;
  },
);

final AutoDisposeFutureProvider<Map<String, Player>> playersProvider =
    FutureProvider.autoDispose<Map<String, Player>>(
  (ref) => ref.read(boardDatabaseProvider).players,
);

final currentIDProvider = StreamProvider.autoDispose<String>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.currentId;
  },
);

final placeOccupiedProvider =
    StreamProvider.autoDispose.family<String?, String>(
  (ref, id) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.placeOccupied(id);
  },
);

final AutoDisposeStreamProvider<String?> roundIdProvider =
    StreamProvider.autoDispose<String?>(
  (ref) {
    final BoardDatabase boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.roundId;
  },
);

final myDataProvider = Provider.autoDispose(
  (ref) {
    final User user = ref.read(firebaseUserProvider);
    final Map<String, Player>? map = ref.watch(playersProvider).value;
    return map == null ? null : map[user.uid];
  },
);

final expansionTileProvider = StateNotifierProvider.autoDispose
    .family<ExpansionTileNotifier, bool, String>(
        (ref, id) => ExpansionTileNotifier());

class ExpansionTileNotifier extends StateNotifier<bool> {
  ExpansionTileNotifier() : super(false);
}

final createRoundProvider = FutureProvider.autoDispose(
  (ref) => ref.read(boardDatabaseProvider).createRound,
);

final roundProvider = StreamProvider.autoDispose<Round?>(
  (ref) {
    final roundId = ref.watch(roundIdProvider).value;

    return roundId == null
        ? Stream.value(null)
        : ref.watch(boardDatabaseProvider).round(roundId);
  },
);

final accusingProvider = FutureProvider.autoDispose.family<void, bool>(
  (ref, accusing) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.accusing(accusing);
  },
);

enum RoundStatus {
  teacher,
  student,
  studentAnswered,
  teacherStudent,
  teacherStudentAnswered,
  noAction
}

final roundStatusProvider = Provider.autoDispose.family<RoundStatus, Round>(
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
    return RoundStatus.noAction;
  },
);

final updateAnswerProvider = FutureProvider.autoDispose.family<void, bool>(
  (ref, answer) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.updateAnswer(answer);
  },
);
final updateRoundAnswerProvider =
    FutureProvider.autoDispose.family<void, String>(
  (ref, id) {
    final boardDatabase = ref.read(boardDatabaseProvider);

    return boardDatabase.updateRoundAnswer(id);
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

final placeOccupiedNotifier =
    StateNotifierProvider<PlaceOccupied, String>((_) => PlaceOccupied());

class PlaceOccupied extends StateNotifier<String> {
  PlaceOccupied() : super("");
}

final boardInActivePlayerNotifier = StreamProvider<List<String>>(
  (ref) => ref.read(boardDatabaseProvider).inActivePlayer,
);

final emptyPlaceOccupiedProvider = FutureProvider.autoDispose
    .family<void, String>(
        (ref, id) => ref.read(boardDatabaseProvider).emptyPlaceOccupied(id));

final AutoDisposeFutureProvider<List<bool>> compareHiddenCardsProvider =
    FutureProvider.autoDispose<List<bool>>(
  (ref) => ref.read(boardDatabaseProvider).compareHiddenCards,
);

final updateWinnerProvider = FutureProvider.autoDispose.family<void, bool>(
  (ref, winner) => ref.read(boardDatabaseProvider).updateWinner(winner),
);

final AutoDisposeStreamProvider<bool> gameWinnerProvider =
    StreamProvider.autoDispose<bool>(
  (ref) => ref.read(boardDatabaseProvider).gameWinner,
);

final AutoDisposeFutureProvider updateWinnerFalseProvider =
    FutureProvider.autoDispose(
  (ref) => ref.read(boardDatabaseProvider).updateWinnerFalse,
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
}

final AutoDisposeFutureProvider<Map> boardRefProvider =
    FutureProvider.autoDispose<Map>(
  (ref) => ref.read(boardDatabaseProvider).boardMap,
);

final suspectsNotifierProvider =
    ChangeNotifierProvider((ref) => SuspectNotifier(ref.read));

class SuspectNotifier extends ChangeNotifier {
  final Reader _read;

  String? _person;
  String? _weapon;
  String? _place;

  SuspectNotifier(this._read);

  String? get place => _place;

  String? get weapon => _weapon;

  String? get person => _person;

  setCard(ClueCard clueCard) {
    final map = _read(cardsProvider).value;
    switch (clueCard.type) {
      case CardType.person:
        _person = map!.keys.firstWhere((id) => map[id] == clueCard);
        break;
      case CardType.weapon:
        _weapon = map!.keys.firstWhere((id) => map[id] == clueCard);
        break;
      case CardType.place:
        _place = map!.keys.firstWhere((id) => map[id] == clueCard);
        break;
    }

    notifyListeners();
  }

  bool validateClick(MapEntry<String, ClueCard> mapEntry) {
    switch (mapEntry.value.type) {
      case CardType.person:
        return _person == mapEntry.key;
      case CardType.weapon:
        return _weapon == mapEntry.key;
      case CardType.place:
        return _place == mapEntry.key;
    }
  }

  bool get withOutPlace => _person != null && _weapon != null;
  bool get withPlace => withOutPlace && _place != null;

  List<String> get idList => [_person!, _weapon!, _place!];

  bool containsId(String id) =>
      [_person ?? "", _weapon ?? "", _place ?? ""].contains(id);

  Round get initRound {
    String uid = _read(firebaseUserProvider).uid;
    final List<String> playerIds = _read(playerRoundOrderProvider(uid));

    return Round(
      place: _place!,
      clues: idList,
      asking: uid,
      to: nextPlayer,
      answers: playerIds.fold(<String, bool?>{}, (map, id) {
        map[id] = null;
        return map;
      }),
    );
  }

  String get nextPlayer {
    final List<String> state = _read(playersProvider).value!.keys.toList();
    if (state.length == 1) return state.first;
    /*final List<String> inActiveIds =
        _read(boardInActivePlayerNotifier).value ?? [];
    state.removeWhere((id) => inActiveIds.contains(id));*/
    //state.removeWhere((element) => false)
    final String uid = _read(firebaseUserProvider).uid;
    if (state.last == uid) return state.first;
    final int myIndex = state.indexOf(uid);
    return state[myIndex + 1];
  }

  String get nextActive {
    final List<String> state = _read(playersProvider).value!.keys.toList();
    if (state.length == 1) return state.first;
    final List<String> inActiveIds =
        _read(boardInActivePlayerNotifier).value ?? [];
    state.removeWhere((id) => inActiveIds.contains(id));
    //state.removeWhere((element) => false)
    final String uid = _read(firebaseUserProvider).uid;
    if (state.last == uid) return state.first;
    final int myIndex = state.indexOf(uid);
    return state[myIndex + 1];
  }
}
