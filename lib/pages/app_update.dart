import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lottie/lottie.dart';

class AppUpdatePage extends ConsumerWidget {
  const AppUpdatePage({Key? key}) : super(key: key);

  /*DefaultTextStyle(
  style: const TextStyle(
    fontSize: 20.0,
  ),
  child: AnimatedTextKit(
    animatedTexts: [
      WavyAnimatedText('Hello World'),
      WavyAnimatedText('Look at the waves'),
    ],
    isRepeatingAnimation: true,
    onTap: () {
      print("Tap Event");
    },
  ),
);*/

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: Pad(all: size.width * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                child: Text(
              "Update is available",
              style: GoogleFonts.poppins(fontSize: size.width * 0.07),
              textAlign: TextAlign.center,
            )),
            Flexible(
              flex: 2,
              child: Lottie.asset('assets/google-btn.json'),
            ),
            const Flexible(flex: 3, child: UpdateButton())
          ],
        ),
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  const UpdateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FractionallySizedBox(
      heightFactor: 0.3,
      widthFactor: 0.9,
      child: ElevatedButton(
        onPressed: () {
          print("Running App Update");
          InAppUpdate.performImmediateUpdate().catchError(
            (error, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Reopen the app again for update.',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            },
          );
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black54),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.05),
              ),
            ),
            padding: MaterialStateProperty.all(Pad(all: size.width * 0.025)),
            elevation: MaterialStateProperty.all(8)),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: FittedBox(
                  child: Text(
                    "Get in on",
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: FittedBox(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        "Google Play Store",
                        textStyle: GoogleFonts.poppins(
                            fontSize: size.width * 0.075,
                            fontWeight: FontWeight.w500),
                        colors: [
                          Colors.white70,
                          Colors.blue,
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                        ],
                      )
                    ],
                    isRepeatingAnimation: true,
                    repeatForever: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*Text(
                  "Google Play Store",
                  style: GoogleFonts.poppins(
                      fontSize: size.width * 0.07, fontWeight: FontWeight.w500),
                )*/

/*const colorizeColors = [
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.red,
];

const colorizeTextStyle = TextStyle(
  fontSize: 50.0,
  fontFamily: 'Horizon',
);

return SizedBox(
  width: 250.0,
  child: AnimatedTextKit(
    animatedTexts: [
      ColorizeAnimatedText(
        'Larry Page',
        textStyle: colorizeTextStyle,
        colors: colorizeColors,
      ),
      ColorizeAnimatedText(
        'Bill Gates',
        textStyle: colorizeTextStyle,
        colors: colorizeColors,
      ),
      ColorizeAnimatedText(
        'Steve Jobs',
        textStyle: colorizeTextStyle,
        colors: colorizeColors,
      ),
    ],
    isRepeatingAnimation: true,
    onTap: () {
      print("Tap Event");
    },
  ),
);
Note: colo*/
