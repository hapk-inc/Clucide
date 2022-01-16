import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'game_room.dart';
import 'providers/pages.dart';
import 'providers/room.dart';

import 'providers/auth.dart';
import 'providers/game_id.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        toolbarHeight: size.height * 0.1,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(size.height * 0.015),
            bottomRight: Radius.circular(size.height * 0.015),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: ref.watch(gameUserProvider).when(
                data: (data) => Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hi ${data == null ? "Unknown" : data.name}",
                    key: ValueKey(data),
                  ),
                ),
                error: (error, stackTrace) => Container(),
                loading: () => Container(),
              ),
        ),
        titleTextStyle: GoogleFonts.poppins(fontSize: size.width * 0.05),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const EditName(),
            ),
            icon: const Icon(Icons.edit),
          ),
          TextButton(
            onPressed: () => ref.read(signOutProvider),
            child: Text(
              "SIGN OUT",
              style: GoogleFonts.poppins(
                fontSize: size.height * 0.02,
                color: Colors.white60,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            //textDirection: ,
            children: [
              Flexible(
                child: Center(
                  child: Text(
                    "Join your friend's code",
                    style: TextStyle(fontSize: size.height * 0.025),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.025),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (value) {},
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      fieldWidth: size.width * 0.1,
                      fieldHeight: size.height * 0.1,
                    ),
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    onCompleted: (code) =>
                        ref.read(validateCodeProvider(code).future).then(
                      (_id) {
                        ref.read(idNotifierProvider.notifier).state = _id;
                        ref.read(pageProvider).addNext(
                            MyPage(const GameRoom(), arguments: false));
                      },
                    ).whenComplete(() => ref.read(joinRoomProvider)),
                    showCursor: false,
                    textStyle: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: size.height * 0.05,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "or\t",
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                          color: Colors.black38,
                        ),
                      ),
                      TextSpan(
                        text: "Ready to\t",
                        style: TextStyle(
                          fontSize: size.height * 0.0275,
                          color: Colors.black54,
                        ),
                      ),
                      TextSpan(
                        text: "start investigation",
                        style: TextStyle(
                          fontSize: size.height * 0.02775,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.5,
                  child: ElevatedButton(
                    onPressed: () => ref.watch(createRoomProvider.future).then(
                      (_id) {
                        ref.read(idNotifierProvider.notifier).state = _id;
                        ref
                            .read(pageProvider)
                            .addNext(MyPage(const GameRoom(), arguments: true));
                      },
                    ).whenComplete(() => ref.watch(joinRoomProvider)),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blue.shade100),
                    ),
                    child: Text(
                      "Create Game",
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: size.height * 0.025,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EditName extends ConsumerWidget {
  const EditName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final textController = TextEditingController();
    return AlertDialog(
      backgroundColor: Colors.blue.shade700,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      actionsPadding: EdgeInsets.all(size.width * 0.01),
      titleTextStyle: GoogleFonts.poppins(
          color: Colors.white70, fontSize: size.width * 0.05),
      title: const Text("Edit Name"),
      content: FractionallySizedBox(
        heightFactor: 0.25,
        child: Center(
          child: TextField(
            controller: textController,
            autofocus: true,
            cursorColor: Colors.white12,
            keyboardType: TextInputType.name,
            style: GoogleFonts.poppins(
                fontSize: size.height * 0.025, color: Colors.yellow),
            decoration: InputDecoration(
              alignLabelWithHint: true,
              /*border: OutlineInputBorder(
                borderSide: BorderSide(width: size.width * 0.001),
              ),*/
              labelText: "Your new name is",
              labelStyle: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                color: Colors.white54,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: const BorderSide(
                  color: Colors.white38,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: const ["UPDATE", "DISCARD"]
          .map(
            (e) => TextButton(
              onPressed: () async {
                if (e.contains("UPDATE")) {
                  await ref
                      .watch(updateNameProvider(textController.text).future);
                  ref.refresh(gameUserProvider);
                }
                Navigator.pop(context);
                //}
              },
              child: Text(
                e,
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: size.width * 0.04),
              ),
            ),
          )
          .toList(),
    );
  }
}
