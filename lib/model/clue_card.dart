import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clue_card.freezed.dart';
part 'clue_card.g.dart';

enum CardType { person, weapon, place }

@freezed
class ClueCard with _$ClueCard {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory ClueCard(
      {required String name,
      required CardType type,
      String? occupiedBy}) = _ClueCard;

  factory ClueCard.fromJson(Map<String, dynamic> json) =>
      _$ClueCardFromJson(json);
}
