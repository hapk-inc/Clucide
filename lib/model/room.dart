import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Room({
    required int roomCode,
    required String creator,
    required String creatorName,
    @Default(false) bool start,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
