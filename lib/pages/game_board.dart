import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
                        final Map<String,Player> players = Map<String,Player>.from(ref.watch(playersProvider).value??{});

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
                        final Map<String,Player> players = Map<String,Player>.from(ref.watch(playersProvider).value??{});

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
              FirebaseCrashlytics.instance.recordError(
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
