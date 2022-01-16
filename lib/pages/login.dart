import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/clucide_logo.png'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: size.height * 0.025,
                left: size.width * 0.025,
                child: FadeInLeft(
                  child: RichText(
                    text: TextSpan(
                      text: "HAPK\n",
                      style: GoogleFonts.poppins(
                          fontSize: size.height * 0.03125,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold
                          //letterSpacing: size.width * 0.0125,
                          ),
                      children: [
                        TextSpan(
                          text: "PRESENTS",
                          style: TextStyle(
                            fontSize: size.height * 0.0175,
                            color: Colors.brown.shade200,
                            fontWeight: FontWeight.w200,
                          ),
                        )
                      ],
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              Center(
                child: FadeIn(
                  child: Text(
                    "CLUCIDE",
                    style: GoogleFonts.poppins(
                      fontSize: size.height * 0.05,
                      color: Colors.red.shade100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                height: size.height * 0.15,
                width: size.width,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FadeInDown(
                        child: Text(
                          "How would you like to login?",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: size.height * 0.02,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.025),
                        child: Consumer(
                          builder: (_, ref, __) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: FadeInLeft(
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "G",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: size.height * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: FadeInRight(
                                  child: TextButton(
                                    child: Text(
                                      "AS GUEST",
                                      style: GoogleFonts.poppins(
                                        fontSize: size.height * 0.02,
                                        color: Colors.white70,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    onPressed: () => ref.read(anonymousProvider(
                                        "Guest${1000 + Random().nextInt(9999 - 1000)}")),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
