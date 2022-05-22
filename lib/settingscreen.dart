import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hex_color/flutter_hex_color.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:op_chess_app/chesswithoutswap.dart';
import 'package:op_chess_app/chesswithswap.dart';
import 'package:op_chess_app/customwidgets/constants.dart';
import 'package:op_chess_app/customwidgets/iconbuttonsimple.dart';
import 'package:op_chess_app/customwidgets/text.dart';
import 'package:op_chess_app/customwidgets/textbutton.dart';
import 'package:op_chess_app/historyhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customwidgets/flatbuttonsimple.dart';
//import 'package:horizontal_data_table/horizontal_data_table.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double h = 0.0, w = 0.0;
  double kh = 1 / 759.2727272727273;
  double kw = 1 / 392.72727272727275;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController user1namecontroller = TextEditingController();
  TextEditingController user2namecontroller = TextEditingController();
  String user1name = 'User 1';
  String user2name = 'User 2';
  final dbHelper = DatabaseHelper.instance;
  int user1wins = 0;
  int user2wins = 0;
  String currfirstcolor = '#FFFFFF';
  String currsecondcolor = '#000000';
  //final HDTRefreshController _hdtRefreshController = HDTRefreshController();
  List<MatchResult> historydata = [];
  Future<void> addStringToSF(int user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user == 1) {
      prefs.setString('user1', user1namecontroller.text);
    }
    if (user == 2) {
      prefs.setString('user2', user2namecontroller.text);
    }
  }

  Future<void> getStringValuesSF(int user) async {
    //get user name
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = 'User';
    if (prefs.containsKey('user1') && user == 1) {
      setState(() {
        user1name = prefs.getString('user1')!;
        user1namecontroller.text = user1name;
      });
    }
    if (prefs.containsKey('user2') && user == 2) {
      setState(() {
        user2name = prefs.getString('user2')!;
        user2namecontroller.text = user2name;
      });
    }
  }

  Future<void> addcolorToSF(int user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user == 1) {
      //white pawn
      prefs.setString('whitepawncolor', currfirstcolor);
    }
    if (user == 2) {
      prefs.setString('blackpawncolor', currsecondcolor);
    }
  }

  Future<void> getcolorValuesSF(int user) async {
    //get user name
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = '';
    if (prefs.containsKey('whitepawncolor') && user == 1) {
      setState(() {
        currfirstcolor = prefs.getString('whitepawncolor')!;
      });
    }
    if (prefs.containsKey('blackpawncolor') && user == 2) {
      setState(() {
        currsecondcolor = prefs.getString('blackpawncolor')!;
      });
    }
  }

  Future<List<MatchResult>> _query() async {
    final allRows = await dbHelper.queryAllRows();
    // print(allRows);
    historydata = [];
    allRows.isNotEmpty
        ? allRows.forEach((row) {
            setState(() {
              historydata.add(MatchResult(
                DateTime.fromMillisecondsSinceEpoch(row['date']),
                int.parse(row['moves'].toString()),
                int.parse(row['time'].toString()),
                int.parse(row['winner'].toString()),
              ));
            });
          })
        : [];
    wins();

    return historydata;
  }

  void wins() {
    if (historydata.isNotEmpty) {
      user1wins = 0;
      user2wins = 0;
      for (int i = 0; i < historydata.length; i++) {
        if (historydata[i].winner == 1) {
          setState(() {
            user1wins += 1;
          });
        }
        if (historydata[i].winner == -1) {
          setState(() {
            user2wins += 1;
          });
        }
      }
    }
  }

  void pickcolor(BuildContext context, bool top) {
    String hexcode = '';
    if (top == true) {
      //White Color change request
      hexcode = currfirstcolor;
    } else {
      hexcode = currsecondcolor;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextPlain('Pick a Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
              pickerColor: HexColor(hexcode),
              enableAlpha: false,
              showLabel: false,
              onColorChanged: (color) {
                setState(() {
                  hexcode = '#${color.value.toRadixString(16)}';
                  if (top == true) {
                    //white color pawn to be changed
                    setState(() {
                      currfirstcolor = '#${color.value.toRadixString(16)}';
                    });
                    addcolorToSF(1);
                  } else {
                    setState(() {
                      currsecondcolor = '#${color.value.toRadixString(16)}';
                    });
                    addcolorToSF(2);
                  }

                  hexcode = '#${color.value.toRadixString(16)}';
                  setState(() {});

                  //print('HAHHAHA' + currfirstcolor);
                });

                // print(hexcode);
              }),
        ),
        actions: [
          TextButtonSimple(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: TextPlain('Confirm'),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getStringValuesSF(1);
    getStringValuesSF(2);
    getcolorValuesSF(1);
    getcolorValuesSF(2);
    _query();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;
    return Scaffold(
      //backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: TextPlain(
          'Settings',
        ),
        actions: [
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              // icon: Icon(Icons.book)
              itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: TextPlain("Change White Pawn Color"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: TextPlain("Change Black Pawn Color"),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: TextPlain("Reset Colors"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              pickcolor(context, true);
            } else if (value == 1) {
              pickcolor(context, false);
            } else if (value == 2) {
              setState(() {
                currfirstcolor = '#FFFFFF';
                currsecondcolor = '#000000';
                addcolorToSF(1);
                addcolorToSF(2);
              });
            }
          }),
        ],
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/chessbackground.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Padding(
          padding: EdgeInsets.all(Constants.padding),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: h * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    username(1, currfirstcolor, user1wins, Colors.white),
                    SizedBox(
                      width: w * 0.01,
                    ),
                    username(2, currsecondcolor, user2wins, Colors.white)
                  ],
                ),
                SizedBox(
                  height: h * 0.05,
                ),
                historylist(historydata)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget username(int user, String backgroundcolor, int wins, Color textcolor) {
    // print(currfirstcolor);

    if (backgroundcolor == '#FFFFFF') {
      textcolor = Colors.black;
    }
    return Container(
      height: 130*kh*h,
      width: 75.0*kw*w + (user == 1 ? user1name.length * 11*kw*w : user2name.length * 11*kw*w),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: HexColor(backgroundcolor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 30*kh*h,
            color: textcolor,
          ),

          //SizedBox(width: 20),
          Row(
            children: [
              TextPlain(user == 1 ? user1name : user2name,
                  fontWeight: FontWeight.w600, fontSize: 24*kh*h, color: textcolor),
              IconButtonSimple(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return StatefulBuilder(builder: (context, setState) {
                            // if (user == 1) {
                            //   user1name = '';
                            // } else {
                            //   user2name = '';
                            // }

                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10*kh*h))),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextPlain(user == 1
                                      ? "User Name(White)"
                                      : "User Name(Black)"),
                                  //  TextPlain(user == 1 ? user1name : user2name),
                                ],
                              ),
                              content: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: user == 1
                                      ? user1namecontroller
                                      : user2namecontroller,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    setState() {
                                      if (user == 1) {
                                        user1name = val;
                                      } else {
                                        user2name = val;
                                      }
                                      ;
                                    }
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                FlatButtonSimple(
                                  onPressed: () async {
                                    await getStringValuesSF(user);
                                    Navigator.of(ctx)
                                        .pop(user == 1 ? user1name : user2name);
                                  },
                                  child: TextPlain("CANCEL"),
                                ),
                                FlatButtonSimple(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await addStringToSF(user);
                                      Navigator.of(ctx).pop(user == 1
                                          ? user1namecontroller.text
                                          : user2namecontroller.text);
                                    }
                                  },
                                  child: TextPlain("SAVE"),
                                ),
                              ],
                            );
                          });
                        }).then((value) {
                      setState(() {
                        if (user == 1) {
                          user1name = value;
                        } else {
                          user2name = value;
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.edit, size: 30*kh*h, color: textcolor)),
            ],
          ),

          Row(
            children: [
              TextPlain('Wins: ' + wins.toString(),
                  fontSize: 18*kh*h, color: textcolor),
            ],
          )
        ],
      ),
    );
  }

  String winnername(int i) {
    String winner = '';
    if (i.toString() == '0') {
      winner = 'Draw';
    } else if (i.toString() == '1') {
      winner = user1name;
    } else {
      winner = user2name;
    }
    return winner;
  }

  Widget historylist(List<MatchResult> l) {
    return FutureBuilder<List<MatchResult>>(
        future: _query(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return bodyData(data);
          } else {
            return Center();
          }
        });
  }

  Widget bodyData(List<MatchResult> names) {
    return Expanded(
      child: Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(

              //columnSpacing: 25,
              columns: <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextPlain(
                          "Date",
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  numeric: true,
                  tooltip: "Date of match played",
                ),
                DataColumn(
                  label: TextPlain("Time"),
                  numeric: true,
                  tooltip: "Time taken by winner(in seconds)",
                ),
                DataColumn(
                  label: TextPlain("Moves"),
                  numeric: true,
                  tooltip: "Number of moves taken to win the game",
                ),
                DataColumn(
                  label: TextPlain("Winner"),
                  numeric: false,
                  tooltip: "Winner of the match",
                ),
              ],
              rows: names
                  .map(
                    (name) => DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 60*kw*w,
                            child: TextPlain(formattedate(name.date),
                                color: Colors.black, fontSize: 17*kh*h),
                          ),
                          showEditIcon: false,
                          placeholder: false,
                        ),
                        DataCell(
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextPlain(
                                  name.time.toString(),
                                  color: Colors.black,
                                  fontSize: 17*kh*h,
                                  textAlign: TextAlign.start,
                                ),
                              ]),
                          showEditIcon: false,
                          placeholder: false,
                        ),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextPlain(name.moves.toString(),
                                  color: Colors.black, fontSize: 17*kh*h),
                            ],
                          ),
                          showEditIcon: false,
                          placeholder: false,
                        ),
                        DataCell(
                          Container(
                            width: 60*kw*w,
                            child: TextPlain(winnername(name.winner),
                                color: Colors.black, fontSize: 17*kh*h),
                          ),
                          showEditIcon: false,
                          placeholder: false,
                        )
                      ],
                    ),
                  )
                  .toList()),
        ),
      ),
    );
  }

  String formattedate(DateTime date) {
    //returns a formatted date from date time to date+month(Ex 27 Jan)
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    String num = date.day.toString();
    String month = months[date.month - 1].substring(0, 3);
    String num_month = num + '  ' + month + '    ';
    String time = date.hour.toString() + ":" + date.minute.toString();
    return num_month;
  }
}

class MatchResult {
  DateTime date;
  int time;
  int moves;
  int winner;
  MatchResult(this.date, this.moves, this.time, this.winner);
}
