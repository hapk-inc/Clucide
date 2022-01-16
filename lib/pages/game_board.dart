import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:traccia/pages/providers/room.dart';
import 'package:traccia/pages/winner.dart';
import '/model/player.dart';
import '/model/clue_card.dart';
import 'clue_round.dart';
import 'game_drawer.dart';
import 'instructions.dart';
import 'providers/auth.dart';
import 'providers/pages.dart';

import 'providers/board.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    ref.listen<String>(
      roundIdProvider.select((value) => value.value ?? ""),
      (previous, next) async {
        if (next.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * 0.05),
                topRight: Radius.circular(size.width * 0.05),
              ),
            ),
            builder: (_) => const ClueRound(),
          );
        } else {
          if (previous != null) {
            if (previous.isNotEmpty) {
              Navigator.pop(context);
            }
          }
        }
      },
    );

    ref.listen<List<String>>(
        boardInActivePlayerNotifier.select((value) => value.value ?? []),
        (previous, next) {
      Map<String, Player> players = ref.watch(playersProvider).value ?? {};
      final int totalIds = players.length;
      if (totalIds != 0) {
        final inActiveCount = next.length;
        if (totalIds - inActiveCount < 3) {
          ref.watch(updateWinnerFalseProvider);
        } else {
          for (var id in next) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                //backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.all(size.width * 0.01),
                content: Container(
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  child: Text(
                    "${players[id]!.name} is inActive",
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: size.width * 0.03),
                  ),
                ),
              ),
            );
          }
        }
      }
      /*List<String> newInActive =
          next.toSet().difference(previous!.toSet()).toList();
      final Map<String, Player> players =
          ref.watch(playersProvider).value ?? {};
      final List<String> allIds = players.keys.toList();
      final List<String> pendingIds =
          allIds.toSet().difference(next.toSet()).toList();*/
      /*if (pendingIds.length <= 2) {
        ref.watch(updateWinnerFalseProvider);
      } else {
        for (var id in newInActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              //backgroundColor: Colors.blue.shade700,
              padding: EdgeInsets.all(size.width * 0.01),
              content: Container(
                height: size.height * 0.05,
                alignment: Alignment.center,
                child: Text(
                  "${players[id]!.name} is inActive",
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: size.width * 0.03),
                ),
              ),
            ),
          );
        }
      }*/

      //List<String> playerNames = newInActive.map((e) => players)
    });

    ref.listen<bool?>(
      gameWinnerProvider.select((value) => value.value),
      (previous, next) {
        if (next != null) {
          ref
              .read(pageProvider)
              .replace(MyPage(const Winner(), arguments: next));
        }
      },
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: ref.watch(cardsProvider).when(
            data: (data) => const GameBoardState(),
            error: (error, stackTrace) => Container(),
            loading: () {
              ref.watch(playersProvider);
              return Container(color: Colors.blue);
            },
          ),
    );
  }
}

class GameBoardState extends ConsumerWidget {
  const GameBoardState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: SizedBox(
        width: size.width * 0.8,
        child: const Drawer(
          child: SafeArea(
            child: GameDrawer(),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 4,
        toolbarHeight: size.height * 0.075,
        title: Text(
          "Case No: ${ref.watch(roomProvider).value == null ? 00000 : ref.watch(roomProvider).value!.roomCode}",
          style: GoogleFonts.poppins(fontSize: size.width * 0.04),
        ),
        actions: [
          Consumer(
            builder: (_, ref, __) => TextButton(
              onPressed: () =>
                  ref.read(pageProvider).addNext(MyPage(const HowToPlay())),
              child: Text(
                "HOW TO PLAY?",
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: size.width * 0.025),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.025),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Flexible(flex: 2, child: BoardPlayers()),
            Flexible(flex: 7, child: CarouselPlaces()),
            Flexible(child: CurrentTurnName()),
          ],
        ),
      ),
    );
  }
}

class CarouselPlaces extends ConsumerWidget {
  const CarouselPlaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentId = ref.watch(currentIDProvider).maybeWhen(
          orElse: () => "",
          data: (data) => data,
        );

    final size = MediaQuery.of(context).size;

    final Map<String, Player>? players = ref.watch(playersProvider).value;

