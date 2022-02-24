import 'package:animate_do/animate_do.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:traccia/models/game_user.dart';
import 'package:traccia/pages/widgets/room_widgets.dart';
import 'package:traccia/provider/auth.dart';
import 'package:traccia/provider/game_id.dart';
import 'package:traccia/provider/room.dart';
import 'package:traccia/route/my_router.gr.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        //appBar: AppBar(),
        /*  drawer: const Drawer(
          child: DashboardDrawer(),
          backgroundColor: Colors.white,
        ),*/
        body: DashboardState(),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /*if (kDebugMode) {
      print("31 State is" + state.name);
    }
    switch (state) {
      case AppLifecycleState.resumed:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }*/
    if (state == AppLifecycleState.inactive) {}
    super.didChangeAppLifecycleState(state);
  }
}

class DashboardState extends ConsumerWidget {
  const DashboardState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        padding: Pad(all: size.width * 0.02),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mall.jpg'),
            fit: BoxFit.fitHeight,
            opacity: 0.1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 3,
              child: FadeInUp(
                child: ListTile(
                  title: AutoSizeText(
                    "CLUCIDE",
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: AutoSizeText(
                    "LET'S SOLVE CRIME",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.wallpoet(fontSize: size.width * 0.05),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 7,
              child: Column(
                children: [
                  Flexible(
                    flex: 3,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        CircleName(
                          name: "Dhanush",
                          radiusFactor: 0.12,
                          backgroundColor: Colors.blue,
                          fontColor: Colors.white,
                          titleFactor: 0.4,
                          subTitleFactor: 0.2,
                        ),
                        CircleName(
                          name: "Dhanush",
                          radiusFactor: 0.1,
                          backgroundColor: Colors.blue,
                          fontColor: Colors.white,
                          titleFactor: 0.4,
                          subTitleFactor: 0.2,
                        ),
                        CircleName(
                          name: "Dhanush",
                          radiusFactor: 0.1,
                          backgroundColor: Colors.blue,
                          fontColor: Colors.white,
                          titleFactor: 0.4,
                          subTitleFactor: 0.2,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 8,
                    child: Container(
                      //color: Colors.red.shade50,
                      width: double.maxFinite,
                      height: double.maxFinite,
                      alignment: Alignment.bottomRight,
                      padding: Pad(all: size.width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ...[
                            WelcomeName(),
                            Spacer(),
                          ],
                          ...List.from(
                            ["Play Single", "Play Multiplayer", "Settings"].map(
                              (e) => Flexible(
                                child: FadeInLeft(
                                  child: TextButton(
                                    onPressed: () {
                                      if (e.contains("Single")) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: FractionallySizedBox(
                                              heightFactor: 0.2,
                                              child: Container(),
                                            ),
                                          ),
                                        );
                                      }
                                      if (e.contains("Multiplayer")) {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                size.width,
                                              ),
                                              topRight: Radius.circular(
                                                size.width * 0.01,
                                              ),
                                            ),
                                          ),
                                          builder: (_) =>
                                              const CreateJoinRoom(),
                                        );
                                      }
                                    },
                                    child: Text(
                                      e,
                                      style: GoogleFonts.poppins(
                                        fontSize: size.width * 0.07,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...[
                            const Spacer(),
                            Flexible(
                              child: FadeInLeft(
                                child: TextButton(
                                  onPressed: () => ref.watch(signOutProvider),
                                  child: Text(
                                    "Logout",
                                    style:
                                        TextStyle(fontSize: size.width * 0.05),
                                  ),
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WelcomeName extends ConsumerWidget {
  const WelcomeName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final GameUser? user = ref.watch(gameUserProvider).value;
    return Flexible(
      child: user == null
          ? Container()
          : Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: "Welcome ",
                  children: [
                    TextSpan(
                      text: camelCase(user.name),
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.left,
              ),
            ),
    );
  }
}

String camelCase(String value) => toBeginningOfSentenceCase(value) ?? "";

class CreateJoinRoom extends ConsumerWidget {
  const CreateJoinRoom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return FractionallySizedBox(
      heightFactor: 0.15,
      child: ButtonBarSuper(
        children: List.from(
          ["CREATE GAME", "JOIN GAME"].map(
            (e) => TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (e.contains("CREATE")) {
                  /*ref.watch(createRoomProvider).whenData((value) {
                    print("290--$value");
                    ref.watch(idNotifierProvider.notifier).state = value;
                    context.router.push(GameRoomRoute(isCreator: true));
                    ref.watch(joinRoomProvider);
                  });*/
                  ref.watch(createRoomProvider.future).then(
                    (value) {
                      ref.watch(idNotifierProvider.notifier).state = value;
                      context.router.push(GameRoomRoute(isCreator: true));
                    },
                  ).whenComplete(
                    () => ref.watch(joinRoomProvider),
                  );
                } else {}
              },
              child: Text(
                e,
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        alignment: WrapSuperAlignment.right,
        wrapFit: WrapFit.min,
      ),
    );
  }
}

/*Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 2,
                    child: RichText(
                      text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Want to start your investigation?\n",
                              style: TextStyle(color: Colors.black87),
                            ),
                            /*const TextSpan(
                              text: "Start now  \t\t",
                              style: TextStyle(color: Colors.grey),
                            ),*/
                            WidgetSpan(
                              child: SizedBox(
                                width: size.width * 0.5,
                                height: size.height * 0.075,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      ref.watch(createRoomProvider.future).then(
                                    (value) {
                                      ref
                                          .read(idNotifierProvider.notifier)
                                          .state = value;
                                      context.router
                                          .push(GameRoomRoute(isCreator: true));
                                    },
                                  ).whenComplete(
                                    () => ref.watch(joinRoomProvider),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.brown),
                                  ),
                                  child: AutoSizeText(
                                    "Create Game",
                                    style:
                                        TextStyle(fontSize: size.width * 0.05),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            )
                          ],
                          style:
                              GoogleFonts.poppins(fontSize: size.width * 0.05)),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            "or join your friend's case",
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Flexible(
                          flex: 4,
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
                            onCompleted: (code) => ref
                                .read(validateCodeProvider(code).future)
                                .then(
                              (_id) {
                                ref.read(idNotifierProvider.notifier).state =
                                    _id;
                                context.router
                                    .push(GameRoomRoute(isCreator: false));
                              },
                            ).whenComplete(() => ref.read(joinRoomProvider)),
                            showCursor: false,
                            textStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: size.height * 0.05,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )*/

/*ElevatedButton(
                                  onPressed: () {
                                    /* final r = AutoRouterDelegate.of(context);
                                    r.controller
                                        .navigate(const GameRoomRoute());*/
                                    //context.router.push(GameRoomRoute());
                                    // context.navigateTo(
                                    //   const GameRoomRoute(),
                                    //   onFailure: (failure) {
                                    //     print(failure.toString());
                                    //   },
                                    // );
                                    AutoRouter.of(context)
                                        .push(const GameRoomRoute());
                                  } /*context.router.push(
                                      const GameRoomRoute())*/ /*{
                                    ref.watch(createRoomProvider.future).then(
                                      (_id) {
                                        ref
                                            .read(idNotifierProvider.notifier)
                                            .state = _id;
                                        context.router.push(GameRoomRoute());
                                      },
                                    ).whenComplete(
                                        () => ref.watch(joinRoomProvider));
                                  }*/
                                  ,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.brown),
                                  ),
                                  child: AutoSizeText(
                                    "Create Game",
                                    style:
                                        TextStyle(fontSize: size.width * 0.05),
                                    maxLines: 1,
                                  ),
                                )*/
