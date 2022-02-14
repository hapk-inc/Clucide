import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traccia/models/game_user.dart';
import 'package:traccia/provider/auth.dart';

enum DrawerList { instructions, signOut, version }

Widget drawerListTile(DrawerList list, Size size) {
  switch (list) {
    case DrawerList.instructions:
      return SizedBox(
        height: size.height * 0.09,
        child: ListTile(
          title: AutoSizeText(
            "How to play",
            maxLines: 1,
            style: TextStyle(
              fontSize: size.width * 0.05,
              color: Colors.black54,
            ),
          ),
          subtitle: const AutoSizeText("Learn the instructions"),
          /*leading: Icon(
            FontAwesomeIcons.clipboard,
            size: size.width * 0.075,
          ),*/
        ),
      );
    case DrawerList.signOut:
      return SizedBox(
        height: size.height * 0.09,
        child: Consumer(
          builder: (_, ref, __) => ListTile(
            onTap: () => ref.watch(signOutProvider),
            title: AutoSizeText(
              "Sign out",
              maxLines: 1,
              style: TextStyle(
                fontSize: size.width * 0.05,
                color: Colors.black54,
              ),
            ),
            subtitle: const AutoSizeText("Logging off "),
            /*leading: Icon(
              FontAwesomeIcons.signOutAlt,
              size: size.width * 0.075,
            ),*/
          ),
        ),
      );
    case DrawerList.version:
      return SizedBox(
        height: size.height * 0.09,
        child: Consumer(
          builder: (__, ref, _) => ListTile(
            title: AutoSizeText(
              "App version",
              maxLines: 1,
              style: TextStyle(
                fontSize: size.width * 0.05,
                color: Colors.black54,
              ),
            ),
            subtitle: const AutoSizeText("Latest App Version"),
            /*leading: Icon(
              FontAwesomeIcons.googlePlay,
              size: size.width * 0.075,
            ),*/
          ),
        ),
      );
  }
}

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const DrawerHeader(),
          Flexible(
            flex: 8,
            child: ListView.separated(
              itemBuilder: (listContxt, index) => drawerListTile(
                  DrawerList.values[index], MediaQuery.of(listContxt).size),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: DrawerList.values.length,
            ),
          ),
        ],
      );
}

class DrawerHeader extends ConsumerWidget {
  const DrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;

    final GameUser gameUser = ref.watch(gameUserProvider).value!;
    return Flexible(
      flex: 2,
      child: Row(
        children: [
          /* Flexible(
            flex: 3,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: CircleAvatar(
                radius: size.width * 0.2,
              ),
            ),
          ),*/
          Flexible(
            flex: 7,
            child: ListTile(
              title: AutoSizeText(
                gameUser.name,
                style: GoogleFonts.poppins(fontSize: size.width * 0.06),
                maxLines: 1,
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 6,
                    child: AutoSizeText.rich(
                      //"ID 012345",
                      TextSpan(
                        children: [
                          TextSpan(
                              text: "ID:\t",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: size.width * 0.04)),
                          TextSpan(text: gameUser.id.toString()),
                        ],
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "EDIT",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