    final Map<String, ClueCard> map =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value!)
          ..removeWhere((key, value) => value.type != CardType.place);

    final String uid = ref.watch(firebaseUserProvider).uid;

    ref.listen<String>(
      placeOccupiedNotifier,
      (previous, next) {
        if (previous!.isNotEmpty) {
          ref.read(emptyPlaceOccupiedProvider(previous));
        }
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: players == null
          ? Container()
          : CarouselSlider.builder(
              itemCount: 9,
              itemBuilder: (BuildContext context, int index, int realIndex) =>
                  ref
                      .watch(placeOccupiedProvider(map.keys.elementAt(index)))
                      .when(
                        data: (_occupiedBy) {
                          final ClueCard card = map.values
                              .elementAt(index)
                              .copyWith(occupiedBy: _occupiedBy);
                          return InkWell(
                            onTap: () => _occupiedBy == null && currentId == uid
                                ? showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(size.width * 0.05),
                                        topRight:
                                            Radius.circular(size.width * 0.05),
                                      ),
                                    ),
                                    builder: (context) =>
                                        ShowModalBottomSuspect(
                                      mapEntry: map.entries.elementAt(index),
                                    ),
                                  )
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/places/${card.name}.jpg',
                                  ),
                                  fit: BoxFit.fitHeight,
                                  opacity: _occupiedBy == null ? 1 : 0.25,
                                ),
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.0125),
                              ),
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.only(
                                    bottomRight:
                                        Radius.circular(size.width * 0.01),
                                    bottomLeft:
                                        Radius.circular(size.width * 0.01),
                                  ),
                                ),
                                padding: EdgeInsets.all(size.width * 0.02),
                                height: size.height * 0.05,
                                width: double.maxFinite,
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  child: Text(
                                    card.occupiedBy == null
                                        ? toBeginningOfSentenceCase(
                                                card.name) ??
                                            ""
                                        : "${toBeginningOfSentenceCase(card.name) ?? ""} (${players[card.occupiedBy]!.name} Occupied)",
                                    style: TextStyle(
                                      fontSize: size.width * 0.04,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        error: (error, stackTrace) => Container(),
                        loading: () => Container(),
                      ),
              options: CarouselOptions(
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayAnimationDuration: const Duration(seconds: 2),
                viewportFraction: 0.75,
                height: size.height * 0.5,
              ),
            ),
    );
  }
}

class CurrentTurnName extends ConsumerWidget {
  const CurrentTurnName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final String user = ref.watch(firebaseUserProvider).uid;
    final String? currentId = ref.watch(currentIDProvider).value;

    final Map<String, Player>? players = ref.watch(playersProvider).value;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: currentId == null ||
                players == null ||
                !players.containsKey(currentId)
            ? Container()
            : currentId == user
                ? Text(
                    "Your Turn",
                    style: TextStyle(fontSize: size.width * 0.04),
                  )
                : Text.rich(
                    TextSpan(children: [
                      const TextSpan(text: "It's "),
                      TextSpan(
                        text: players[currentId]!.name + "\t",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "turn"),
                    ], style: TextStyle(fontSize: size.width * 0.025)),
                  ),
      ),
    );
  }
}

