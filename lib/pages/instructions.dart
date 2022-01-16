import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:traccia/pages/providers/board.dart';

import 'providers/how_to_play.dart';

class HowToPlay extends ConsumerWidget {
  const HowToPlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: IntroductionScreen(
            pages: [
              PageViewModel(
                  title: "Introduction",
                  bodyWidget: const Text(
                      "Chief Burns finds wealthy industrialist Charles dead, "
                      "and it looks like foul play. "
                      "Burns round up siz likely suspects: "
                      "\nEmily, Mr. Cheng, Ken, Regina, Regina and Richard. "
                      "\n\nTo win, you must determine the answers to these questions:"
                      "\n\nWho did it? Where? and with what Weapon?\n\n"
                      "Three Groups - Persons, Weapons and Locations were shuffled separately "
                      "and one card from each group will be taken. "
                      "The Case file now contains the answers: "
                      "Who? Where? and with what Weapon?\n\n"
                      "\t\tRemaining Cards will be shuffled among the players"
                      "(It doesn't matter if some players receive more cards than others). "
                      "Look at your own cards. Because they're in your hand,"
                      " they can't be in the Case File - "
                      "which means none of your cards was involved in the crime.\n\n")),
              PageViewModel(
                title: "Game Play",
                bodyWidget: const Text(
                    "On each turn, try to reach a different location. "
                    "You may not enter a place that's already occupied by another suspect\n"
                    "\n\nMaking a Suggestions - As soon as you enter a location, make a suggestion. "
                    "By making suggestions throughout the game, you try to determine - "
                    "by process of elimination - which three case are in the Case File."
                    "\nTo make a suggestion, choose a Suspect and a Weapon into the "
                    "location that you just entered. "
                    "Then suggest that the crime was committed in that Location, "
                    "by that Suspect, with what Weapon.\n\n"
                    "Example: Let's say that you're Cheng and you enter the Basket Court. "
                    "By Clicking a Suspect - Regina, for instance. "
                    "Then selecting a weapon - Syringe, perhaps - into the court. "
                    "This means that you're suggest the crime was committed in the"
                    " Basketball court by Regina with the Syringe.\n\n"
                    "Remember two things: * You must be in the Location that "
                    "you mention in your Suggestion."
                    "* Be sure to consider all Cards- including spare Suspects "
                    "and including yourself!"
                    "-as falling under equal suspicion\n\n"),
              ),
              PageViewModel(
                title: "Game Play",
                bodyWidget: const Text(
                  "Proving a Suggestion True or False-"
                  "-As soon as you make a Suggestion,"
                  " your opponents, in turn, try to prove it false."
                  "If the next player does have one of the cards named, "
                  "he or she must show it to you and no one else."
                  "If the player has more than one of the cards named, "
                  "he or she selects just one to show you"
                  "If that opponent has none of the cards that you named, "
                  "then the chance to prove your Suggestion false passes, "
                  "in turn, to the next Player"
                  "As soon as one opponent shows you one of the cards that you named, "
                  "it is proof that this card cannot be in the envelope"
                  "If no one is able to prove your Suggestion false, "
                  "you may either end your turn or make a Accusation now.\n\n"
                  "Making an accusation-- When you think you've figured out which "
                  "three cards in the case file, you may, on your turn, "
                  "make an Accusation and choose three elements you want "
                  "and click Accuse now button\n\n"
                  "Remember: You may make only one Accusation during a game\n\n",
                ),
              ),
              PageViewModel(
                title: "Accusation",
                bodyWidget: const Text(
                    "If your accusation is Incorrect---If any of the cards that you "
                    "named is not inside the Case File:"
                    "* You may make no further moves in the game, "
                    "and therefore, cannot win"
                    "* You do continue to try to prove your "
                    "opponent's Suggestion false by"
                    " showing cards when asked"
                    "\n\nWinning--You win he game if your Accusation is "
                    "completely correct- that is, "
                    "if you find in the case file all three "
                    "of the cards that you "
                    "named"),
              )
            ],
            showNextButton: false,
            showDoneButton: false,
            showSkipButton: false,
          ),
        ),
      );
}

/*Stack(
          children: [
            PageView(
              controller: instructionPageController,
              onPageChanged: (i) =>
                  ref.watch(indexStateProvider.notifier).state = i,
              children: [
                Opacity(
                  opacity: math.max(0, math.max(0, _offsetValue)),
                  child: Container(
                    color: Colors.blue.shade50,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * 0.05,
                        horizontal: size.width * 0.02),
                    child: const PageOne(),
                  ),
                ),
                Container(),
                Container(),
              ],
            ),
            const RowIndicator()
          ],
        )*/

class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return RichText(
      text: TextSpan(
        children: [
              WidgetSpan(
                child: FadeInRight(
                  child: Text(
                    "Instructions",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.05,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
              TextSpan(
                style: TextStyle(fontSize: size.width * 0.04),
                children: const [
                  TextSpan(
                      text:
                          "\n\nChief Burns find wealthy industrialist Charles dead,\t"),
                  TextSpan(
                      text: "and it looks like foul play. "
                          "Burns round up six likely suspects :\n\n"),
                ],
              )
            ] +
            List.from(
              persons.map(
                (e) => TextSpan(
                  text: "${toBeginningOfSentenceCase(e) ?? ""},\t",
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
              ),
            ) +
            [
              TextSpan(
                text: "\n\nTo win, you must determine the "
                    "answers to these questions:\n\n",
                children: [
                  WidgetSpan(
                    child: FadeInRight(
                      child: Text(
                        "Who did it? \nWhere? \nwith what Weapon?",
                        style: TextStyle(
                            color: Colors.black54, fontSize: size.width * 0.07),
                      ),
                    ),
                  ),
                ],
              ),
              const TextSpan(
                text: "\n\nThree groups:\n",
                children: [
                  TextSpan(
                      text:
                          "\t Persons, Places and Weapons were shuffled separately "
                          "and one card from each group will be taken."
                          "\tRemaining Cards will be shuffled among the players"),
                  TextSpan(
                      text:
                          "(It doesn't matter if some players receive more cards than others)",
                      style: TextStyle(
                          fontWeight: FontWeight.w100, color: Colors.black38))
                ],
              ),
            ],
        style: GoogleFonts.poppins(color: Colors.black87),
      ),
    );
  }
}

class RowIndicator extends ConsumerWidget {
  const RowIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      width: size.width,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.025),
        child: AppBar(
          backgroundColor: Colors.transparent,
          leadingWidth: size.width * 0.175,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              3,
              (index) => Flexible(
                child: AnimatedContainer(
                  width: ref.watch(indexStateProvider) == index
                      ? size.width * 0.03
                      : size.width * 0.02,
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: ref.watch(indexStateProvider) == index
                        ? Colors.blue
                        : Colors.black38,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
