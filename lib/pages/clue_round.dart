import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/model/round.dart';
import '/model/clue_card.dart';
import '/model/player.dart';
import '/pages/game_room.dart';
import 'providers/auth.dart';
import 'providers/board.dart';

class RoundAnswerOption extends ConsumerWidget {
  final List<String> commonClues;
  const RoundAnswerOption(this.commonClues, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Map<String, ClueCard> cards = ref.watch(cardsProvider).value!;

    return FractionallySizedBox(
      heightFactor: 0.3,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.025),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                "Which card you want to show?",
                style: GoogleFonts.poppins(
                    fontSize: size.width * 0.0325, fontWeight: FontWeight.w200),
              ),
            ),
            Flexible(
              flex: 2,
              child: RowSuper(
                children: commonClues.map(
                  (e) {
                    final ClueCard card = cards[e]!;
                    final String picLocation = card.type == CardType.place
                        ? 'assets/places_icon'
                        : card.type == CardType.weapon
                            ? 'assets/weapons_icon'
                            : 'assets/avatar_icon';

                    return ActionChip(
                      elevation: 4,
                      label: Container(
                        width: size.width * 0.25,
                        padding: EdgeInsets.all(size.width * 0.0225),
                        child: Text(
                          toBeginningOfSentenceCase(cards[e]!.name) ?? "",
                          style: TextStyle(fontSize: size.width * 0.0275),
                        ),
                      ),
                      avatar: Image.asset('$picLocation/${card.name}.png'),
                      onPressed: () => ref
                          .watch(updateRoundAnswerProvider(e).future)
                          .whenComplete(
                            () => Navigator.pop(context),
                          ),
                    );
                  },
                ).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ClueRound extends ConsumerWidget {
  const ClueRound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Map<String, ClueCard> cards = ref.watch(cardsProvider).value!;
    final Map<String, Player> players = ref.watch(playersProvider).value!;
    final String user = ref.watch(firebaseUserProvider).uid;
    final bool yourRound = user == ref.watch(currentIDProvider).value;

    Future selectRoundAnswer(List<String> commonClues) => showModalBottomSheet(
          context: context,
          isDismissible: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.width * 0.05),
              topRight: Radius.circular(size.width * 0.05),
            ),
          ),
          backgroundColor: Colors.blue.shade50,
          builder: (context) => RoundAnswerOption(commonClues),
        );
    accuseSnackBar() => ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(
                  "Want to accuse now?",
                  style: GoogleFonts.luckiestGuy(fontSize: size.width * 0.025),
                ),
                action: yourRound
                    ? SnackBarAction(
                        label: 'Accuse Now',
                        onPressed: () => ref.watch(accusingProvider(true)),
                      )
                    : null,
              ),
            )
            .closed
            .then(
          (SnackBarClosedReason reason) {
            if (reason == SnackBarClosedReason.timeout) {
              if (yourRound) ref.watch(accusingProvider(false));
            }
          },
        );

    ref.listen<AsyncValue<Round?>>(
      roundProvider,
      (previous, async) {
        async.whenData(
          (round) async {
            if (round != null) {
              if (user == round.asking) {
                if (ref.watch(placeOccupiedNotifier.notifier).state !=
                    round.place) {
                  ref.watch(placeOccupiedNotifier.notifier).state = round.place;
                }
              }
              if (round.accusing == null) {
                if (round.answers.values.every((check) => check == false)) {
                  accuseSnackBar();
                } else {
                  RoundStatus? roundStatus =
                      ref.watch(roundStatusProvider(round));

                  switch (roundStatus) {
                    case RoundStatus.teacher:
                      if (round.roundAnswer != null) {
                        ref.watch(playerClueNotifier).update(round.roundAnswer!,
                            round.to!, PersonAnswer.verified);

                        accuseSnackBar();
                      }
                      break;
                    case RoundStatus.student:
                      final List<String> myClues =
                          ref.watch(myDataProvider)!.clues;
                      final bool myAnswer =
                          round.clues.any((clue) => myClues.contains(clue));
                      ref.watch(updateAnswerProvider(myAnswer));

                      break;
                    case RoundStatus.studentAnswered:
                      if (round.roundAnswer == null &&
                          round.answers[user] == true) {
                        final List<String> myClues =
                            ref.watch(myDataProvider)!.clues;
                        List<String> commonClues = round.clues
                          ..removeWhere((id) => !myClues.contains(id));

                        await selectRoundAnswer(commonClues);
                      }

                      break;
                    case RoundStatus.teacherStudent:
                      final List<String> myClues =
                          ref.watch(myDataProvider)!.clues;
                      final bool myAnswer =
                          round.clues.any((clue) => myClues.contains(clue));
                      ref.watch(updateAnswerProvider(myAnswer));

                      break;
                    case RoundStatus.teacherStudentAnswered:
                      if (round.roundAnswer != null) {
                        accuseSnackBar();
                      } else {
                        final myClues = ref.watch(myDataProvider)!.clues;
                        List<String> commonClues = round.clues
                          ..removeWhere((id) => !myClues.contains(id));
                        await selectRoundAnswer(commonClues);
                      }
                      break;
                    case null:
                      break;
                  }
                }
                //}
              }
            }
          },
        );
      },
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size.width * 0.01),
          ),
        ),
        padding: EdgeInsets.all(size.width * 0.025),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: ref.watch(roundProvider).when(
                data: (round) {
                  if (round == null) return Container();
                  if (round.accusing != null) {
                    if (round.accusing!) {
                      ref.refresh(suspectsNotifierProvider);
                      return const FinalCardAccusation();
                    }
                  }
                  final List<String> playerRoundOrder =
                      ref.watch(playerRoundOrderProvider(round.asking));

                  final bool meTeacher = round.asking == user;
                  final String teacherName =
                      toBeginningOfSentenceCase(players[round.asking]!.name) ??
                          "";
                  final String? stud = round.to;

                  final String? studName = stud == null
                      ? ""
                      : toBeginningOfSentenceCase(players[stud]!.name) ?? "";

                  final String text = round.roundAnswer != null
                      ? meTeacher
                          ? "It's ${toBeginningOfSentenceCase(cards[round.roundAnswer]!.name) ?? ""}"
                          : "$teacherName saw the player's card"
                      : round.answers.values
                              .every((element) => element == false)
                          ? "No-one has the above cards"
                          : round.answers[stud] == null
                              ? "$teacherName is checking with $studName"
                              : "$studName said " +
                                  (round.answers[stud]! ? "Yes" : "No");

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "${players[round.asking]!.name}\t"),
                              TextSpan(
                                text: "wants to check with",
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.indigo,
                                ),
                              )
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.05,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Center(
                          child: RowSuper(
                            children: round.clues.map(
                              (e) {
                                final ClueCard card = cards[e]!;
                                final String name = cards[e]!.name;
                                final String picLocation =
                                    card.type == CardType.place
                                        ? 'assets/places_icon'
                                        : card.type == CardType.weapon
                                            ? 'assets/weapons_icon'
                                            : 'assets/avatar_icon';
                                return AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: round.roundAnswer == null ||
                                          round.asking != user
                                      ? 1
                                      : round.roundAnswer == e
                                          ? 1
                                          : 0.25,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex: 4,
                                        child: CircleAvatar(
                                          radius: size.width * 0.175,
                                          backgroundColor: Colors.primaries[
                                              Random().nextInt(
                                                  Colors.primaries.length)],
                                          child: AspectRatio(
                                            aspectRatio: 0.9,
                                            child: Image.asset(
                                                '$picLocation/${card.name}.png'),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                          child: Text(
                                              toBeginningOfSentenceCase(name) ??
                                                  ""))
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                            alignment: Alignment.center,
                            innerDistance: -size.width * 0.1,
                          ),
                        ),
                      ),
                      Flexible(
                        child: RowSuper(
                          innerDistance: -size.width * 0.05,
                          children: playerRoundOrder.map(
                            (id) {
                              final Player? player = players[id];
                              if (player == null) return Container();
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: round.to == id ? 1 : 0.25,
                                child: Badge(
                                  showBadge: round.answers[id] != null,
                                  //showBadge: round.answers.containsKey(id),
                                  position: BadgePosition(
                                      bottom: -size.height * 0.01),
                                  badgeContent: round.answers[id] == null
                                      ? null
                                      : Icon(
                                          round.answers[id] == true
                                              ? Icons.done
                                              : Icons.close,
                                          color: Colors.white70,
                                          size: size.width * 0.03,
                                        ),
                                  badgeColor: round.answers[id] == null
                                      ? Colors.white
                                      : round.answers[id] == true
                                          ? Colors.green
                                          : Colors.red,
                                  child: CircleName(
                                    name: player.name,
                                    radiusFactor: 0.125,
                                    backgroundColor: Colors.blue.shade100,
                                    fontColor: Colors.blue,
                                    titleFactor: 0.025,
                                    subTitleFactor: 0.0125,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      Flexible(
                        child: Center(
                          child: Text(
                            text,
                            style: TextStyle(fontSize: size.width * 0.04),
                          ),
                        ),
                      )
                    ],
                  );
                },
                error: (error, stackTrace) => Container(),
                loading: () => Container(),
              ),
        ),
      ),
    );
  }
}

