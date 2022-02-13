import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_user.freezed.dart';
part 'game_user.g.dart';

@freezed
class GameUser with _$GameUser {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory GameUser({
    required String name,
    required int id,
    required bool isActive,
    required int lastPlayed,
    String? playing,
  }) = _GameUser;

  factory GameUser.fromJson(Map<String, dynamic> json) =>
      _$GameUserFromJson(json);
}
