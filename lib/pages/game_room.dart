import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traccia/route/my_router.gr.dart';
import '/models/room.dart';
import '/provider/room.dart';
import 'package:auto_route/auto_route.dart';
import 'widgets/room_widgets.dart';

class GameRoomPage extends ConsumerWidget {
  final bool isCreator;
  const GameRoomPage({Key? key, this.isCreator = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          context.router.replace(const GameBoardRoute());
          //ref.read(pageProvider).replace(MyPage(const GameBoard()));
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
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
        child: AnimatedContainer(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/room_mall.jpg'),
              fit: BoxFit.fitHeight,
              alignment: const Alignment(0.05, 0),
              opacity: ref.watch(roomProvider).value == null ? 1 : 0.25,
            ),
          ),
          duration: const Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: ref.watch(roomProvider).value == null
                ? Container()
                : RoomState(room: ref.watch(roomProvider).value!),
          ),
        ),
      ),
    );
  }
}

class RoomState extends StatelessWidget {
  final Room room;
  const RoomState({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: FadeInUp(
            child: Text(
              "${room.roomCode}",
              style: GoogleFonts.poppins(
                fontSize: size.height * 0.1,
                color: Colors.purple.shade700,
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
              color: Colors.purple,
            ),
          ),
        ),
      ],
    );
  }
}
