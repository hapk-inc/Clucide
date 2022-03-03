import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CircleName extends StatelessWidget {
  final String name;
  final double radiusFactor;
  final Color backgroundColor;
  final Color fontColor;
  final double titleFactor;
  final double subTitleFactor;

  const CircleName({
    required this.name,
    required this.radiusFactor,
    required this.backgroundColor,
    required this.fontColor,
    required this.titleFactor,
    required this.subTitleFactor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FadeInRight(
      child: SizedBox.square(
        dimension: size.height * radiusFactor,
        child: Card(
          color: backgroundColor,
          elevation: 8,
          shape: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.025),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    child: AutoSizeText(
                      name.substring(0, 3).toUpperCase(),
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: size.height * titleFactor,
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    child: FittedBox(
                      child: AutoSizeText(
                        name,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          color: fontColor,
                          fontSize: size.height * subTitleFactor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
