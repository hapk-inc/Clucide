import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_status.freezed.dart';
part 'player_status.g.dart';

@freezed
class PlayerStatus with _$PlayerStatus {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory PlayerStatus({
    @Default(true) bool isActive,
    bool? winner,
    String? occupiedAt,
    @Default([]) List<String> found,
  }) = _PlayerStatus;

  factory PlayerStatus.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatusFromJson(json);
}
