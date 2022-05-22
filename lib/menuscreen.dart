import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:op_chess_app/chesswithoutswap.dart';
import 'package:op_chess_app/chesswithswap.dart';
import 'package:op_chess_app/customwidgets/constants.dart';
import 'package:op_chess_app/customwidgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String currfirstcolor = '#FFFFFF';
  String currsecondcolor = '#000000';
  double h = 0.0, w = 0.0;
  double kh = 1 / 759.2727272727273;
  double kw = 1 / 392.72727272727275;
  Future<void> getcolorValuesSF() async {
    //get color
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = '';
    if (prefs.containsKey('whitepawncolor')) {
      setState(() {
        currfirstcolor = prefs.getString('whitepawncolor')!;
      });
    }
    if (prefs.containsKey('blackpawncolor')) {
      setState(() {
        currsecondcolor = prefs.getString('blackpawncolor')!;
      });
    }
  }

  @override
  void initState() {
    getcolorValuesSF();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: TextPlain(
            'Chess',
          )),
      body: Padding(
        padding: EdgeInsets.all(Constants.padding),
        child: FutureBuilder(
            future: getcolorValuesSF(),
            builder: (_, data) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/chessbackground.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // FaIcon(
                      //   FontAwesomeIcons.solidChessKnight,
                      //   size: 90,
                      // ),
                      // SizedBox(
                      //   height: 50,
                      // ),
                      Container(
                        color: Colors.brown.shade300,
                        height: 50*kh*h,
                        width: 250*kw*w,
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.person, color: Colors.white),
                          label: TextPlain(
                            'Single Player',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50*kh*h,
                      ),
                      Container(
                        color: Colors.brown.shade300,
                        height: 50*kh*h,
                        width: 250*kw*w,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChessWithSwap(
                                        currfirstcolor, currsecondcolor)));
                          },
                          icon: Row(
                            children: [
                              Icon(Icons.person, color: Colors.white),
                              Icon(Icons.person, color: Colors.white),
                            ],
                          ),
                          label: TextPlain(
                            'MultiPlayer(with swap)',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50*kh*h,
                      ),
                      Container(
                        color: Colors.brown.shade400,
                        height: 50*kh*h,
                        width: 250*kw*w,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChessWithoutSwap(
                                        currfirstcolor, currsecondcolor)));
                          },
                          icon: Row(
                            children: [
                              Icon(Icons.person, color: Colors.white),
                              Icon(Icons.person, color: Colors.white),
                            ],
                          ),
                          label: TextPlain(
                            'MultiPlayer(without swap)',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
