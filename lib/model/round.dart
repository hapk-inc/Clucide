import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'round.freezed.dart';
part 'round.g.dart';

@freezed
class Round with _$Round {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Round({
    required String asking,
    String? to,
    required List<String> clues,
    required String place,
    @Default({}) Map<String, bool?> answers,
    String? roundAnswer,
    bool? accusing,
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
}
