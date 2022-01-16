import 'package:animate_do/animate_do.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_board.dart';
import 'providers/pages.dart';
import 'providers/room.dart';

class GameRoom extends ConsumerWidget {
  const GameRoom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCreator = ModalRoute.of(context)!.settings.arguments as bool;
    final Size size = MediaQuery.of(context).size;

    ref.listen<bool>(
      startRoomProvider.select(
        (asyncValue) => asyncValue.maybeWhen(
          orElse: () => false,
          data: (data) => data,
        ),
      ),
      (_, next) {
        if (next) {
          ref.read(pageProvider).replace(MyPage(const GameBoard()));
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.1,
        actions: [
          if (isCreator)
            TextButton(
              onPressed: () {
                final Map rPlayers = ref.watch(roomPlayerProvider).value;
                if (kDebugMode) {
                  ref.watch(initBoardProvider);
                } else {
                  if (rPlayers.length > 2 && rPlayers.length < 7) {
                    ref.watch(initBoardProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Minimum 3 to 6 Players",
                          style:
                              GoogleFonts.poppins(fontSize: size.width * 0.04),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                "START GAME",
                style: GoogleFonts.poppins(
                  fontSize: size.height * 0.02,
                  color: Colors.white70,
                ),
              ),
            )
        ],
      ),
      floatingActionButton: isCreator && kDebugMode
          ? FloatingActionButton(
              onPressed: () => ref.read(joinAnonymousProvider),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: ref.watch(roomProvider).when(
                data: (room) => Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: FadeInUp(
                          child: Text(
                            "${room.roomCode}",
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.1,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      RoomPlayers(room.creator),
                      Flexible(
                        child: Text(
                          "${room.creatorName} created this room",
                          style: TextStyle(
                            fontSize: size.height * 0.025,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stackTrace) => Container(),
                loading: () => Container(),
              ),
        ),
      ),
    );
  }
}

class RoomPlayers extends ConsumerWidget {
  final String creatorId;
  const RoomPlayers(this.creatorId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 2,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: ref.watch(roomPlayerProvider).when(
              data: (data) {
                return WrapSuper(
                  alignment: WrapSuperAlignment.center,
                  spacing: -size.width * 0.05,
                  lineSpacing: -size.height * 0.01,
                  children: data.entries.map<Widget>(
                    (e) {
                      Map map = e.value;
                      final String name = map['name'];

                      return CircleName(
                        name: name,
                        radiusFactor: 0.15,
                        backgroundColor: e.key == creatorId
                            ? Colors.blue.shade100
                            : Colors.blue.shade400,
                        fontColor: e.key != creatorId
                            ? Colors.blue.shade100
                            : Colors.blue,
                        titleFactor: 0.05,
                        subTitleFactor: 0.015,
                      );
                    },
                  ).toList(),
                );
              },
              error: (error, stackTrace) => const CircularProgressIndicator(),
              loading: () => Container(),
            ),
      ),
    );
  }
}

class CircleName extends StatelessWidget {
  final String name;
  final double radiusFactor;
  final Color backgroundColor;
  final Color fontColor;
  final double titleFactor;
  final double subTitleFactor;

  const CircleName({
    required this.name,
    required this.radiusFactor,
    required this.backgroundColor,
    required this.fontColor,
    required this.titleFactor,
    required this.subTitleFactor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FadeInRight(
      child: SizedBox.square(
        dimension: size.height * radiusFactor,
        child: Card(
          color: backgroundColor,
          elevation: 8,
          shape: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.025),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    child: Text(
                      name.substring(0, 2).toUpperCase(),
                      style: GoogleFonts.poppins(
                        //fontSize: size.height * 0.05,
                        fontSize: size.height * titleFactor,
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: fontColor,
                        fontSize: size.height * subTitleFactor,
                        //fontSize: size.height * 0.015,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
