// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Round _$$_RoundFromJson(Map<String, dynamic> json) => _$_Round(
      asking: json['asking'] as String,
      to: json['to'] as String?,
      clues: (json['clues'] as List<dynamic>).map((e) => e as String).toList(),
      place: json['place'] as String,
      answers: (json['answers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool?),
          ) ??
          const {},
      roundAnswer: json['round_answer'] as String?,
      accusing: json['accusing'] as bool?,
    );

Map<String, dynamic> _$$_RoundToJson(_$_Round instance) => <String, dynamic>{
      'asking': instance.asking,
      'to': instance.to,
      'clues': instance.clues,
      'place': instance.place,
      'answers': instance.answers,
      'round_answer': instance.roundAnswer,
      'accusing': instance.accusing,
    };
