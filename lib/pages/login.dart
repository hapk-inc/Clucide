import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '/provider/auth.dart';

/*Text(
                "CLUCIDE",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.2,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )*/

final controller = TextEditingController();

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.black54,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    FlickerAnimatedText(
                      "CLUCIDE",
                      textStyle: GoogleFonts.poppins(
                        fontSize: size.width * 0.2,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      //colors: [Colors.black87, Colors.white70],
                      //speed: const Duration(seconds: 1),
                    )
                  ],
                  repeatForever: true,
                  isRepeatingAnimation: true,
                ),
              ),
              //fit: FlexFit.tight,
            ),
            Flexible(
              flex: 8,
              child: IntroductionScreen(
                pages: [
                  PageViewModel(
                    titleWidget: Text(
                      "SOLVE CRIME, MEAN TIME",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.wallpoet(
                          fontSize: size.width * 0.05, color: Colors.grey),
                    ),
                    bodyWidget: Container(
                      color: Colors.white,
                      child: Image.asset(
                        'assets/case-file.png',
                        alignment: Alignment.center,
                      ),
                    ),
                    decoration: const PageDecoration(
                      //pageColor: Colors.black87,
                      bodyAlignment: Alignment.center,
                    ),
                  ),
                  PageViewModel(
                    titleWidget: TextField(
                      controller: controller,
                      cursorHeight: size.height * 0.05,
                      cursorColor: Colors.indigo.shade100,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.075,
                        color: Colors.indigo,
                      ),
                      onEditingComplete: () {} /*=> _onSubmitted()*/,
                      decoration: InputDecoration(
                        hintText: "Enter Name",
                        filled: true,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: size.width * 0.075,
                          color: Colors.indigo.shade200,
                          fontWeight: FontWeight.w200,
                        ),
                        contentPadding: Pad(all: size.width * 0.05),
                      ),
                    ),
                    //image: Image.asset('assets/case-file.png'),
                    bodyWidget: Container(
                      padding: Pad(all: size.width * 0.05),
                      color: Colors.grey.shade200,
                      width: size.width,
                      height: size.height * 0.55,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                              Flexible(
                                flex: 2,
                                child: FadeInRight(
                                  child: Text(
                                    "How would like to login?",
                                    style: GoogleFonts.poppins(
                                      fontSize: size.width * 0.07,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ] +
                            AuthMethod.values
                                .map(
                                  (e) => AuthButton(authMethod: e),
                                )
                                .toList(),
                      ),
                    ),
                  )
                ],
                next: Text(
                  "NEXT",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //color: Colors.black54,
                showNextButton: true,
                showDoneButton: false,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AuthButton extends ConsumerWidget {
  final AuthMethod authMethod;
  const AuthButton({Key? key, required this.authMethod}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.75,
        child: Opacity(
          opacity: authMethod == AuthMethod.guest ? 0.5 : 1,
          child: ElevatedButton(
            onPressed: () {
              switch (authMethod) {
                case AuthMethod.gmail:
                  // TODO: Handle this case.
                  break;
                case AuthMethod.phone:
                  // TODO: Handle this case.
                  break;
                case AuthMethod.guest:
                  ref.watch(anonymousProvider(controller.text));
                  break;
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                authMethod == AuthMethod.gmail
                    ? Colors.red.shade700
                    : authMethod == AuthMethod.phone
                        ? Colors.green.shade700
                        : Colors.grey,
              ),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.02))),
              padding: MaterialStateProperty.all(Pad(all: size.width * 0.02)),
              elevation: MaterialStateProperty.all(
                  authMethod == AuthMethod.guest ? 4 : 8),
            ),
            child: FittedBox(child: ButtonName(authMethod: authMethod)),
          ),
        ),
      ),
    );
  }
}

class ButtonName extends StatelessWidget {
  final AuthMethod authMethod;
  const ButtonName({Key? key, required this.authMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    switch (authMethod) {
      /*case AuthMethod.gmail:
        return AutoSizeText.rich(
          TextSpan(
            text: "Sign in".toUpperCase(),
            children: [
              TextSpan(
                  text: " with ".toUpperCase(),
                  style: TextStyle(fontSize: size.width * 0.05)),
              TextSpan(
                text: "GMAIL",
                style: TextStyle(
                  fontSize: size.width * 0.075,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              //color: Colors.white60,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          maxLines: 1,
        );
      case AuthMethod.phone:
        return AutoSizeText.rich(
          TextSpan(
            text: "Sign in ".toUpperCase(),
            children: [
              TextSpan(
                text: "PHONE ",
                style: TextStyle(
                  fontSize: size.width * 0.075,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "NO.",
                style: TextStyle(
                  fontSize: size.width * 0.05,
                ),
              ),
            ],
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          maxLines: 1,
        );
      case AuthMethod.guest:
        return AutoSizeText.rich(
          TextSpan(
            text: "Sign in as ".toUpperCase(),
            children: [
              TextSpan(
                text: "GUEST",
                style: TextStyle(
                  fontSize: size.width * 0.075,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          maxLines: 1,
        );*/
      case AuthMethod.gmail:
        return Text(
          "Sign with Gmail Account",
          style: GoogleFonts.poppins(
              fontSize: size.width * 0.05, color: Colors.white70),
        );
      case AuthMethod.phone:
        return Text(
          "Sign with Phone Number",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            color: Colors.white70,
          ),
        );
      case AuthMethod.guest:
        return Text(
          "Sign with Guest User",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            color: Colors.white70,
          ),
        );
    }
  }
}

/*Text(
                                          e.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: size.width * 0.05,
                                          ),
                                        )*/
