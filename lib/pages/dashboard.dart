import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:traccia/provider/game_id.dart';
import 'package:traccia/provider/room.dart';
import 'package:traccia/route/my_router.gr.dart';

import 'widgets/dashboard_drawer.dart';

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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        drawer: const Drawer(
          child: DashboardDrawer(),
          backgroundColor: Colors.white,
        ),
        body: const DashboardState(),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
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
    }
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
            opacity: 0.25,
          ),
        ),
        child: Column(
          children: [
            Flexible(
              flex: 3,
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
                  "SOLVE CRIME, MEAN TIME",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.wallpoet(fontSize: size.width * 0.05),
                  maxLines: 1,
                ),
              ),
            ),
            Flexible(
              flex: 7,
              child: Column(
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
              ),
            )
          ],
        ),
      ),
    );
  }
}

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
