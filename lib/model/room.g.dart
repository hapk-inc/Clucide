// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Room _$$_RoomFromJson(Map<String, dynamic> json) => _$_Room(
      roomCode: json['room_code'] as int,
      creator: json['creator'] as String,
      creatorName: json['creator_name'] as String,
      start: json['start'] as bool? ?? false,
    );

Map<String, dynamic> _$$_RoomToJson(_$_Room instance) => <String, dynamic>{
      'room_code': instance.roomCode,
      'creator': instance.creator,
      'creator_name': instance.creatorName,
      'start': instance.start,
    };
