import 'package:animate_do/animate_do.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:intl/intl.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/board.dart';
import 'package:traccia/provider/room.dart';

import '../models/clue_card.dart';
import '../models/player.dart';
import 'widgets/choice_dialog.dart';
import 'widgets/game_board_widgets.dart';

class GameBoardPage extends ConsumerStatefulWidget {
  const GameBoardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameBoardPageState();
}

const animDuration = Duration(milliseconds: 500);

class _GameBoardPageState extends ConsumerState<GameBoardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() =>
      _controller.isDismissed ? _controller.forward() : _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double maxSlide = size.width * 0.6;
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait(
          [
            ref.watch(boardPlayerProvider.future),
            ref.watch(cardsProvider.future),
          ],
        ),
        builder: (_, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) return Container(color: Colors.grey);

          return AnimatedSwitcher(
            duration: animDuration,
            child: snapshot.hasData
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      final double slide = maxSlide * _controller.value;
                      final double scale = 1 - (_controller.value * 0.3);

                      return SafeArea(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: toggle,
                              child: const BoardDrawer(),
                            ),
                            Positioned(
                              width: size.width * 0.8,
                              height: size.height,
                              right: 0,
                              child: AnimatedContainer(
                                transform: Matrix4.identity()
                                  ..translate(slide)
                                  ..scale(scale),
                                duration: const Duration(microseconds: 100),
                                child: const GameBoardState(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(),
          );
        },
      ),
    );
  }
}

final animatedListController = AnimatedListController();

class BoardDrawer extends ConsumerWidget {
  const BoardDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, ClueCard> cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final players = ref.watch(boardPlayerProvider).value ?? {};
    final me = ref.watch(firebaseUserProvider).uid;
    final status = ref.watch(playerStatusProvider(me)).value;

    if (players.isEmpty || status == null) return Container();

    final Player mePlayer = players[me];

    final List<String> idList = cards.keys.toList();

    int compareValue(String id) => mePlayer.clues.contains(id)
        ? 4
        : status.found.contains(id)
            ? 2
            : 0;

    idList.sort(
      (a, b) => compareValue(a).compareTo(compareValue(b)),
    );

    return AnimatedSwitcher(
      duration: animDuration,
      child: cards.isEmpty
          ? Container(color: Colors.grey)
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 3,
                  child: BoardDrawerHeader(me: mePlayer),
                ),
                Flexible(
                  flex: 21,
                  child: AutomaticAnimatedListView<String>(
                    list: idList,
                    listController: animatedListController,
                    itemBuilder:
                        (_, String id, AnimatedWidgetBuilderData data) =>
                            data.measuring
                                ? Container(color: Colors.blueGrey)
                                : ClueTile(
                                    clue: cards[id]!,
                                    isFound: status.found.contains(id),
                                    myClue: mePlayer.clues.contains(id),
                                  ),
                    comparator: AnimatedListDiffListComparator<String>(
                      sameItem: (x, y) => false,
                      sameContent: (x, y) => false,
                    ),
                  ),
                ),
                Flexible(child: Container(color: Colors.blueGrey.shade800))
              ],
            ),
    );
  }
}

class BoardDrawerHeader extends ConsumerWidget {
  final Player me;
  const BoardDrawerHeader({Key? key, required this.me}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final cards = ref.watch(cardsProvider).value ?? {};
    final String myCards = cards.isEmpty
        ? ""
        : me.clues
            .map((e) => toBeginningOfSentenceCase(cards[e]!.name) ?? "")
            .toList()
            .join(", ");
    return Container(
      color: Colors.blueGrey.shade800,
      child: Row(
        children: [
          Flexible(
            flex: 4,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Image.asset(me.asImage),
                ),
                Flexible(
                  flex: 3,
                  child: ListTile(
                    title: Text(
                      toBeginningOfSentenceCase(me.name) ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.05,
                        color: Colors.white70,
                      ),
                    ),
                    subtitle: AutoSizeText(
                      "You have " + myCards,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
                        color: Colors.white60,
                      ),
                      maxLines: 2,
                    ),
                    isThreeLine: true,
                  ),
                )
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class GameBoardState extends StatelessWidget {
  const GameBoardState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Flexible(flex: 2, child: AdArea()),
          Flexible(flex: 2, child: CaseTitle()),
          Flexible(flex: 1, child: BoardTab()),
          Flexible(flex: 3, child: PlayerRowList()),
          Flexible(flex: 11, child: VenueCarouselList()),
          Spacer(),
        ],
      ),
    );
  }
}

