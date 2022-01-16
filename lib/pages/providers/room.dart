import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traccia/model/game_user.dart';
import '/model/room.dart';

import 'auth.dart';
import 'board_database.dart';
import 'init_board.dart';
import 'room_database.dart';

final AutoDisposeFutureProvider<String> createRoomProvider =
    FutureProvider.autoDispose<String>(
  (ref) {
    final firebaseUser = ref.watch(firebaseUserProvider);
    final roomDatabase = ref.read(roomDatabaseProvider);
    final GameUser gameUser = ref.watch(gameUserProvider).value ??
        GameUser(name: firebaseUser.displayName ?? "Unknown");
    return roomDatabase.createRoom(firebaseUser, gameUser);
  },
);

final AutoDisposeFutureProvider joinRoomProvider = FutureProvider.autoDispose(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);

    final user = ref.read(firebaseUserProvider);
    final GameUser gameUser = ref.watch(gameUserProvider).value!;
    return roomDatabase.joinRoom(user, gameUser);
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
