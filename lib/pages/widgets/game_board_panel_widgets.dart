/*
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:traccia/models/clue_card.dart';
import 'package:traccia/models/player.dart';
import 'package:traccia/models/round.dart';
import 'package:traccia/pages/game_board.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/board.dart';
import 'package:traccia/provider/room.dart';

final accuseStepperProvider =
    StateNotifierProvider<AccuseStepper, int>((_) => AccuseStepper());

class AccuseStepper extends StateNotifier<int> {
  AccuseStepper() : super(0);
}

class AccuseRoundState extends ConsumerWidget {
  const AccuseRoundState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final String uid = ref.watch(firebaseUserProvider).uid;
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    final Map<String, ClueCard> cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final List<String> meClues = players[uid]!.clues;
    final playerClues = ref.watch(playerClueNotifier).pClues;
    final suspectNotifier = ref.watch(suspectsNotifierProvider);
    return Stepper(
      steps: List.from(
        CardType.values.map(
          (_type) {
            final ClueCard? sideAnswer = _type == CardType.person
                ? cards[suspectNotifier.person]
                : _type == CardType.weapon
                    ? cards[suspectNotifier.weapon]
                    : cards[suspectNotifier.place];
            final List<String> cardIds = cards.keys
                .where((element) => cards[element]!.type == _type)
                .toList();

            return Step(
              title: ListTile(
                onTap: () {
                  print("Change stepper value ${_type.index}");
                  ref.watch(accuseStepperProvider.notifier).state = _type.index;
                },
                title: AutoSizeText(
                  toBeginningOfSentenceCase(_type.name) ?? "",
                  style: GoogleFonts.poppins(),
                ),
                subtitle: AutoSizeText(
                  "you have\t" +
                      cardIds
                          .where((element) => meClues.contains(element))
                          .map((e) =>
                              toBeginningOfSentenceCase(cards[e]!.name) ?? "")
                          .join(",\t"),
                  style: TextStyle(
                      color: Colors.grey, fontSize: size.width * 0.02),
                ),
                //isThreeLine: true,
                trailing: sideAnswer == null
                    ? null
                    : AutoSizeText(
                        toBeginningOfSentenceCase(sideAnswer.name) ?? "",
                        style: GoogleFonts.poppins(),
                      ),
              ),
              content: Container(
                height: size.height * 0.2,
                width: size.width,
                color: Colors.blueGrey.shade50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...cardIds.where((id) => !meClues.contains(id)).where((id) {
                      Map<String, PersonAnswer> clueA = playerClues[id] ?? {};
                      return !clueA.containsValue(PersonAnswer.verified);
                    }).map(
                      (id) => SizedBox(
                        width: size.width * 0.3,
                        child: InkWell(
                          onTap: () => suspectNotifier.setCard(id, _type),
                          child: Card(
                            color: Colors.blueGrey,
                            child: Column(
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    child: Image.asset(cards[id]!.imagePath),
                                  ),
                                ),
                                Flexible(
                                  child: AutoSizeText(
                                    toBeginningOfSentenceCase(
                                            cards[id]!.name) ??
                                        "",
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade100,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...cardIds.where((id) => !meClues.contains(id)).where((id) {
                      Map<String, PersonAnswer> clueA = playerClues[id] ?? {};
                      return clueA.containsValue(PersonAnswer.verified);
                    }).map(
                      (id) => Opacity(
                        opacity: 0.5,
                        child: SizedBox(
                          width: size.width * 0.3,
                          child: Card(
                            color: Colors.blueGrey,
                            child: Column(
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    child: Image.asset(cards[id]!.imagePath),
                                  ),
                                ),
                                Flexible(
                                  child: AutoSizeText(
                                    (toBeginningOfSentenceCase(
                                                cards[id]!.name) ??
                                            "") +
                                        "\t(${players[playerClues[id]!.keys.firstWhere((element) => playerClues[id]![element] == PersonAnswer.verified)]!.name}'s clue)",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade100,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      currentStep: ref.watch(accuseStepperProvider),
      onStepCancel: () => ref.read(accusingProvider(false)),
      onStepContinue: () => ref.watch(compareHiddenCardsProvider.future).then(
        (listBool) {
          print(listBool);
          return ref.watch(updateWinnerProvider(
              listBool.every((element) => element == true)));
        },
      ),
    );
  }
}

class ClueRoundState extends ConsumerWidget {
  const ClueRoundState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Round? round = ref.watch(gameRoundProvider).value;
    final cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});

    return AnimatedSwitcher(
      duration: animDuration,
      child: round == null || cards.isEmpty || players.isEmpty
          ? Container()
          : Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.05),
                  topRight: Radius.circular(size.width * 0.05),
                ),
              ),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(size.width * 0.05),
                          topRight: Radius.circular(size.width * 0.05),
                        ),
                        image: DecorationImage(
                          image: AssetImage(cards[round.place]!.locationPath),
                          fit: BoxFit.cover,
                          opacity: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: Pad(all: size.width * 0.05),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: RowSuper(
                              children: round.clues
                                  .where((e) => e != round.place)
                                  .map(
                                (e) {
                                  ClueCard? clue = cards[e];
                                  if (clue == null) return Container();
                                  return CircleAvatar(
                                    backgroundColor:
                                        clue.type == CardType.person
                                            ? Colors.blue.shade100
                                            : Colors.red.shade400,
                                    radius: size.width * 0.09,
                                    backgroundImage:
                                        clue.type == CardType.person
                                            ? AssetImage(clue.imagePath)
                                            : null,
                                    child: clue.type == CardType.weapon
                                        ? Image.asset(clue.imagePath)
                                        : null,
                                  );
                                },
                              ).toList(),
                              innerDistance: -size.width * 0.025,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            width: size.width * 0.5,
                            child: Text(
                              round.clues
                                  .map((e) =>
                                      toBeginningOfSentenceCase(cards[e]!.name))
                                  .join(",\t"),
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.04,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Text(
                              "${toBeginningOfSentenceCase(players[round.asking]!.name)} "
                              "wants to check with...",
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Flexible(
                    flex: 2,
                    child: Center(child: PlayerRoundEachAnswers()),
                  ),
                  Flexible(
                    child: Box(
                        */
