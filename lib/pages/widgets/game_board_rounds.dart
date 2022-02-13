import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class AllRounds extends ConsumerWidget {
  const AllRounds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    final String uid = ref.watch(firebaseUserProvider).uid;
    final List<MaterialColor> randomColors = [
      Colors.blueGrey,
      Colors.red,
      Colors.indigo,
      Colors.green
    ];
    return AnimatedSwitcher(
      duration: animDuration,
      child: cards.isEmpty || players.isEmpty
          ? Container()
          : ref.watch(allRoundsProvider).when(
                data: (QuerySnapshot snapshot) => ListView.builder(
                  itemBuilder: (context, index) {
                    Map map = snapshot.docs.elementAt(index).data() as Map;
                    Map<String, dynamic> json = Map<String, dynamic>.from(map);
                    Round round = Round.fromJson(json);

                    return Container(
                      height: size.height * (round.asking == uid ? 0.25 : 0.2),
                      margin:
                          EdgeInsets.symmetric(vertical: size.height * 0.001),
                      decoration: BoxDecoration(
                          color: randomColors[Random().nextInt(4)].shade900,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.01)),
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 8,
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: RowSuper(
                                    children: round.clues
                                        .map(
                                          (e) => CircleAvatar(
                                            radius: size.width * 0.075,
                                            backgroundColor:
                                                circleColor(cards[e]!.type)
                                                    .shade400,
                                            backgroundImage: cards[e]!.type ==
                                                    CardType.person
                                                ? AssetImage(
                                                    cards[e]!.imagePath)
                                                : null,
                                            child: cards[e]!.type !=
                                                    CardType.person
                                                ? Image.asset(
                                                    cards[e]!.imagePath)
                                                : null,
                                          ),
                                        )
                                        .toList(),
                                    innerDistance: -size.width * 0.025,
                                  ),
                                ),
                                Positioned(
                                  width: size.width * 0.6,
                                  height: size.height * 0.075,
                                  child: GridTileBar(
                                    title: AutoSizeText(
                                      toBeginningOfSentenceCase(
                                              players[round.asking]!.name) ??
                                          "",
                                      style: GoogleFonts.poppins(
                                          fontSize: size.width * 0.04),
                                    ),
                                    subtitle: AutoSizeText(
                                      round.clues
                                          .map((e) =>
                                              toBeginningOfSentenceCase(
                                                  cards[e]!.name) ??
                                              "")
                                          .join(",\t"),
                                      style: GoogleFonts.poppins(
                                        fontSize: size.width * 0.02,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  width: size.width * 0.25,
                                  height: size.height * 0.2,
                                  child: Container(
                                    alignment: Alignment.center,
                                    //color: Colors.red,
                                    child: ListView(
                                      reverse: true,
                                      children: round.answers.entries
                                          .map(
                                            (e) => SizedBox(
                                              height: size.height * 0.04,
                                              child: ListTile(
                                                title: AutoSizeText(
                                                  toBeginningOfSentenceCase(
                                                          players[e.key]!
                                                              .name) ??
                                                      "",
                                                  maxLines: 1,
                                                  style: GoogleFonts.poppins(
                                                      color: e.value == null
                                                          ? Colors.white30
                                                          : Colors.white70,
                                                      decoration:
                                                          e.value == false
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null),
                                                  //textAlign: TextAlign.end,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      //shrinkWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              round.asking == uid
                                  ? round.to != null &&
                                          round.roundAnswer != null
                                      ? "${toBeginningOfSentenceCase(players[round.to]!.name) ?? ""} showed ${toBeginningOfSentenceCase(cards[round.roundAnswer!]!.name) ?? ""}"
                                      : "No one showed the card"
                                  : round.to == uid && round.roundAnswer != null
                                      ? "You showed ${toBeginningOfSentenceCase(cards[round.roundAnswer]!.name) ?? ""}"
                                      : "${toBeginningOfSentenceCase(players[round.to]!.name) ?? ""} showed to ${toBeginningOfSentenceCase(players[round.asking]!.name) ?? ""}",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: size.width * 0.03),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: snapshot.docs.length,
                ),
                error: (error, stackTrace) => Container(),
                loading: () => Container(),
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

/*List.generate(
                                        5,
                                        (index) => AutoSizeText(
                                          "Atom",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: size.width * 0.04,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationThickness:
                                                size.height * 0.0025,
                                            decorationColor: Colors.white70,
                                          ),
                                          maxLines: 1,
                                        ),
                                      )*/

/*
ListView(
      children: List.generate(
        9,
        (listIndex) => Container(
          height: size.height * 0.25,
          margin: EdgeInsets.symmetric(vertical: size.height * 0.001),
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              */
/*image: DecorationImage(
                      image: AssetImage(
                          const ClueCard(name: "lift", type: CardType.place)
                              .locationPath),
                      fit: BoxFit.cover,
                      opacity: 0.4,
                    ),*/ /*

              borderRadius: BorderRadius.circular(size.width * 0.01)),
          padding: EdgeInsets.all(size.width * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 8,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: RowSuper(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade700,
                            radius: size.width * 0.075,
                            backgroundImage:
                                const AssetImage('assets/avatar_icon/adam.png'),
                          ),
                          CircleAvatar(
                            radius: size.width * 0.075,
                            backgroundColor: Colors.blueGrey.shade800,
                            child: Image.asset('assets/weapons_icon/knife.png'),
                          ),
                          CircleAvatar(
                            radius: size.width * 0.075,
                            backgroundColor: Colors.blueGrey.shade800,
                            child: Image.asset('assets/places_icon/lift.png'),
                          ),
                        ],
                        innerDistance: -size.width * 0.025,
                      ),
                    ),
                    Positioned(
                      width: size.width * 0.5,
                      height: size.height * 0.075,
                      child: GridTileBar(
                        title: AutoSizeText(
                          "Tobirama",
                          style:
                              GoogleFonts.poppins(fontSize: size.width * 0.04),
                        ),
                        subtitle: AutoSizeText(
                          "Ken | Plug | Electronics",
                          style:
                              GoogleFonts.poppins(fontSize: size.width * 0.02),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      width: size.width * 0.25,
                      height: size.height * 0.175,
                      child: Container(
                        alignment: Alignment.center,
                        child: ListView(
                          children: List.generate(
                            5,
                            (index) => AutoSizeText(
                              "Atom",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: size.height * 0.0025,
                                decorationColor: Colors.white70,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          shrinkWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  "Fred showed Bowling",
                  style: TextStyle(
                      color: Colors.white60, fontSize: size.width * 0.03),
                ),
              )
            ],
          ),
        ),
      ),
    )
*/

class RoundAnswerOption extends ConsumerWidget {
  final List<String> clues;
  const RoundAnswerOption({Key? key, required this.clues}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final cards = ref.watch(cardsProvider).value;
    final meClues = ref.watch(mePlayerProvider).value!.clues;
    return FractionallySizedBox(
      heightFactor: 0.4,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size.width * 0.01),
            topRight: Radius.circular(size.width * 0.01),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
                flex: 2, child: Text("Which card you want to show?")),
            Flexible(
                flex: 8,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: meClues
                      .map((e) => Opacity(
                            opacity: clues.contains(e) ? 1 : 0.2,
                            child: Card(
                              color: Colors.blue,
                              elevation: 4,
                              child: InkWell(
                                onTap: !clues.contains(e)
                                    ? null
                                    : () => ref
                                        .watch(
                                            updateRoundAnswerProvider(e).future)
                                        .whenComplete(
                                          () => Navigator.pop(context),
                                        ),
                                child: Box(
                                  width: size.width * 0.2,
                                  padding: Pad(all: size.width * 0.01),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(
                                        flex: 8,
                                        child:
                                            Image.asset(cards![e]!.imagePath),
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: AutoSizeText(
                                          toBeginningOfSentenceCase(
                                                  cards[e]!.name) ??
                                              "",
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ))
          ],
        ),
      ),
    );
  }
}

/*class RoundAnswerOption extends ConsumerWidget {
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
}*/
