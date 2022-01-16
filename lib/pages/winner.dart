import 'package:animate_do/animate_do.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/model/clue_card.dart';

import 'providers/board.dart';
import '/model/player.dart';

class Winner extends ConsumerWidget {
  const Winner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Map<String, ClueCard> cards = ref.watch(cardsProvider).value!;
    final Map<String, Player> players = ref.watch(playersProvider).value!;
    final bool winner = ModalRoute.of(context)!.settings.arguments as bool;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.blue.shade50,
          padding: EdgeInsets.all(size.width * 0.05),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: ref.watch(boardRefProvider).when(
                  data: (map) {
                    final hidden = map['hidden'] as List;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: FadeInLeft(
                            child: Text(
                              "Case solved",
                              style: GoogleFonts.luckiestGuy(
                                fontSize: size.width * 0.1,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 7,
                          child: Wrap(
                            children: hidden.map(
                              (e) {
                                final ClueCard card = cards[e]!;
                                final String picLocation =
                                    card.type == CardType.place
                                        ? 'assets/places_icon'
                                        : card.type == CardType.weapon
                                            ? 'assets/weapons_icon'
                                            : 'assets/avatar_icon';

                                return FadeIn(
                                  child: CircleAvatar(
                                    radius: size.width * 0.175,
                                    child: AspectRatio(
                                      aspectRatio: 0.9,
                                      child: Image.asset(
                                          '$picLocation/${card.name}.png'),
                                    ),
                                  ),
                                ) /*CircleName(
                                    titleFactor: 0.05,
                                    fontColor: Colors.blue,
                                    subTitleFactor: 0.02,
                                    name: cards[e]!.name,
                                    backgroundColor: Colors.blue.shade200,
                                    radiusFactor: 0.175,
                                  )*/
                                    ;
                              },
                            ).toList(),
                            alignment: WrapAlignment.center,
                          ),
                        ),
                        Flexible(
                          child: RowSuper(
                            children: hidden.map(
                              (e) {
                                final ClueCard card = cards[e]!;
                                return FittedBox(
                                  child: Text(
                                    toBeginningOfSentenceCase(card.name) ?? "",
                                    style: GoogleFonts.luckiestGuy(
                                      fontSize: size.width * 0.075,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            separator: const Text(" - "),
                            innerDistance: size.width * 0.0275,
                          ),
                        ),
                        Flexible(
                          child: winner
                              ? Text(
                                  "${players[map['currentId'] as String]!.name} "
                                  "found the answers",
                                  style: TextStyle(fontSize: size.width * 0.04),
                                )
                              : Text(
                                  "No one guessed it correctly",
                                  style: TextStyle(fontSize: size.width * 0.04),
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
      ),
    );
  }
}

/*Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: size.width * 0.025,
                          runSpacing: size.height * 0.01,
                          children: ["Regina", "Saw", "Lift"]
                              .map((e) => Chip(
                                    label: Container(
                                      width: size.width * 0.3,
                                      height: size.height * 0.05,
                                      alignment: Alignment.center,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    elevation: 4,
                                  ))
                              .toList(),
                        ),
                      ),
                      Flexible(
                        child: FadeInLeft(
                          child: Text.rich(
                            TextSpan(
                              text: "By\t\t",
                              children: [
                                TextSpan(
                                  text: "Player1",
                                  style:
                                      TextStyle(fontSize: size.width * 0.075),
                                )
                              ],
                            ),
                          ),
                        ),
                      )*/

/*Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: "Case solved\n\n",
                  style: GoogleFonts.luckiestGuy(fontSize: size.width * 0.1)),
              WidgetSpan(
                child: Chip(
                  label: Container(
                    width: size.width * 0.275,
                    height: size.height * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      "Regina",
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                  ),
                  elevation: 4,
                ),
              ),
              const TextSpan(text: "\t\t"),
              WidgetSpan(
                child: Chip(
                  label: Container(
                    width: size.width * 0.275,
                    height: size.height * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      "Regina",
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                  ),
                  elevation: 4,
                ),
              ),
              TextSpan(text: '\t\tand'),
              WidgetSpan(
                child: Chip(
                  label: Container(
                    width: size.width * 0.275,
                    height: size.height * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      "Regina",
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        )*/
