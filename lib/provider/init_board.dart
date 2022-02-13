import 'dart:math';

import 'package:collection/collection.dart';
import 'package:traccia/models/clue_card.dart';

import 'board.dart';

class InitBoard {
  final UnmodifiableMapView mapView;

  InitBoard(this.mapView);

  final List<ClueCard> _hiddenCards = [
    ClueCard(name: persons[Random().nextInt(6)], type: CardType.person),
    ClueCard(name: weapons[Random().nextInt(6)], type: CardType.weapon),
    ClueCard(name: places[Random().nextInt(9)], type: CardType.place),
  ];

  final Map<String, ClueCard> cardMap = Map.fromIterables(
    List.generate(21, (_) => generateID),
    <ClueCard>{
      ...persons.map((e) => ClueCard(name: e, type: CardType.person)),
      ...places.map((e) => ClueCard(name: e, type: CardType.place)),
      ...weapons.map((e) => ClueCard(name: e, type: CardType.weapon)),
    },
  );

  static String get generateID {
    var r = Random();
    return String.fromCharCodes(
        List.generate(13, (index) => r.nextInt(33) + 89));
  }

  Map<String, ClueCard> get hidden {
    Map<String, ClueCard> map = Map<String, ClueCard>.from(cardMap);
    map.removeWhere((key, value) => !_hiddenCards.contains(value));
    return map;
  }

  Map get players {
    final _cards = Map<String, ClueCard>.from(cardMap);
    _cards.removeWhere((_, value) => _hiddenCards.contains(value));
    final remainingKeys = _cards.keys.toList()
      ..shuffle()
      ..shuffle();

    final List<String> p = List.from(persons)..shuffle();
    Map _players = Map.from(mapView);
    int i = 0;
    _players.updateAll(
      (_, value) {
        final int count = cardOrder(_players.length)[i];
        Map map = value;
        map.remove('timestamp');
        map['as'] = p[i];
        map['card_count'] = count;
        map['clues'] = remainingKeys.getRange(0, count).toList(growable: false);
        i++;
        map['player_no'] = i;
        remainingKeys.removeRange(0, count);

        return map;
      },
    );
    return _players;
  }

  static List<int> cardOrder(int playerCount) {
    switch (playerCount) {
      case 1:
        return [18];
      case 2:
        return [9, 9];
      case 3:
        return [6, 6, 6];
      case 4:
        return [4, 4, 5, 5];
      case 5:
        return [3, 3, 4, 4, 4];
      case 6:
        return [3, 3, 3, 3, 3, 3];
      default:
        return [];
    }
  }
}