/*child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Flexible(
                            flex: 6,
                            child:
                                AutoSizeText("Player1 wants to check with\t"),
                          ),
                          Flexible(
                            child: AnimatedTextKit(
                              animatedTexts: [
                                ScaleAnimatedText("Rachell"),
                                ScaleAnimatedText("Rachell"),
                                ScaleAnimatedText("Rachell"),
                              ],
                              */ /*
 */
/* repeatForever: true,
                              isRepeatingAnimation: true,*/ /*
 */
/*
                            ),
                          )
                        ],
                      ),*/ /*

                        ),
                  )
                ],
              ),
            ),
    );
  }
}

class PlayerRoundEachAnswers extends ConsumerWidget {
  const PlayerRoundEachAnswers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Round? round = ref.watch(gameRoundProvider).value;
    final cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final String uid = ref.watch(firebaseUserProvider).uid;
    final players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    //final rNotifier = ref.watch(roundNotifierProvider);
    final List<String> playerRoundOrder =
        ref.watch(playerRoundOrderProvider(round!.asking));
    Map<String, bool?> answerMap = round.answers;
    return SizedBox(
      //color: Colors.blueGrey.shade200,
      height: size.height * 0.2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final String playerId = playerRoundOrder[index];
          RoundAnswerPlayer roundAnswerPlayer;
          roundAnswerPlayer = answerMap[playerId] == null
              ? RoundAnswerPlayer.notYet
              : answerMap[playerId] == false
                  ? RoundAnswerPlayer.no
                  : round.roundAnswer != null
                      ? round.asking == uid
                          ? round.to == playerId
                              ? RoundAnswerPlayer.theCard
                              : RoundAnswerPlayer.seen
                          : RoundAnswerPlayer.seen
                      : RoundAnswerPlayer.yes;
          */
/*  ? round.asking == playerId || round.to == playerId
                          ? playerId == uid
                              ? RoundAnswerPlayer.theCard
                              : RoundAnswerPlayer.seen
                          : RoundAnswerPlayer.yes
                      : RoundAnswerPlayer.yes;*/ /*


          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size.width * 0.02),
            ),
            child: Container(
              width: size.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
              child: AnimatedSwitcher(
                duration: animDuration,
                child: EachAnswer(
                  player: players[playerId]!,
                  answer: roundAnswerPlayer,
                  card: round.roundAnswer == null
                      ? null
                      : cards[round.roundAnswer],
                  key: ValueKey(roundAnswerPlayer),
                ),
              ),
            ),
          );
        },
        itemCount: playerRoundOrder.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox.square(dimension: size.width * 0.005),
      ),
    );
  }

  */
/*Container(
      color: Colors.blueGrey.shade200,
      height: size.height * 0.2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) => SizedBox(
          width: size.width * 0.25,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                child: Card(
                  child: SizedBox(
                    height: size.height * 0.175,
                    width: size.width * 0.25,
                  ),
                ),
              ),
              Positioned(
                  //bottom: -size.height * 0.01,
                  child: CircleAvatar(radius: size.width * 0.06)),
            ],
            alignment: AlignmentDirectional.bottomCenter,
          ),
        ),
        itemCount: 5,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox.square(dimension: size.width * 0.025),
      ),
    );*/ /*


  */
