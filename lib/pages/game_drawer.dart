import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/model/clue_card.dart';
import '/model/player.dart';

import 'providers/auth.dart';
import 'providers/board.dart';

class GameDrawer extends ConsumerWidget {
  const GameDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String user = ref.watch(firebaseUserProvider).uid;
    final Map<String, ClueCard> cards = ref.watch(cardsProvider).value!;
    final Map<String, Player> players = ref.watch(playersProvider).value!;
    final Size size = MediaQuery.of(context).size;
    final playerClues = ref.watch(playerClueNotifier).pClues;
    final Player me = players[user]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            alignment: Alignment.center,
            //padding: EdgeInsets.all(size.width * 0.01),
            child: ListTile(
              leading: Image.asset(
                  'assets/avatar_icon/${me.as}.png') /*Icon(
                Icons.person,
                color: Colors.blue,
                size: size.height * 0.075,
              )*/
              ,
              contentPadding: EdgeInsets.all(size.width * 0.02),
              title: Text(
                me.name,
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.blue),
              ),
              subtitle: Text(
                "as " + (toBeginningOfSentenceCase(players[user]!.as) ?? ""),
                style: TextStyle(
                    fontSize: size.width * 0.025, color: Colors.black87),
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey.shade400,
          thickness: 0.5,
        ),
        Flexible(
          flex: 9,
          child: SingleChildScrollView(
            child: ExpansionPanelList(
              children: cards.entries.map(
                (e) {
                  final String iconId = e.key;
                  final Map<String, PersonAnswer>? iconMap =
                      playerClues.containsKey(iconId)
                          ? playerClues[iconId]
                          : null;
                  return ExpansionPanel(
                    headerBuilder: (_, __) => Container(
                      height: size.height * 0.07,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: ListTile(
                        leading: e.value.type == CardType.place
                            ? Image.asset(
                                'assets/places_icon/${e.value.name}.png')
                            : e.value.type == CardType.weapon
                                ? Image.asset(
                                    'assets/weapons_icon/${e.value.name}.png')
                                : Image.asset(
                                    'assets/avatar_icon/${e.value.name}.png'),
                        title: Text(
                          toBeginningOfSentenceCase(e.value.name) ?? "",
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                        ),
                        trailing: me.clues.contains(iconId)
                            ? Text(
                                "My Card",
                                style: TextStyle(
                                  fontSize: size.width * 0.0225,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : playerClues.containsKey(iconId)
                                ? playerClues[iconId]!
                                        .containsValue(PersonAnswer.verified)
                                    ? Text(
                                        players[playerClues[iconId]!
                                                .entries
                                                .firstWhere((element) =>
                                                    element.value ==
                                                    PersonAnswer.verified)
                                                .key]!
                                            .name,
                                        style: TextStyle(
                                          fontSize: size.width * 0.0225,
                                          color: Colors.blue,
                                        ),
                                      )
                                    : const Icon(Icons.priority_high)
                                : null,
                      ),
                    ),
                    body: Container(
                      height: size.height * 0.075,
                      color: Colors.white70,
                      padding: EdgeInsets.all(size.width * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 9,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: iconMap == null
                                  ? Container()
                                  : PlayerAnswerStateList(icon: iconId),
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(size.width * 0.025),
                                    topRight:
                                        Radius.circular(size.width * 0.025),
                                  ),
                                ),
                                builder: (_) => AddPlayerClue(e.key),
                              ),
                              icon: Icon(
                                Icons.add,
                                size: size.width * 0.035,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    isExpanded: ref.watch(expansionTileProvider(e.key)),
                    backgroundColor: e.value.type == CardType.person
                        ? Colors.blue.shade100
                        : e.value.type == CardType.weapon
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                  );
                },
              ).toList(),
              dividerColor: Colors.white70,
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) {
                final String cardId = cards.keys.elementAt(panelIndex);
                if (!me.clues.contains(cardId)) {
                  ref.watch(expansionTileProvider(cardId).notifier).state =
                      !isExpanded;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AddPlayerClue extends ConsumerWidget {
  final String iconId;
  const AddPlayerClue(this.iconId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerClueN = ref.watch(playerClueNotifier);
    final String userId = ref.watch(firebaseUserProvider).uid;
    final Map<String, Map<String, PersonAnswer>> clueMap =
        Map<String, Map<String, PersonAnswer>>.from(playerClueN.pClues);
    final Size size = MediaQuery.of(context).size;
    final Map<String, Player> players =
        Map<String, Player>.from(ref.watch(playersProvider).value ?? {});
    players.remove(userId);
    if (clueMap.containsKey(iconId)) {
      Map<String, PersonAnswer>? answers = clueMap[iconId];
      players.removeWhere((key, value) => answers!.containsKey(key));
    }

    return FractionallySizedBox(
      heightFactor: 0.15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size.width * 0.025),
            topRight: Radius.circular(size.width * 0.025),
          ),
        ),
        padding: EdgeInsets.all(size.width * 0.02),
        child: ListView.separated(
          itemBuilder: (_, index) {
            final String playerId = players.keys.elementAt(index);
            final String name = players.values.elementAt(index).name;
            return ActionChip(
              label: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: GoogleFonts.poppins(
                          color: Colors.blue, fontSize: size.width * 0.03),
                    ),
                    WidgetSpan(
                      child: Icon(
                        Icons.priority_high,
                        size: size.width * 0.05,
                      ),
                    )
                  ],
                ),
              ),
              elevation: 4,
              onPressed: () {
                playerClueN.update(iconId, playerId, PersonAnswer.inDoubt);
                Navigator.pop(context);
              },
            );
          },
          separatorBuilder: (_, __) => SizedBox(width: size.width * 0.05),
          itemCount: players.length,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}

class PlayerAnswerStateList extends ConsumerWidget {
  final String icon;
  const PlayerAnswerStateList({required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, PersonAnswer> iconMap =
        ref.watch(playerClueNotifier).pClues[icon]!;
    final players = ref.watch(playersProvider).value!;
    final Size size = MediaQuery.of(context).size;

    Icon perSonAnswer(PersonAnswer answer) {
      switch (answer) {
        case PersonAnswer.yes:
          return Icon(Icons.done,
              color: Colors.green.shade200, size: size.width * 0.05);
        case PersonAnswer.no:
          return Icon(Icons.close,
              color: Colors.red.shade200, size: size.width * 0.05);
        case PersonAnswer.verified:
          return Icon(Icons.done_all,
              color: Colors.blue.shade700, size: size.width * 0.05);
        case PersonAnswer.inDoubt:
          return Icon(Icons.priority_high,
              color: Colors.brown.shade200, size: size.width * 0.05);
      }
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: iconMap.length,
      itemBuilder: (_, int index) {
        final String playerId = iconMap.keys.elementAt(index);
        final String name = players[playerId]!.name;
        return FadeIn(
          child: ActionChip(
            backgroundColor: Colors.blue.shade50,
            label: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: size.width * 0.0275,
                    ),
                  ),
                  WidgetSpan(
                    child: perSonAnswer(iconMap[playerId]!),
                  )
                ],
              ),
            ),
            elevation: 4,
            onPressed: () {
              PersonAnswer? newAnswer;
              switch (iconMap[playerId]!) {
                case PersonAnswer.yes:
                  newAnswer = PersonAnswer.inDoubt;
                  break;
                case PersonAnswer.no:
                  newAnswer = PersonAnswer.yes;
                  break;
                case PersonAnswer.inDoubt:
                  newAnswer = PersonAnswer.no;
                  break;
                case PersonAnswer.verified:
                  break;
              }
              if (newAnswer != null) {
                ref.read(playerClueNotifier).update(
                      icon,
                      playerId,
                      newAnswer,
                    );
              }
            },
          ),
        );
      },
      separatorBuilder: (_, __) => SizedBox(width: size.width * 0.025),
    );
  }
}
