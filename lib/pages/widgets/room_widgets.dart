import 'package:animate_do/animate_do.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '/provider/room.dart';

class RoomPlayers extends ConsumerWidget {
  final String creatorId;
  const RoomPlayers(this.creatorId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 2,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: ref.watch(roomPlayerProvider).when(
              data: (data) {
                return WrapSuper(
                  alignment: WrapSuperAlignment.center,
                  spacing: -size.width * 0.05,
                  lineSpacing: -size.height * 0.01,
                  children: data.entries.map<Widget>(
                    (e) {
                      Map map = e.value;
                      final String name = map['name'];

                      return CircleName(
                        name: name,
                        radiusFactor: 0.15,
                        backgroundColor: e.key == creatorId
                            ? Colors.purple.shade100
                            : Colors.purple.shade400,
                        fontColor: e.key != creatorId
                            ? Colors.purple.shade100
                            : Colors.purple,
                        titleFactor: 0.05,
                        subTitleFactor: 0.015,
                      );
                    },
                  ).toList(),
                );
              },
              error: (error, stackTrace) => const CircularProgressIndicator(),
              loading: () => Container(),
            ),
      ),
    );
  }
}

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
                        //fontSize: size.height * 0.05,
                        fontSize: size.height * titleFactor,
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: AutoSizeText(
                      name,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        color: fontColor,
                        fontSize: size.height * subTitleFactor,
                        //fontSize: size.height * 0.015,
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