class FinalCardAccusation extends ConsumerWidget {
  const FinalCardAccusation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final suspectNotifier = ref.watch(suspectsNotifierProvider);
    final Map<String, ClueCard> cards = ref.watch(cardsProvider).value!;
    final Map<String, Player> players = ref.watch(playersProvider).value!;
    final String currentId = ref.watch(currentIDProvider).value ?? "";
    final String user = ref.watch(firebaseUserProvider).uid;
    //final playerClues = ref.watch(playerClueNotifier).pClues;
    final Player me = players[user]!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: currentId != user
          ? Container(
              color: Colors.blue.shade50,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Text(
                      "${players[currentId]!.name} "
                      "started Final accusation",
                      style: TextStyle(
                          fontSize: size.width * 0.05, color: Colors.blue),
                    ),
                  ),
                  Flexible(
                    flex: 9,
                    child: AvatarGlow(
                      endRadius: size.width * 0.4,
                      glowColor: Colors.blue.shade400,
                      child: Material(
                        shape: const CircleBorder(),
                        child: CircleName(
                          fontColor: Colors.blue.shade50,
                          name: players[currentId]!.name,
                          backgroundColor: Colors.blue,
                          radiusFactor: 0.15,
                          subTitleFactor: 0.02,
                          titleFactor: 0.04,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.all(size.width * 0.02),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: suspectNotifier.withPlace
                                ? () => ref
                                    .watch(compareHiddenCardsProvider.future)
                                    .then(
                                      (listBool) => ref.watch(
                                          updateWinnerProvider(listBool.every(
                                              (element) => element == true))),
                                    )
                                : null,
                            child: Padding(
                              padding: EdgeInsets.all(size.width * 0.02),
                              child: FittedBox(
                                child: Text(
                                  "Select your final accusation",
                                  style: GoogleFonts.luckiestGuy(
                                      fontSize: size.width * 0.05),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: OutlinedButton(
                            onPressed: () => ref.watch(accusingProvider(false)),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.luckiestGuy(
                                  color: Colors.grey,
                                  fontSize: size.width * 0.04),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: WrapSuper(
                      alignment: WrapSuperAlignment.center,
                      spacing: size.width * 0.02,
                      children: cards.entries
                          .map(
                            (e) => TextButton(
                              onPressed: me.clues.contains(e.key)
                                  ? null
                                  : () => ref
                                      .read(suspectsNotifierProvider)
                                      .setCard(e.value),
                              child: AnimatedDefaultTextStyle(
                                style: GoogleFonts.poppins(
                                  fontSize: size.width * 0.05,
                                  fontWeight: suspectNotifier.containsId(e.key)
                                      ? FontWeight.bold
                                      : FontWeight.w200,
                                  color: me.clues.contains(e.key)
                                      ? Colors.grey.shade400
                                      : e.value.type == CardType.person
                                          ? suspectNotifier.person == e.key
                                              ? Colors.red.shade700
                                              : Colors.red.shade200
                                          : e.value.type == CardType.weapon
                                              ? suspectNotifier.weapon == e.key
                                                  ? Colors.green.shade700
                                                  : Colors.green.shade200
                                              : suspectNotifier.place == e.key
                                                  ? Colors.blue.shade700
                                                  : Colors.blue.shade200,
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
  }
}