class BoardTab extends StatelessWidget {
  const BoardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.blue.shade200);
  }
}

class CaseTitle extends ConsumerWidget {
  const CaseTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    int roomCode = ref
        .watch(roomProvider)
        .maybeWhen(orElse: () => 000000, data: (room) => room.roomCode);
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(boardPlayerProvider).value ?? {});
    final String currentId = ref.watch(currentIDProvider).value ?? "";
    return Center(
      child: GridTileBar(
        title: players[currentId] == null
            ? Container()
            : AutoSizeText(
                "${toBeginningOfSentenceCase(players[currentId]!.name)}'s turn",
                style: GoogleFonts.poppins(
                  color: Colors.blueGrey.shade700,
                  fontSize: size.width * 0.05,
                ),
              ),
        subtitle: AutoSizeText.rich(
          TextSpan(text: "Case No: ", children: [
            TextSpan(
                text: roomCode.toString(),
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                )),
          ]),

          //"C.No: $roomCode",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.03,
            color: Colors.blueGrey.shade300,
          ),
        ),
        trailing: players[currentId] == null
            ? null
            : Image.asset(players[currentId]!.asImage),
      ),
    );
  }
}

final playerAnimatedListController = AnimatedListController();

class PlayerRowList extends ConsumerWidget {
  const PlayerRowList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentId = ref.watch(currentIDProvider).value ?? "";
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(boardPlayerProvider).value ?? {});
    return ListView(
      scrollDirection: Axis.horizontal,
      children: players.keys
          .map(
            (e) => PlayerRound(
              player: players[e]!,
              currentTurn: e == currentId,
            ),
          )
          .toList(),
    );
  }
}

class PlayerRound extends StatelessWidget {
  final Player player;
  final bool currentTurn;
  const PlayerRound({Key? key, required this.player, required this.currentTurn})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Flexible(
            flex: 2,
            child: AnimatedOpacity(
                duration: animDuration,
                opacity: currentTurn ? 1 : 0.25,
                child: Image.asset(player.asImage)),
          ),
          Flexible(
            child: AutoSizeText(toBeginningOfSentenceCase(player.name) ?? ""),
          )
        ],
      );
}

