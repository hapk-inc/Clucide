// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Player _$$_PlayerFromJson(Map<String, dynamic> json) => _$_Player(
      as: json['as'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      playerNo: json['player_no'] as int,
      cardCount: json['card_count'] as int,
      clues: (json['clues'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_PlayerToJson(_$_Player instance) => <String, dynamic>{
      'as': instance.as,
      'name': instance.name,
      'is_active': instance.isActive,
      'player_no': instance.playerNo,
      'card_count': instance.cardCount,
      'clues': instance.clues,
    };
