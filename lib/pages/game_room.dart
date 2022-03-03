import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traccia/models/room.dart';
import 'package:traccia/provider/board.dart';
import 'package:traccia/provider/room.dart';
import 'package:traccia/route/my_router.gr.dart';
import 'widgets/room_widgets.dart';

class GameRoomPage extends ConsumerWidget {
  final bool isCreator;
  const GameRoomPage({Key? key, this.isCreator = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(
      strStartRoomProvider.select((value) => value.value ?? false),
      (previous, next) {
        if (next) {
          if (isCreator) {
            ref.read(createBoardProvider);
          }
          context.router.replace(const GameBoardRoute());
        }
      },
    );

    final Room? room = ref.watch(roomProvider).value;
    return Scaffold(
      floatingActionButton: isCreator && kDebugMode
          ? FloatingActionButton(
              onPressed: () => ref.read(joinAnonymousProvider),
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        actions: [if (isCreator) const StartRoomButton(click: true)],
      ),
      body: SafeArea(
        child: AnimatedContainer(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/room_mall.jpg'),
              fit: BoxFit.fitHeight,
              alignment: const Alignment(0.05, 0),
              opacity: room == null ? 1 : 0.25,
            ),
          ),
          child: room == null
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(flex: 3, child: RoomPlayers(room.creator)),
                    Flexible(flex: 7, child: RoomState(room: room)),
                  ],
                ),
          duration: const Duration(milliseconds: 5000),
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: FadeInUp(
            child: AutoSizeText(
              "${room.roomCode}",
              maxLines: 1,
              style: GoogleFonts.luckiestGuy(
                fontSize: size.height * 0.1,
                color: Colors.purple.shade700,
              ),
            ),
          ),
        ),
        //RoomPlayers(room.creator),
        Flexible(
          child: AutoSizeText(
            "${room.creatorName} created the room",
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

class RoomPlayers extends ConsumerWidget {
  final String creatorId;
  const RoomPlayers(this.creatorId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => FirebaseAnimatedList(
        query: ref.read(roomPlayerProvider),
        shrinkWrap: true,
        reverse: true,
        itemBuilder:
            (_, DataSnapshot snapshot, Animation<double> animation, __) {
          final Map map = snapshot.value as Map;
          final String name = map['name'];
          return CircleName(
            name: name,
            radiusFactor: 0.14,
            backgroundColor: snapshot.key == creatorId
                ? Colors.purple.shade100
                : Colors.purple.shade400,
            fontColor: snapshot.key != creatorId
                ? Colors.purple.shade100
                : Colors.purple,
            titleFactor: 0.04,
            subTitleFactor: 0.02,
          );
        },
      );
}

class StartRoomButton extends ConsumerWidget {
  final bool click;
  const StartRoomButton({Key? key, this.click = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return TextButton(
      onPressed: () async {
        final playerSize = await ref
            .watch(roomPlayerProvider)
            .get()
            .then((value) => value.children.length);
        if (kDebugMode) {
          ref.read(startRoomProvider);
        } else {
          if (playerSize > 2 && playerSize < 7) {
            ref.read(startRoomProvider);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Minimum 3 to 6 Players",
                  style: GoogleFonts.poppins(fontSize: size.width * 0.04),
                ),
              ),
            );
          }
        }
      },
      child: AutoSizeText(
        "START GAME",
        style: GoogleFonts.luckiestGuy(
          fontSize: size.width * 0.05,
          color: Colors.purple.shade100,
        ),
      ),
    );
  }
}
