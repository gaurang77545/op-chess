import 'package:op_chess_app/chesswithoutswap.dart';
import 'package:op_chess_app/chesswithswap.dart';
import 'package:op_chess_app/menuscreen.dart';
import 'package:op_chess_app/settingscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'customwidgets/iconbuttonsimple.dart';

//flutter downgrade 2.10.3
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  final pages = [
    //ChessWithoutSwap(),
    MenuScreen(),
    // ChessWithoutSwap('#FFFFFF', '#000000'),
    SettingsScreen(),

    //SettingsScreen(),

    //ChessWithoutSwap(),
    //  SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButtonSimple(
            //   enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 0;
              });
            },
            icon: pageIndex == 0
                ? const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButtonSimple(
            // enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon: pageIndex == 1
                ? const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
        ],
      ),
    );
  }
}
