import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:traccia/models/clue_card.dart';
import 'package:traccia/models/player.dart';
import 'package:traccia/pages/game_board.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/board.dart';
import 'package:collection/collection.dart';

class PlayersAndVenues extends StatelessWidget {
  const PlayersAndVenues({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Flexible(
          flex: 3,
          child: Box(alignment: Alignment.centerLeft, child: OnlyPlayers()),
        ),
        Flexible(flex: 7, child: Box(child: VenueList()))
      ],
    );
  }
}

class VenueList extends ConsumerWidget {
  const VenueList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final String uid = ref.watch(firebaseUserProvider).uid;
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    if (players.isEmpty) return Container();
    final List<String> myClues = players[uid]!.clues;
    final places =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {})
          ..removeWhere((key, value) => value.type != CardType.place);
    final suspectNotifier = ref.watch(suspectsNotifierProvider);
    final Map<String, ClueCard> sorted = Map<String, ClueCard>.fromEntries([
      ...places.entries.whereNot((map) => myClues.contains(map.key)),
      ...places.entries.where((map) => myClues.contains(map.key)),
    ]);
    final String roundId = ref.watch(currentIDProvider).when(
          data: (data) => data,
          error: (error, stackTrace) => "",
          loading: () => "",
        );

    return ListView.separated(
      itemCount: sorted.length,
      itemBuilder: (_, int index) {
        final ClueCard placeClue = sorted.values.elementAt(index);
        return InkWell(
          onTap: () => roundId != uid
              ? null
              : showDialog(
                  context: context,
                  builder: (_) => ClueChoiceEx(
                      id: sorted.keys.elementAt(index), placeClue: placeClue),
                ).then(
                  (value) {
                    if (value == null) return;
                    //print("533" + value.toString());
                    if (value) {
                      suspectNotifier.setCard(
                          sorted.keys.elementAt(index), CardType.place);
                      ref.watch(createRoundProvider);
                    }
                  },
                ),
          child: Container(
            height: size.height * 0.2,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.all(
                Radius.circular(size.width * 0.01),
              ),
              image: DecorationImage(
                image: AssetImage('assets/places/${placeClue.name}.jpg'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: GridTile(
              child: GridTileBar(
                title: AutoSizeText(
                  toBeginningOfSentenceCase(placeClue.name) ?? "",
                  style: GoogleFonts.poppins(fontSize: size.width * 0.04),
                  textAlign: TextAlign.center,
                ),
              ),
              //footer: Container(),
              /*footer: index != 8
                  ? null
                  : Container(
                      height: size.height * 0.025,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(size.width * 0.01),
                            bottomRight: Radius.circular(size.width * 0.01),
                          )),
                      child: const Text("You were occupied")),*/
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => Box(
        height: size.height * 0.0025,
      ),
    );
  }
}

class ClueChoiceEx extends ConsumerWidget {
  const ClueChoiceEx({Key? key, required this.id, required this.placeClue})
      : super(key: key);

  final String id;
  final ClueCard placeClue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final Map<String, ClueCard> cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});
    final Player? mePlayer = ref.watch(mePlayerProvider).value;
    final suspectNotifier = ref.watch(suspectsNotifierProvider);
    return AlertDialog(
      title: SizedBox(
        width: size.width * 0.2,
        height: size.height * 0.06,
        child: AutoSizeText.rich(
          TextSpan(
            text: "Which clues you want to "
                "investigate in ",
            children: [
              TextSpan(
                text: "${toBeginningOfSentenceCase(placeClue.name)}\t?",
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  color: Colors.blueGrey.shade700,
                ),
              )
            ],
          ),
          style: GoogleFonts.poppins(
              fontSize: size.width * 0.03, color: Colors.grey),
        ),
      ),
      content: AnimatedSwitcher(
        duration: animDuration,
        child: mePlayer == null
            ? const CircularProgressIndicator()
            : Container(
                height: size.height * 0.35,
                width: size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(placeClue.imagePath),
                    opacity: 0.2,
                  ),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: ListView(
                        children: [
                          ...cards.entries
                              .where(
                                  (clue) => clue.value.type == CardType.person)
                              .whereNot((c) => mePlayer.clues.contains(c.key))
                              .map(
                            (e) {
                              final mClues =
                                  ref.watch(playerClueNotifier).pClues[e.key] ??
                                      {};
                              final players = Map<String, Player>.from(
                                  ref.watch(playersProvider).value ?? {});
                              return SizedBox(
                                height: size.height * 0.06,
                                child: InkWell(
                                  onTap: () => suspectNotifier.setCard(
                                      e.key, e.value.type),
                                  child: GridTileBar(
                                    leading: CircleAvatar(
                                      radius: size.width * 0.005,
                                    ),
                                    title: AutoSizeText(
                                      toBeginningOfSentenceCase(e.value.name) ??
                                          "",
                                      style: GoogleFonts.poppins(
                                          fontSize: size.width * 0.04,
                                          color: suspectNotifier.person == e.key
                                              ? Colors.blueGrey.shade700
                                              : Colors.blueGrey.shade300,
                                          fontWeight:
                                              suspectNotifier.person == e.key
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                    ),
                                    subtitle: mClues.isEmpty
                                        ? null
                                        : mClues.containsValue(
                                                PersonAnswer.verified)
                                            ? AutoSizeText(
                                                "${players[mClues.keys.firstWhere((element) => mClues[element] == PersonAnswer.verified)]!.name}'s clue",
                                                style: GoogleFonts.poppins(
                                                  fontSize: size.width * 0.025,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )
                                            : null,
                                    trailing: suspectNotifier.person == e.key
                                        ? const Icon(
                                            Icons.done,
                                            color: Colors.green,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          ...cards.entries
                              .where(
                                  (clue) => clue.value.type == CardType.person)
                              .where((c) => mePlayer.clues.contains(c.key))
                              .map(
                                (e) => SizedBox(
                                  height: size.height * 0.05,
                                  child: InkWell(
                                    onTap: () => suspectNotifier.setCard(
                                        e.key, e.value.type),
                                    child: GridTileBar(
                                      leading: CircleAvatar(
                                        radius: size.width * 0.005,
                                      ),
                                      title: AutoSizeText.rich(
                                        TextSpan(
                                          text: (toBeginningOfSentenceCase(
                                                  e.value.name) ??
                                              ""),
                                          children: [
                                            TextSpan(
                                              text: "\nYour clue",
                                              style: GoogleFonts.poppins(
                                                fontSize: size.width * 0.025,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          ],
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: size.width * 0.04,
                                          color: Colors.grey.shade600,
                                          fontWeight:
                                              suspectNotifier.person == e.key
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: suspectNotifier.person == e.key
                                          ? const Icon(
                                              Icons.done,
                                              color: Colors.green,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView(
                        children: [
                          ...cards.entries
                              .where(
                                  (clue) => clue.value.type == CardType.weapon)
                              .whereNot((c) => mePlayer.clues.contains(c.key))
                              .map(
                            (e) {
                              final mClues =
                                  ref.watch(playerClueNotifier).pClues[e.key] ??
                                      {};
                              final players = Map<String, Player>.from(
                                  ref.watch(playersProvider).value ?? {});
                              return SizedBox(
                                height: size.height * 0.06,
                                child: InkWell(
                                  onTap: () => suspectNotifier.setCard(
                                      e.key, e.value.type),
                                  child: GridTileBar(
                                    leading: CircleAvatar(
                                      radius: size.width * 0.005,
                                    ),
                                    title: AutoSizeText(
                                      toBeginningOfSentenceCase(e.value.name) ??
                                          "",
                                      style: GoogleFonts.poppins(
                                        fontSize: size.width * 0.04,
                                        color: suspectNotifier.weapon == e.key
                                            ? Colors.blueGrey.shade700
                                            : Colors.blueGrey.shade300,
                                        fontWeight:
                                            suspectNotifier.weapon == e.key
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: mClues.isEmpty
                                        ? null
                                        : mClues.containsValue(
                                                PersonAnswer.verified)
                                            ? AutoSizeText(
                                                "${players[mClues.keys.firstWhere((element) => mClues[element] == PersonAnswer.verified)]!.name}'s clue",
                                                style: GoogleFonts.poppins(
                                                  fontSize: size.width * 0.025,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )
                                            : null,
                                    trailing: suspectNotifier.weapon == e.key
                                        ? const Icon(
                                            Icons.done,
                                            color: Colors.green,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          ...cards.entries
                              .where(
                                  (clue) => clue.value.type == CardType.weapon)
                              .where((c) => mePlayer.clues.contains(c.key))
                              .map(
                                (e) => SizedBox(
                                  height: size.height * 0.05,
                                  child: InkWell(
                                    onTap: () => suspectNotifier.setCard(
                                        e.key, e.value.type),
                                    child: GridTileBar(
                                      leading: CircleAvatar(
                                        radius: size.width * 0.005,
                                      ),
                                      title: AutoSizeText.rich(
                                        TextSpan(
                                          text: (toBeginningOfSentenceCase(
                                                  e.value.name) ??
                                              ""),
                                          children: [
                                            TextSpan(
                                              text: "\nYour clue",
                                              style: GoogleFonts.poppins(
                                                fontSize: size.width * 0.025,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          ],
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: size.width * 0.04,
                                          color: Colors.grey.shade600,
                                          fontWeight:
                                              suspectNotifier.weapon == e.key
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: suspectNotifier.weapon == e.key
                                          ? const Icon(
                                              Icons.done,
                                              color: Colors.green,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        ...[
          RowSuper(
            children: [suspectNotifier.person, suspectNotifier.weapon]
                .map(
                  (e) => AnimatedSwitcher(
                    duration: animDuration,
                    child: CircleAvatar(
                      key: ValueKey(e),
                      backgroundColor: Colors.lightBlue,
                      child: cards.containsKey(e)
                          ? Image.asset(cards[e]!.imagePath)
                          : null,
                    ),
                  ),
                )
                .toList(),
            innerDistance: -size.width * 0.02,
          )
        ],
        ...["ACCUSE NOW", "CANCEL"].map(
          (e) => TextButton(
            onPressed: () => Navigator.pop(context, e.contains("ACCUSE NOW")),
            child: Text(e),
          ),
        ),
      ],
      backgroundColor: Colors.blueGrey.shade100,
    );
  }
}

class OnlyPlayers extends ConsumerWidget {
  const OnlyPlayers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final String uid = ref.watch(firebaseUserProvider).uid;
    final String currentId = ref.watch(currentIDProvider).maybeWhen(
          orElse: () => "",
          data: (data) => data,
        );
    final Map<String, ClueCard> cards =
        Map<String, ClueCard>.from(ref.watch(cardsProvider).value ?? {});

    return AnimatedSwitcher(
      duration: animDuration,
      child: ref.watch(playersProvider).when(
            data: (map) => map.isEmpty || currentId.isEmpty
                ? Container()
                : Column(
                    children: [
                      Flexible(
                        flex: 6,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: map.entries
                              //.take(3)
                              .map(
                                (e) => AnimatedOpacity(
                                  opacity: e.key == currentId ? 1 : 0.5,
                                  duration: animDuration,
                                  child: Container(
                                    width: size.width *
                                        (e.key == currentId ? 0.2 : 0.15),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade800,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/avatar_icon/${e.value.as}.png'),
                                        fit: BoxFit.cover,
                                        opacity: 0.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    padding: Pad(all: size.width * 0.02),
                                  ),
                                ),
                              )
                              .toList(),
                          //fitHorizontally: true,
                          //innerDistance: -size.width * 0.1,
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: AnimatedSwitcher(
                          duration: animDuration,
                          child: GridTileBar(
                            title: AutoSizeText(
                              uid == currentId
                                  ? "Your turn"
                                  : "It's ${map[currentId]!.name}'s turn.",
                              //" Wait for your turn",
                              key: ValueKey(currentId),
                              //textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.04,
                                color: Colors.blueGrey.shade700,
                              ),
                              maxLines: 1,
                            ),
                            subtitle: AutoSizeText(
                              uid == currentId
                                  ? ref.watch(mePlayerProvider).value == null
                                      ? ""
                                      : "You have ${ref.watch(mePlayerProvider).value!.clues.map((e) => toBeginningOfSentenceCase(cards[e]!.name) ?? "").join(",\t")}"
                                  : ref
                                          .watch(playerClueNotifier)
                                          .playerVerifiedClues(currentId)
                                          .isEmpty
                                      ? "No Cards for now"
                                      : "You found ${ref.watch(playerClueNotifier).playerVerifiedClues(currentId).map((e) => toBeginningOfSentenceCase(cards[e]!.name)).join(",\t")}",
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.02,
                                color: Colors.blueGrey,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
            error: (error, stackTrace) => Container(),
            loading: () => Container(),
          ),
    );
  }
}
