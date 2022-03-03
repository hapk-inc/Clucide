import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clue_card.freezed.dart';
part 'clue_card.g.dart';

enum CardType { person, weapon, place }

@freezed
class ClueCard with _$ClueCard {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory ClueCard({required String name, required CardType type}) =
      _ClueCard;

  factory ClueCard.fromJson(Map<String, dynamic> json) =>
      _$ClueCardFromJson(json);

  const ClueCard._();

  String get imagePath {
    switch (type) {
      case CardType.person:
        return "assets/avatar_icon/$name.png";
      case CardType.weapon:
        return "assets/weapons_icon/$name.png";
      case CardType.place:
        return "assets/places_icon/$name.png";
    }
  }

  String get locationPath => "assets/places/$name.jpg";

  MaterialColor get dialogColor {
    switch (name) {
      case "lift":
        return Colors.purple;
      case "bowling":
        return Colors.brown;
      case "electronics":
        return Colors.lightBlue;
      case "clothing":
        return Colors.blueGrey;
      case "parking":
        return Colors.indigo;
      case "restroom":
        return Colors.grey;
      case "supermarket":
        return Colors.deepOrange;
      case "restaurant":
        return Colors.orange;
      case "theatre":
        return Colors.red;
      default:
        return Colors.red;
    }
  }
}
