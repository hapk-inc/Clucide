import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Player({
    required String as,
    required String name,
    required int playerNo,
    required int cardCount,
    required List<String> clues,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  const Player._();

  String get asImage => "assets/avatar_icon/$as.png";
}