class ShowModalBottomSuspect extends ConsumerWidget {
  final MapEntry<String, ClueCard> mapEntry;
  const ShowModalBottomSuspect({required this.mapEntry, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Map<String, ClueCard> map =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value!)
          ..removeWhere((key, value) => value.type == CardType.place);
    final suspectNotifier = ref.watch(suspectsNotifierProvider);
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.02),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: ElevatedButton(
                  onPressed: suspectNotifier.withOutPlace
                      ? () {
                          //ref.read(suspectsNotifierProvider).setCard(placeMap.value);
                          ref
                              .read(suspectsNotifierProvider)
                              .setCard(mapEntry.value);
                          ref.watch(createRoundProvider);
                          Navigator.pop(context);
                          /*.then((value) {
                            print("round created");
                          }).whenComplete(() => Navigator.pop(context));*/
                        }
                      : null,
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.02),
                      child: Text(
                        "In ${toBeginningOfSentenceCase(mapEntry.value.name + "..") ?? ""}",
                        style: GoogleFonts.luckiestGuy(
                            fontSize: size.width * 0.05),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: WrapSuper(
                alignment: WrapSuperAlignment.center,
                spacing: size.width * 0.02,
                children: map.entries
                    .map(
                      (e) => TextButton(
                        onPressed: () =>
                            ref.read(suspectsNotifierProvider).setCard(e.value),
                        child: AnimatedDefaultTextStyle(
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.05,
                            fontWeight: suspectNotifier.containsId(e.key)
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: e.value.type == CardType.person
                                ? suspectNotifier.person == e.key
                                    ? Colors.red
                                    : Colors.red.shade100
                                : e.value.type == CardType.weapon
                                    ? suspectNotifier.weapon == e.key
                                        ? Colors.green
                                        : Colors.green.shade100
                                    : suspectNotifier.place == e.key
                                        ? Colors.blue
                                        : Colors.blue.shade100,
                          ),
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            toBeginningOfSentenceCase(e.value.name) ?? "",
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
    /*return FractionallySizedBox(
      heightFactor: 0.75,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        "In ${toBeginningOfSentenceCase(mapEntry.value.name + "..") ?? ""}",
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: !suspectNotifier.withOutPlace
                          ? null
                          : () {
                              //ref.read(suspectsNotifierProvider).setCard(placeMap.value);
                              ref
                                  .read(suspectsNotifierProvider)
                                  .setCard(mapEntry.value);
                              ref
                                  .read(createRoundProvider.future)
                                  .then((value) {
                                print("round created");
                              }).whenComplete(() => Navigator.pop(context));
                            },
                      child: Text(
                        "Pick a person and weapon",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.02),
                child: WrapSuper(
                  children: map.entries
                      .map(
                        (e) => InkWell(
                          onTap: () => suspectNotifier.setCard(e.value),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: suspectNotifier.validateClick(e) ? 1 : 0.5,
                            child: Text(
                              toBeginningOfSentenceCase(e.value.name) ?? "",
                              style: randomFont(Random().nextInt(6)).copyWith(
                                fontSize: size.width * 0.07,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  alignment: WrapSuperAlignment.center,
                  lineSpacing: size.height * 0.02,
                  spacing: size.width * 0.02,
                ),
              ),
            )
          ],
        ),
      ),
    );*/
  }

  TextStyle randomFont(int index) {
    switch (index) {
      case 0:
        return GoogleFonts.fredokaOne(letterSpacing: 5);
      case 1:
        return GoogleFonts.bangers(letterSpacing: 1);
      case 2:
        return GoogleFonts.pacifico(letterSpacing: 2);
      case 3:
        return GoogleFonts.orbitron();
      case 4:
        return GoogleFonts.luckiestGuy(letterSpacing: 1);
      case 5:
        return GoogleFonts.pressStart2p();
      default:
        return GoogleFonts.poppins();
    }
  }
}

class BoardPlayers extends ConsumerWidget {
  const BoardPlayers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final String currentId = ref.watch(currentIDProvider).maybeWhen(
          orElse: () => "",
          data: (data) => data,
        );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              child: Text(
                "PLAYERS",
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 9,
          child: ref.watch(playersProvider).when(
                data: (data) => RowSuper(
                  children: data.entries
                      .map(
                        (e) => AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: e.key == currentId ? 1 : 0.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                flex: 8,
                                child: InkWell(
                                  /* onTap: () => showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.blue.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(size.width * 0.05),
                                        topRight:
                                            Radius.circular(size.width * 0.05),
                                      ),
                                    ),
                                    builder: (context) => FractionallySizedBox(
                                      heightFactor: 0.3,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Which card you want to show?",
                                                style: GoogleFonts.poppins(
                                                    fontSize:
                                                        size.width * 0.0325,
                                                    fontWeight:
                                                        FontWeight.w200),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: RowSuper(
                                                children: [
                                                  "Ken",
                                                  "Saw",
                                                  "Clothing"
                                                ]
                                                    .map(
                                                      (e) => Chip(
                                                        elevation: 4,
                                                        label: Container(
                                                          width:
                                                              size.width * 0.25,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  size.width *
                                                                      0.0225),
                                                          child: Text(
                                                            e,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    size.width *
                                                                        0.0275),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),*/
                                  child: CircleAvatar(
                                    radius: size.width * 0.15,
                                    backgroundColor: Colors
                                        .primaries[Random()
                                            .nextInt(Colors.primaries.length)]
                                        .shade200,
                                    child: AspectRatio(
                                      aspectRatio: 0.95,
                                      child: Image.asset(
                                          'assets/avatar_icon/${e.value.as}.png'),
                                    ),
                                  ) /*CircleName(
                                    name: e.value.as,
                                    radiusFactor: 0.15,
                                    titleFactor: 0.15 / data.length,
                                    subTitleFactor: 0.075 / data.length,
                                    backgroundColor: Colors.blue,
                                    fontColor: Colors.white60,
                                  )*/
                                  ,
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: e.key == currentId ? 1 : 0.25,
                                  child: Text(
                                    e.value.name,
                                    style: TextStyle(
                                      fontSize: size.height * 0.0175,
                                    ),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  alignment: Alignment.centerLeft,
                  innerDistance: -size.width * (0.15 / data.length),
                ),
                error: (error, stackTrace) => Container(),
                loading: () => Container(),
              ),
        )
      ],
    );
  }
}