class VenueCarouselList extends ConsumerWidget {
  const VenueCarouselList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, ClueCard> cards =
        Map.from(ref.watch(cardsProvider).value ?? {});
    final Size size = MediaQuery.of(context).size;
    if (cards.isEmpty) return Container(color: Colors.green);
    cards.removeWhere((key, value) => value.type != CardType.place);
    return CarouselSlider.builder(
      itemCount: cards.length,
      itemBuilder: (_, now, next) {
        final String id = cards.keys.elementAt(now);
        final ClueCard clue = cards.values.elementAt(now);
        return Card(
          // color: Colors.blueGrey.shade800,
          elevation: 8,
          child: GridTile(
            footer: Container(
              color: Colors.black45,
              height: size.height * 0.05,
              alignment: Alignment.centerLeft,
              padding: Pad(horizontal: size.width * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      toBeginningOfSentenceCase(clue.name) ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () {
                        showGeneralDialog(
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionBuilder: (context, a1, a2, widget) {
                            final curvedValue =
                                Curves.easeInOutBack.transform(a1.value) - 1.0;
                            return Transform(
                              transform: Matrix4.translationValues(
                                  0.0, curvedValue * 500, 0.0),
                              child: Opacity(
                                opacity: a1.value,
                                child: ChoiceDialog(placeId: id),
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                          barrierDismissible: true,
                          barrierLabel: '',
                          context: context,
                          pageBuilder: (_, a1, a2) => const Box(),
                        );
                      },
                      child: const Text("START"),
                    ),
                  )
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(clue.locationPath),
                  fit: BoxFit.cover,
                  //opacity: 0.25,
                  alignment: clue.name == "restroom"
                      ? Alignment.centerLeft
                      : Alignment.center,
                ),
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        enlargeCenterPage: true,
        autoPlay: false,
        autoPlayAnimationDuration: const Duration(seconds: 2),
        viewportFraction: 0.775,
        height: size.height * 0.5,
      ),
    );
  }
}

/*Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: idList
                            .where((element) =>
                                cards[element]!.type == CardType.person)
                            .map(
                              (e) => SizedBox(
                                width: size.width * 0.27,
                                child: Card(
                                  elevation: 4,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex: 4,
                                        child: AnimatedOpacity(
                                            duration: animDuration,
                                            opacity: 0.2,
                                            child: Image.asset(
                                                cards[e]!.imagePath)),
                                      ),
                                      Flexible(
                                        child: AutoSizeText(
                                          camelCase(cards[e]!.name),
                                          style: GoogleFonts.poppins(
                                            fontSize: size.width * 0.02,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Flexible(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: idList
                            .where((element) =>
                                cards[element]!.type == CardType.weapon)
                            .map(
                              (e) => SizedBox(
                                width: size.width * 0.25,
                                child: Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: AnimatedOpacity(
                                              duration: animDuration,
                                              opacity: 0.2,
                                              child: Image.asset(
                                                  cards[e]!.imagePath)),
                                        ),
                                        Flexible(
                                          child: AutoSizeText(
                                            camelCase(cards[e]!.name),
                                            style: GoogleFonts.poppins(
                                              fontSize: size.width * 0.02,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                )*/

/*Row(
        children: [
          Flexible(
            child: Text(
              "In\t" + (camelCase(cards[placeId]!.name) ?? ""),
            ),
          ),
          Flexible(
              child: Image.asset(
            cards[placeId]!.imagePath,
          ))
        ],
      )*/

class AdArea extends StatelessWidget {
  const AdArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      //color: Colors.blue.shade50,
      alignment: Alignment.centerRight,
      padding: Pad(all: width * 0.02),
      child: AutoSizeText(
        "CLUCIDE",
        style: GoogleFonts.luckiestGuy(fontSize: width * 0.1),
      ),
    );
  }
}

/*import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:traccia/models/player.dart';
import 'package:traccia/models/round.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/board.dart';
import 'package:traccia/provider/board_database.dart';
import 'package:traccia/route/my_router.gr.dart';

import 'widgets/game_board_drawer.dart';
import 'widgets/game_board_panel_widgets.dart';
import 'widgets/game_board_rounds.dart';
import 'widgets/game_board_widgets.dart';

class GameBoardPage extends ConsumerStatefulWidget {
  const GameBoardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameBoardPageState();
}

const animDuration = Duration(milliseconds: 500);

class _GameBoardPageState extends ConsumerState<GameBoardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() =>
      _controller.isDismissed ? _controller.forward() : _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double maxSlide = size.width * 0.5;

    showAccuseSnackBar() => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: AccuseSnackBar()))
            .closed
            .then(
          (value) {
            print(value.name);
            ref.watch(accusingProvider(value == SnackBarClosedReason.hide));
          },
        );

    Future selectRoundAnswer(List<String> clues) => showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.width * 0.01),
              topRight: Radius.circular(size.width * 0.01),
            ),
          ),
          builder: (_) => RoundAnswerOption(clues: clues),
        );

    ref.listen<String>(
      roundIdProvider.select((value) => value.value ?? ""),
      (previous, next) async {
        if (next.isEmpty) {
          if (_panelController.isPanelOpen) {
            _panelController.close();
          }
        } else {
          if (_panelController.isPanelClosed) {
            _panelController.open();
          }
        }
      },
    );

    ref.listen<QuerySnapshot>(
      allPlayerStatusProvider.select((value) => value.value!),
      (previous, next) {
        final doc = next.docs;
        bool winnerCheck = doc.any((element) {
          final Map map = element.data() as Map;
          if (map.containsKey('winner')) {
            bool? winner = map['winner'];
            return winner ?? false;
          }
          return false;
        });
        if (winnerCheck) {
          ref.refresh(playerClueNotifier);
          context.router.replace(WinnerRoute(winner: winnerCheck));
        }
      },
    );

    ref.listen<AsyncValue<Round?>>(
      gameRoundProvider,
      (previous, async) {
        async.whenData(
          (round) async {
            try {
              if (round != null) {
                final String user = ref.watch(firebaseUserProvider).uid;

                if (round.accusing == null) {
                  if (round.answers.values.every((check) => check == false)) {
                    if (round.asking == user) {
                      for (var clueKey in round.clues) {
                        for (var playerKey in round.answers.keys) {
                          ref
                              .watch(playerClueNotifier)
                              .update(clueKey, playerKey, PersonAnswer.no);
                        }
                      }
                    }
                    if (round.asking == user) {
                      showAccuseSnackBar();
                    }
                  } else {
                    RoundStatus? roundStatus =
                        ref.watch(roundStatusProvider(round));

                    switch (roundStatus) {
                      case RoundStatus.teacher:
                        if (round.roundAnswer != null) {
                          if (round.answers.containsValue(false)) {
                            for (var clueKey in round.clues) {
                              for (var playerKey in round.answers.keys.where(
                                  (element) =>
                                      round.answers[element] == false)) {
                                ref.watch(playerClueNotifier).update(
                                    clueKey, playerKey, PersonAnswer.no);
                              }
                            }
                          }
                          ref.watch(playerClueNotifier).update(
                              round.roundAnswer!,
                              round.to!,
                              PersonAnswer.verified);

                          showAccuseSnackBar();
                        }
                        break;
                      case RoundStatus.student:
                        print("Checking Student");
                        // final Player? me =
                        //     await ref.watch(mePlayerProvider.future);
                        final Map<String, Player> players =
                            Map<String, Player>.from(
                                ref.watch(playersProvider).value ?? {});

                        final Player? me = players[user];
                        final bool doYouHave =
                            round.clues.any((clue) => me!.clues.contains(clue));
                        ref
                            .watch(boardDatabaseProvider)
                            .updatePlayerAnswer(round, doYouHave);

                        break;
                      case RoundStatus.studentAnswered:
                        if (round.roundAnswer == null &&
                            round.answers[user] == true) {
                          await selectRoundAnswer(round.clues);
                        }

                        break;

                      case RoundStatus.teacherStudent:
                        final Map<String, Player> players =
                            Map<String, Player>.from(
                                ref.watch(playersProvider).value ?? {});

                        final Player? me = players[user];
                        final bool doYouHave =
                            round.clues.any((clue) => me!.clues.contains(clue));
                        Future.delayed(
                            const Duration(milliseconds: 500),
                            () => ref
                                .watch(boardDatabaseProvider)
                                .updatePlayerAnswer(round, doYouHave));

                        break;
                      case RoundStatus.teacherStudentAnswered:
                        if (round.roundAnswer != null) {
                          showAccuseSnackBar();
                        } else {
                          await selectRoundAnswer(round.clues);
                        }
                        break;
                      case null:
                        break;
                    }
                  }
                }
              }
            } catch (e) {
              //FirebaseCrashlytics.instance
              ref.read(crashlyticsProvider).recordError(
                    e,
                    null,
                    reason: 'Round Error',
                    fatal: true,
                  );
            }
          },
        );
      },
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double slide = maxSlide * _controller.value;
          final double scale = 1 - (_controller.value * 0.3);

          return SlidingUpPanel(
            controller: _panelController,
            isDraggable: false,
            body: Stack(
              children: [
                GestureDetector(
                  onTap: toggle,
                  child: const BoardDrawer(),
                ),
                Positioned(
                  width: size.width * 0.8,
                  height: size.height,
                  right: 0,
                  child: Container(
                    transform: Matrix4.identity()
                      ..translate(slide)
                      ..scale(scale),
                    padding: Pad(all: size.width * 0.01),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                            size.width * (_controller.isDismissed ? 0 : 0.05)),
                      ),
                    ),
                    child: const BoardTabState(),
                  ),
                )
              ],
            ),
            collapsed: const CollapsedRound(),
            //panel: 1 != 1 ? const ClueRoundState() : const AccuseRoundState(),
            panel: AnimatedSwitcher(
              duration: animDuration,
              child: ref.watch(gameRoundProvider).when(
                    data: (round) {
                      if (round == null) return null;
                      if (!(round.accusing ?? false)) {
                        return const ClueRoundState();
                      } else {
                        if (round.asking ==
                            ref.watch(firebaseUserProvider).uid) {
                          return const AccuseRoundState();
                        }
                        return const Box();
                      }
                    },
                    error: (error, stackTrace) =>
                        Lottie.asset('assets/no_internet.json'),
                    loading: () => null,
                  ),
            ),
            minHeight: size.height * 0.05,
            maxHeight: size.height *
                (ref.watch(gameRoundProvider).maybeWhen(
                      data: (round) {
                        if (round == null) return 0.75;
                        return !(round.accusing ?? false) ? 0.9 : 0.75;
                      },
                      orElse: () => 0.5,
                    )), //0.9,0.75
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.width * 0.05),
              topRight: Radius.circular(size.width * 0.05),
            ),
          );
        },
      ),
    );
  }
}

class BoardTabState extends StatelessWidget {
  const BoardTabState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Flexible(flex: 2, child: Container()),
          Flexible(
            child: TabBar(
              tabs: ["Board", "Rounds"]
                  .map(
                    (e) => Tab(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          e,
                          style: GoogleFonts.poppins(
                              fontSize: size.width * 0.03,
                              color: Colors.blueGrey.shade800),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Flexible(
            flex: 14,
            child: TabBarView(
              children: [
                PlayersAndVenues(),
                AllRounds(),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
*/
