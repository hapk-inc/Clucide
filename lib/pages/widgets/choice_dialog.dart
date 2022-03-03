import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/clue_card.dart';
import '../../models/player.dart';
import '../../provider/auth.dart';
import '../../provider/board.dart';

class ChoiceDialog extends ConsumerWidget {
  final String placeId;
  const ChoiceDialog({Key? key, required this.placeId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
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

    String camelCase(String v) => toBeginningOfSentenceCase(v) ?? "";

    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        elevation: 8,
        backgroundColor: cards[placeId]!.dialogColor.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.025),
        ),
        title: TabBar(
          tabs: const [
            Tab(text: "Person"),
            Tab(text: "Weapon"),
          ],
          labelStyle: GoogleFonts.poppins(color: Colors.black87),
        ),
        content: SizedBox(
          height: size.height * 0.5,
          width: size.width,
          child: TabBarView(
            children: [
              Container(color: Colors.red),
              Container(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "CANCEL",
              style: GoogleFonts.poppins(color: Colors.brown.shade100),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(cards[placeId]!.dialogColor),
            ),
            child: Text("CREATE ROUND"),
          )
        ],
      ),
    );
  }
}

/*AlertDialog(
      backgroundColor: cards[placeId]!.dialogColor.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.025),
      ),
      content: cards.isEmpty
          ? Container()
          : SizedBox(
              //color: Colors.blue,
              height: size.height,
              width: size.width,
              child: FadeInUp(
                child: DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 2,
                        child: TabBar(
                          tabs: const [
                            Tab(
                              child: Text(
                                "Person",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Weapon",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                          labelStyle:
                              GoogleFonts.poppins(color: Colors.black87),
                          unselectedLabelStyle:
                              GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      Flexible(
                        flex: 18,
                        child: TabBarView(
                          children: [
                            LayoutBuilder(
                              builder: (_, constraints) => GridView(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                        childAspectRatio: 1 /
                                            ((constraints.maxHeight * 0.6) /
                                                constraints.maxWidth)),
                                children: idList
                                    .where((element) =>
                                        cards[element]!.type == CardType.person)
                                    .map(
                                      (e) => GridTile(
                                        child: Container(
                                          color: cards[placeId]!.dialogColor,
                                          padding: Pad(all: size.width * 0.02),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                flex: 4,
                                                child: Image.asset(
                                                  cards[e]!.imagePath,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                              ),
                                              Flexible(
                                                child: AutoSizeText(
                                                  camelCase(cards[e]!.name),
                                                  style: GoogleFonts.poppins(
                                                      fontSize:
                                                          size.width * 0.02),
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
                            LayoutBuilder(
                              builder: (_, constraints) => GridView(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                        childAspectRatio: 1 /
                                            ((constraints.maxHeight * 0.6) /
                                                constraints.maxWidth)),
                                children: idList
                                    .where((element) =>
                                        cards[element]!.type == CardType.weapon)
                                    .map(
                                      (e) => GridTile(
                                        child: Container(
                                          color: cards[placeId]!.dialogColor,
                                          padding: Pad(all: size.width * 0.02),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                flex: 4,
                                                child: Image.asset(
                                                  cards[e]!.imagePath,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                              ),
                                              Flexible(
                                                child: AutoSizeText(
                                                  camelCase(cards[e]!.name),
                                                  style: GoogleFonts.poppins(
                                                      fontSize:
                                                          size.width * 0.02),
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
                          ],
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: ButtonBar(
                            children: ["CANCEL", "START ROUND"]
                                .map((e) => ElevatedButton(
                                    onPressed: () {}, child: Text(e)))
                                .toList(),
                          )),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        RowSuper(
          children: mePlayer.clues
              .take(3)
              .map(
                (e) => Image.asset(
                  cards[e]!.imagePath,
                  width: size.width * 0.175,
                ),
              )
              .toList(),
        )
      ],
      /*title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "Which ",
                  children: [
                    TextSpan(
                      text: "clues\n",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: size.width * 0.045,
                      ),
                    ),
                    const TextSpan(text: "you want to\n check"),
                  ],
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    color: cards[placeId]!.dialogColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              child: FadeInRight(
                child: RichText(
                  text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: FadeInRight(
                            child: SizedBox.square(
                              dimension: size.height * 0.125,
                              child: Image.asset(cards[placeId]!.imagePath),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "\nin ",
                          style: TextStyle(fontSize: size.width * 0.03),
                        ),
                        TextSpan(
                          text: camelCase(cards[placeId]!.name),
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      style: GoogleFonts.poppins(
                          color: cards[placeId]!.dialogColor)),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ],
      ),*/
      /*actions: [
        ElevatedButton(
          onPressed: () {},
          child: const Text("Start Round"),
        )
      ],*/
    )*/
