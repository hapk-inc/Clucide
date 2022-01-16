// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clue_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ClueCard _$$_ClueCardFromJson(Map<String, dynamic> json) => _$_ClueCard(
      name: json['name'] as String,
      type: $enumDecode(_$CardTypeEnumMap, json['type']),
      occupiedBy: json['occupied_by'] as String?,
    );

Map<String, dynamic> _$$_ClueCardToJson(_$_ClueCard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$CardTypeEnumMap[instance.type],
      'occupied_by': instance.occupiedBy,
    };

const _$CardTypeEnumMap = {
  CardType.person: 'person',
  CardType.weapon: 'weapon',
  CardType.place: 'place',
};
