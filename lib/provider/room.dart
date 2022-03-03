import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mock_data/mock_data.dart';
import 'package:traccia/models/room.dart';

import 'room_database.dart';

final createRoomProvider = Provider.autoDispose<Future<String>>(
  (ref) {
    final roomDatabase = ref.watch(roomDatabaseProvider);
    return roomDatabase.createRoom;
  },
);

final joinRoomProvider = Provider.autoDispose(
  (ref) {
    final roomDatabase = ref.watch(roomDatabaseProvider);
    return roomDatabase.joinRoom;
  },
);

final AutoDisposeFutureProvider<Room> roomProvider =
    FutureProvider.autoDispose<Room>(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.room;
  },
);

final roomPlayerProvider = Provider.autoDispose<Query>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.playerQuery;
  },
);

final AutoDisposeFutureProvider joinAnonymousProvider =
    FutureProvider.autoDispose(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.joinAnonymous(mockName());
  },
);

final AutoDisposeStreamProvider<bool> strStartRoomProvider =
    StreamProvider.autoDispose<bool>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.strStartRoom;
  },
);

final lastActivePlayerProvider = FutureProvider<Map>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.lastActive;
  },
);

final startRoomProvider = FutureProvider.autoDispose(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.startRoomTrue;
  },
);

/*
import 'dart:collection';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traccia/models/room.dart';

import 'board_database.dart';
import 'init_board.dart';
import 'room_database.dart';

final AutoDisposeFutureProvider<String> createRoomProvider =
    FutureProvider.autoDispose<String>(
  (ref) async {
    try {
      final roomDatabase = ref.watch(roomDatabaseProvider);
      return await roomDatabase.createRoom;
    } catch (e) {
      return "";
    }
  },
);

final AutoDisposeFutureProvider joinRoomProvider = FutureProvider.autoDispose(
  (ref) {
    final roomDatabase = ref.watch(roomDatabaseProvider);
    return roomDatabase.joinRoom;
  },
);

final AutoDisposeFutureProvider<Room> roomProvider =
    FutureProvider.autoDispose<Room>(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.room;
  },
);

final AutoDisposeStreamProvider roomPlayerProvider =
    StreamProvider.autoDispose<Map>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.players;
  },
);

final AutoDisposeStreamProvider<bool> startRoomProvider =
    StreamProvider.autoDispose<bool>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.startRoom;
  },
);

///////////////////////////////////////
final initBoardProvider = FutureProvider.autoDispose(
  (ref) async {
    final player = await ref.watch(roomPlayerProvider.future);
    final board = InitBoard(UnmodifiableMapView(player));
    final BoardDatabase boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.init(board);
  },
);

final AutoDisposeFutureProvider joinAnonymousProvider =
    FutureProvider.autoDispose(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.joinAnonymous("Random${1000 + Random().nextInt(8999)}");
  },
);

final FutureProviderFamily validateCodeProvider =
    FutureProvider.family<String?, String>(
  (ref, code) {
    final int _code = int.parse(code);
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.validateCode(_code);
  },
);
*/
