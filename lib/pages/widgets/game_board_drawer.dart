import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:traccia/models/clue_card.dart';
import 'package:traccia/models/player.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/board.dart';

class BoardDrawer extends ConsumerWidget {
  const BoardDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final String uid = ref.watch(firebaseUserProvider).uid;
    final Map<String, ClueCard> cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    if (cards.isEmpty || players.isEmpty) {
      return Container();
    }

    //cards.entries.

    final Player me = players[uid]!;
    return Container(
      color: Colors.blueGrey.shade800,
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Spacer(),
                Flexible(
                  flex: 2,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Image.asset(
                          'assets/avatar_icon/${me.as}.png',
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                      Flexible(
                          flex: 5,
                          child: FractionallySizedBox(
                            heightFactor: 1,
                            child: GridTileBar(
                              title: AutoSizeText(
                                me.name,
                                style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.04),
                              ),
                              subtitle: AutoSizeText(
                                me.clues
                                    .map((e) => toBeginningOfSentenceCase(
                                        cards[e]!.name))
                                    .join(",\t"),
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                  color: Colors.blueGrey.shade200,
                                  fontSize: size.width * 0.02,
                                ),
                              ),
                            ),
                          )),
                      const Spacer(flex: 3)
                    ],
                  ),
                ),
                Flexible(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 7,
                      child: TextButton(
                        onPressed: () {},
                        child: AutoSizeText(
                          "HOW TO PLAY",
                          style: TextStyle(color: Colors.blueGrey.shade100),
                        ),
                      ),
                    ),
                    Spacer(flex: 3),
                  ],
                ))
              ],
            ),
          ),
          Flexible(
            flex: 7,
            child: ListView(
              children: [
                ...cards.entries
                    .whereNot((mapEntry) => me.clues.contains(mapEntry.key))
                    .whereNot(
                  (element) {
                    Map<String, PersonAnswer> clueA =
                        ref.watch(playerClueNotifier).pClues[element.key] ?? {};
                    return clueA.containsValue(PersonAnswer.verified);
                  },
                ).sorted((a, b) {
                  Map<String, PersonAnswer> clueA =
                      ref.watch(playerClueNotifier).pClues[a.key] ?? {};
                  Map<String, PersonAnswer> clueB =
                      ref.watch(playerClueNotifier).pClues[b.key] ?? {};
                  return clueB.values
                      .where((element) => element == PersonAnswer.no)
                      .length
                      .compareTo(clueA.values
                          .where((element) => element == PersonAnswer.no)
                          .length);
                }).map((e) => DrawerTile(card: e.value, id: e.key)),
                ...cards.entries
                    .whereNot((mapEntry) => me.clues.contains(mapEntry.key))
                    .where(
                  (element) {
                    Map<String, PersonAnswer> c =
                        ref.watch(playerClueNotifier).pClues[element.key] ?? {};
                    return c.containsValue(PersonAnswer.verified);
                  },
                ).map(
                  (e) {
                    final m = ref.watch(playerClueNotifier).pClues[e.key] ?? {};
                    final String otherId =
                        m.keys.firstWhere((k) => m[k] == PersonAnswer.verified);
                    return Opacity(
                        opacity: 0.4,
                        child: DrawerTile(
                          card: e.value,
                          playerOwned: otherId,
                        ));
                  },
                ),
                ...cards.entries
                    .where((mapEntry) => me.clues.contains(mapEntry.key))
                    .map(
                      (e) => Opacity(
                        opacity: 0.2,
                        child: DrawerTile(card: e.value, playerOwned: uid),
                      ),
                    ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class DrawerTile extends ConsumerWidget {
  final ClueCard card;
  final String? playerOwned;
  final String? id;
  const DrawerTile({Key? key, required this.card, this.playerOwned, this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    final bool isYou =
        ref.watch(firebaseUserProvider).uid == (playerOwned ?? "");

    AutoSizeText deductions() {
      Map<String, PersonAnswer> personAnswers =
          id == null ? {} : ref.watch(playerClueNotifier).pClues[id] ?? {};

      return AutoSizeText.rich(
        TextSpan(
          children: personAnswers.entries
              .where((e) => e.value == PersonAnswer.no)
              .map(
                (e) => TextSpan(
                  text:
                      (toBeginningOfSentenceCase(players[e.key]!.name) ?? "") +
                          "\t",
                  style: TextStyle(
                    color: Colors.blueGrey.shade200,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2,
                  ),
                ),
              )
              .toList(),
        ),
        maxLines: 2,
      );
    }

    return Container(
      height: size.height * 0.1,
      color: Colors.blueGrey.shade600,
      margin: EdgeInsets.symmetric(vertical: size.height * 0.001),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Image.asset(card.imagePath),
            ),
          ),
          Flexible(
            flex: 5,
            child: FractionallySizedBox(
              heightFactor: 1,
              child: ListTile(
                title: AutoSizeText(
                  toBeginningOfSentenceCase(card.name) ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    color: Colors.blueGrey.shade50,
                  ),
                ),
                isThreeLine: playerOwned == null,
                subtitle: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.02,
                    color: Colors.blueGrey.shade200,
                  ),
                  child: isYou
                      ? AutoSizeText("Your Turn")
                      : playerOwned != null
                          ? AutoSizeText(
                              " ${toBeginningOfSentenceCase(players[playerOwned]!.name) ?? ""}'s Clue")
                          : deductions(),
                ),
              ),
            ),
          ),
          const Spacer(flex: 3)
        ],
      ),
    );
  }
}

/*AutoSizeText(
                  isYou
                      ? "Your Card"
                      : playerOwned != null
                          ? " ${toBeginningOfSentenceCase(players[playerOwned]!.name) ?? ""}'s Clue"
                          : deductions(),
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.02,
                    color: Colors.blueGrey.shade200,
                  ),
                )*/