/*Center(
        child: WrapSuper(
          children: List.generate(
            5,
            (index) => CircleAvatar(
              radius: size.width * (index == 4 ? 0.15 : 0.1),
            ),
          ),
          wrapFit: WrapFit.proportional,
          alignment: WrapSuperAlignment.center,
          //innerDistance: -size.width * 0.02,
        ),
      )*/ /*


  Widget widgetControlBuilder(context, ControlsDetails details) => Consumer(
        builder: (_, ref, __) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.04,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //TextButton(onPressed: () {}, child: AutoSizeText("ACCUSE NOW")),

                //TextButton(onPressed: () {}, child: AutoSizeText("CANCEL")),

                TextButton(
                    onPressed: () {},
                    //ref.read(roundNotifierProvider).updateSelectedAnswer,
                    child: const AutoSizeText("SHOW CARD")),
                TextButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(
                                const SnackBar(content: AccuseSnackBar()))
                            .closed
                            .then((value) {
                          print(value.name);
                          ref.watch(accusingProvider(
                              value == SnackBarClosedReason.hide));
                        }),
                    child: const AutoSizeText("SNACK"))
              ],
            ),
          );
        },
      );
}

enum RoundAnswerPlayer { notYet, no, yes, seen, theCard }

class EachAnswer extends StatelessWidget {
  final Player player;
  final ClueCard? card;
  final RoundAnswerPlayer answer;

  const EachAnswer(
      {Key? key, required this.player, this.card, required this.answer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    switch (answer) {
      case RoundAnswerPlayer.notYet:
        return Column(
          children: [
            Flexible(
              flex: 8,
              child: Image.asset(player.asImage),
            ),
            Flexible(
                flex: 2,
                child: AutoSizeText(
                  toBeginningOfSentenceCase(player.name) ?? "",
                  style: TextStyle(color: Colors.blueGrey.shade100),
                ))
          ],
        );
      case RoundAnswerPlayer.no:
        return Box(
          color: Colors.blueGrey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 7,
                child: Icon(
                  Icons.close,
                  color: Colors.red.shade400,
                  size: size.width * 0.2,
                ),
              ),
              Flexible(
                  flex: 3,
                  child: GridTileBar(
                    leading: Image.asset(player.asImage),
                    title: AutoSizeText(
                      toBeginningOfSentenceCase(player.name) ?? "",
                      style: TextStyle(color: Colors.blueGrey.shade100),
                    ),
                  ))
            ],
          ),
        );
      case RoundAnswerPlayer.yes:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 7,
              child: Icon(
                Icons.done,
                size: size.width * 0.2,
              ),
            ),
            Flexible(
              flex: 3,
              child: GridTileBar(
                leading: Image.asset(player.asImage),
                title: AutoSizeText(
                  "Emily",
                  style: TextStyle(color: Colors.blueGrey.shade400),
                ),
              ),
            )
          ],
        );
      case RoundAnswerPlayer.seen:
        return Box(
          color: Colors.blueGrey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 7,
                child: Icon(
                  Icons.done_all,
                  color: Colors.lightBlue,
                  size: size.width * 0.2,
                ),
              ),
              Flexible(
                flex: 3,
                child: GridTileBar(
                  leading: Image.asset(player.asImage),
                  title: AutoSizeText(
                    toBeginningOfSentenceCase(player.name) ?? "",
                    style: TextStyle(color: Colors.blueGrey.shade100),
                  ),
                ),
              )
            ],
          ),
        );
      case RoundAnswerPlayer.theCard:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 7,
              child: Image.asset(card!.imagePath),
            ),
            Flexible(
              flex: 3,
              child: GridTileBar(
                leading: Image.asset(player.asImage),
                title: AutoSizeText(
                  toBeginningOfSentenceCase(player.name) ?? "",
                  style: TextStyle(color: Colors.blueGrey.shade400),
                ),
              ),
            )
          ],
        );
    }
  }
}

class FinalClue extends StatelessWidget {
  final ClueCard clue;
  const FinalClue({Key? key, required this.clue}) : super(key: key);

  //final Size size;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.centerRight,
      child: Card(
        color: Colors.white70,
        shape: CircleBorder(),
        elevation: 2,
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Image.asset(clue.imagePath),
              ),
              TextSpan(
                  text: "${toBeginningOfSentenceCase(clue.name)}",
                  style: GoogleFonts.poppins(
                      color: Colors.blueGrey.shade700,
                      fontSize: size.width * 0.02))
            ],
          ),
        ),
      ),
    );
  }
}

*/
/*Row(
                    children: [
                      Flexible(
                          flex: 3,
                          child: Image.asset("assets/places_icon/bowling.png")),
                      Flexible(
                          flex: 2,
                          child: AutoSizeText(
                            "Bowling",
                            maxLines: 1,
                            style: TextStyle(color: Colors.grey),
                          )),
                    ],
                  )*/ /*


class AccuseSnackBar extends StatelessWidget {
  const AccuseSnackBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.025,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 7,
            child: AutoSizeText(
              "Want to accuse now",
              style: GoogleFonts.poppins(color: Colors.grey.shade400),
            ),
          ),
          Flexible(
            flex: 3,
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: AutoSizeText(
                "ACCUSE NOW",
                maxLines: 1,
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhichCardUShow extends ConsumerWidget {
  final String id;
  final bool shouldClick;
  final List<String> clues;
  const WhichCardUShow({
    Key? key,
    required this.id,
    required this.shouldClick,
    required this.clues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    Map<String, Player> players = ref.watch(playersProvider).value ?? {};
    Map<String, ClueCard> cards = ref.watch(cardsProvider).value ?? {};
    //List<String> rClues = ref.watch(roundNotifierProvider).gameRound!.clues;
    return Container(
      height: size.height * 0.08,
      //color: Colors.white70,
      alignment: Alignment.centerLeft,
      child: RowSuper(
        children: List.from(
          players[id]!.clues.map(
            (e) {
              final CardType type = cards[e]!.type;
              return Opacity(
                //opacity: index == 0 ? 0.2 : 1,
                opacity: clues.contains(e) ? 1 : 0.25,
                child: InkWell(
                  onTap: !clues.contains(e)
                      ? null
                      : () {
                          print("Setting Answer");
                          //ref.read(roundNotifierProvider).selectedAnswer = e;
                        },
                  child: CircleAvatar(
                    radius: size.width * 0.07,
                    backgroundColor: circleColor(type),
                    backgroundImage: type == CardType.person
                        ? AssetImage(cards[e]!.imagePath)
                        : null,
                    child: type != CardType.person
                        ? Image.asset(cards[e]!.imagePath)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        innerDistance: -size.width * 0.0075,
        //fill: true,
        fitHorizontally: true,
      ),
    );
  }

  MaterialColor circleColor(CardType type) {
    switch (type) {
      case CardType.person:
        return Colors.lightBlue;
      case CardType.weapon:
        return Colors.red;
      case CardType.place:
        return Colors.lightGreen;
    }
  }
}

*/
/*ListView(
                children: List.generate(
                  6,
                  (index) => Card(
                    elevation: 4,
                    shape: const CircleBorder(),
                    //shape: RoundedRectangleBorder(
                    //    borderRadius: BorderRadius.circular(size.width * 0.02)),
                    child: CircleAvatar(
                      radius: size.width * 0.1,
                      backgroundColor: Colors.blue.shade700,
                      child: Image.asset(
                        const ClueCard(name: 'lift', type: CardType.place)
                            .imagePath,
                        width: size.width * 0.175,
                      ),
                    ),
                  ),
                ),
                //innerDistance: -size.width * 0.02,
                //wrapFit: WrapFit.proportional,
              )*/ /*


*/
/*SizedBox(
                    width: index == 2 ? size.width : null,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: CircleAvatar(
                        child: Image.asset(
                            ClueCard(name: 'ken', type: CardType.person)
                                .imagePath),
                        backgroundColor: Colors.transparent,
                      ),
                      label: Text(
                        "Bowlling".toUpperCase(),
                      ),
                    ),
                  )*/ /*


*/
/*ButtonBarSuper(
                children: [
                  ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.asset(
                        ClueCard(name: "bowling", type: CardType.place)
                            .imagePath,
                        width: size.width * 0.1,
                        height: size.height * 0.1,
                      ),
                      label: Text("BOWLING")),
                  ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.asset(
                        ClueCard(name: "bowling", type: CardType.place)
                            .imagePath,
                        width: size.width * 0.1,
                        height: size.height * 0.1,
                      ),
                      label: Text("BOWLING")),
                  ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.asset(
                        ClueCard(name: "bowling", type: CardType.place)
                            .imagePath,
                        width: size.width * 0.1,
                        height: size.height * 0.1,
                      ),
                      label: Text("BOWLING")),
                ],
                lineSpacing: 2,
                spacing: 2,
              )*/ /*


*/
