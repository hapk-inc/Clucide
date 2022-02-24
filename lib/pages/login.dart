import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/provider/auth.dart';

final controller = TextEditingController();

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
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
              flex: 6,
              child: Box(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        "Let's solve a crime.".toUpperCase(),
                        style: GoogleFonts.wallpoet(
                          fontSize: size.width * 0.04,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Image.asset(
                        'assets/case-file.png',
                        alignment: Alignment.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: ButtonBarSuper(
                alignment: WrapSuperAlignment.right,
                wrapFit: WrapFit.min,
                children: [
                  TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          "Enter your name and Login",
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        content: FractionallySizedBox(
                          heightFactor: 0.3,
                          child: Box(
                            padding: Pad(all: size.width * 0.01),
                            child: const Center(
                              child: NameTextField(),
                            ),
                          ),
                        ),
                        actions: [
                          Consumer(
                            builder: (context, ref, child) => TextButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  ref.watch(anonymousProvider(controller.text));
                                }
                              },
                              child: Text(
                                "LOGIN",
                                style: TextStyle(fontSize: size.width * .04),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    child: Text(
                      "START",
                      style: GoogleFonts.luckiestGuy(
                          fontSize: size.width * .05, color: Colors.grey
                          //fontWeight: FontWeight.bold,
                          ),
                      //style: GoogleFonts.poppins(),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

final _formKey = GlobalKey<FormState>();

class NameTextField extends StatelessWidget {
  const NameTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: controller,
        autofocus: true,
        validator: (value) {
          String text = value ?? "";
          return text.isEmpty || text.length < 5
              ? "Name should be more than 5 characters"
              : null;
        },
        decoration: InputDecoration(
          hintText: "Ex: Sherlock",
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          errorStyle: GoogleFonts.poppins(), errorMaxLines: 2,
          //errorText: validateText(controller.text),
        ),
        style: GoogleFonts.poppins(
          color: Colors.blue,
          fontSize: size.width * 0.04,
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
