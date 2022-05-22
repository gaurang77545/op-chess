import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:op_chess_app/customwidgets/constants.dart';
import 'package:op_chess_app/customwidgets/text.dart';
import 'package:op_chess_app/customwidgets/textbutton.dart';
import 'package:op_chess_app/menuscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_hex_color/flutter_hex_color.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'customwidgets/iconbuttonsimple.dart';
import 'historyhelper.dart';

class ChessWithoutSwap extends StatefulWidget {
  String currfirstcolor;
  String currsecondcolor;
  ChessWithoutSwap(this.currfirstcolor, this.currsecondcolor);

  @override
  _ChessWithoutSwapState createState() => _ChessWithoutSwapState();
}

class _ChessWithoutSwapState extends State<ChessWithoutSwap> {
  ChessBoardController controller = ChessBoardController();
  final StopWatchTimer _stopWatchTimerfirst =
      StopWatchTimer(); //first here represents first player to move initially
  //and it keeps on getting replaced with second timer to display time in a correct and more readable format
  final StopWatchTimer _stopWatchTimersecond = StopWatchTimer();
  String currtimefirst = '';
  String currtimesecond = '';
  double h = 0.0, w = 0.0;
  double kh = 1 / 759.2727272727273;
  double kw = 1 / 392.72727272727275;
  PlayerColor orientation = PlayerColor.white;
  List<BoardColor> colors = [
    BoardColor.brown,
    BoardColor.darkBrown,
    BoardColor.green,
    BoardColor.orange,
  ];
  BoardColor currcolor = BoardColor.orange;
  String currfirstcolor = '#FFFFFF';
  String currsecondcolor = '#000000';
  String hexcolor = '#FFFFFF';
  int count = 0; //for bottom builder which shows moves played
  int countmoves = 0;
  final dbHelper = DatabaseHelper.instance;
  String user1name = 'User 1';
  String user2name = 'User 2';
  @override
  void initState() {
    _stopWatchTimerfirst.onExecute.add(StopWatchExecute.start);
    getStringValuesSF(1);
    getStringValuesSF(2);
    currfirstcolor = widget.currfirstcolor;
    currsecondcolor = widget.currsecondcolor;
    controller.addListener(() {
      controller.undoMove();
    });
    super.initState();
  }

  void _insert(DateTime dt, int moves, DateTime time, int winner) async {
    //insert into backend
    // row to insert
    //winner=1 => Player 1 won
    //winner==0=>Draw
    //winner==-1=>Player 2 won
    int totseconds = (time.millisecond > 50) ? 1 : 0;
    totseconds += time.hour * 60 * 60 + time.minute * 60 + time.second;

    //print(totseconds);
    Map<String, dynamic> row = {
      DatabaseHelper.columnDate: dt.millisecondsSinceEpoch,
      DatabaseHelper.columnMoves: moves,
      DatabaseHelper.columnTime: totseconds,
      DatabaseHelper.columnWinner: winner
    };

    final id = await dbHelper.insert(row);
    //print(row);
    print('inserted row id: $id');
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(() {});
    _stopWatchTimerfirst.dispose();
    _stopWatchTimersecond.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: TextPlain('Chess Demo'),
        actions: [
          IconButtonSimple(
            icon: Icon(Icons.restore_outlined),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: TextPlain("Reset"),
                    content: TextPlain(
                        "This would reset complete progress of the match.Are you sure?"),
                    actions: [
                      TextButtonSimple(
                        child: TextPlain("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButtonSimple(
                        child: TextPlain("Continue"),
                        onPressed: () {
                          controller.resetBoard();

                          _stopWatchTimerfirst.onExecute
                              .add(StopWatchExecute.reset);
                          _stopWatchTimersecond.onExecute
                              .add(StopWatchExecute.reset);
                          _stopWatchTimerfirst.onExecute
                              .add(StopWatchExecute.start);
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.padding),
        child: ListView(
          children: [
            StreamBuilder<int>(
              stream: _stopWatchTimersecond.rawTime,
              initialData: _stopWatchTimersecond.rawTime.value,
              builder: (context, snapshotouter) {
                final value = snapshotouter.data;

                currtimesecond = StopWatchTimer.getDisplayTime(
                  value!,
                  hours: true,
                  // minute: false,
                  // milliSecond: false,
                  // second: true
                );

                return StreamBuilder<int>(
                  stream: _stopWatchTimerfirst.rawTime,
                  initialData: _stopWatchTimerfirst.rawTime.value,
                  builder: (context, snapshotinner) {
                    final value = snapshotinner.data;

                    currtimefirst = StopWatchTimer.getDisplayTime(
                      value!,
                      hours: true,
                      // minute: false,
                      // milliSecond: false,
                      // second: true
                    );

                    // replace(currtimefirst, currtimesecond);
                    return Column(
                      children: [
                        SizedBox(
                          height: h * 0.1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextPlain(user2name,
                                fontSize: 20*kh*h,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                            TextPlain(currtimesecond,
                                fontSize: 20*kh*h,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ],
                        ),
                        Center(
                          child: ChessBoard(
                            controller: controller,
                            whitepieceColor: currfirstcolor,
                            blackpieceColor: currsecondcolor,
                            boardColor: currcolor,
                            arrows: [
                              // BoardArrow(
                              //   from: 'd2',
                              //   to: 'd4',
                              //   //color: Colors.red.withOpacity(0.5),
                              // ),
                              // BoardArrow(
                              //   from: 'e7',
                              //   to: 'e5',
                              //   color: Colors.red.withOpacity(0.7),
                              // ),
                            ],
                            boardOrientation: orientation,
                            size: 300,
                            onMove: () {
                              countmoves++;
                              if (controller.isCheckMate()) {
                                _stopWatchTimerfirst.onExecute
                                    .add(StopWatchExecute.stop);
                                _stopWatchTimersecond.onExecute
                                    .add(StopWatchExecute.stop);
                                int winner = 0;
                                if (countmoves % 2 == 0) {
                                  //black won
                                  winner = -1;
                                } else {
                                  winner = 1;
                                }
                                print(winner);
                                DateTime time = DateFormat("hh:mm:ss.SSS")
                                    .parse(winner == 1
                                        ? currtimefirst
                                        : currtimesecond);

                                //print(DateFormat.Hms().format(time));
                                _insert(
                                    DateTime.now(), countmoves, time, winner);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: TextPlain("CONGRATULATIONS"),
                                      content: TextPlain(winner == 1
                                          ? user1name.toUpperCase()
                                          : user2name.toUpperCase() +
                                              " WON THE MATCH"),
                                      actions: [
                                        TextButtonSimple(
                                          child: TextPlain("PLAY AGAIN ??"),
                                          onPressed: () {
                                            controller.resetBoard();
                                            if (orientation ==
                                                PlayerColor.black) {
                                              orientation = PlayerColor.white;
                                            }
                                            _stopWatchTimerfirst.onExecute
                                                .add(StopWatchExecute.reset);
                                            _stopWatchTimersecond.onExecute
                                                .add(StopWatchExecute.reset);
                                            _stopWatchTimerfirst.onExecute
                                                .add(StopWatchExecute.start);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButtonSimple(
                                          child: TextPlain("Back to Menu"),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MenuScreen()));
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              } else if (controller.isDraw() ||
                                  controller.isStaleMate() ||
                                  controller.isThreefoldRepetition() ||
                                  controller.isInsufficientMaterial()) {
                                _stopWatchTimerfirst.onExecute
                                    .add(StopWatchExecute.stop);
                                _stopWatchTimersecond.onExecute
                                    .add(StopWatchExecute.stop);
                                int winner = 0;

                                print(winner);
                                DateTime time = DateFormat("hh:mm:ss.SSS")
                                    .parse(winner == 1
                                        ? currtimefirst
                                        : currtimesecond);

                                //print(DateFormat.Hms().format(time));
                                _insert(
                                    DateTime.now(), countmoves, time, winner);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: TextPlain("DRAW"),
                                      content: TextPlain("Match is Drawed"),
                                      actions: [
                                        TextButtonSimple(
                                          child: TextPlain("PLAY AGAIN ??"),
                                          onPressed: () {
                                            controller.resetBoard();
                                            if (orientation ==
                                                PlayerColor.black) {
                                              orientation = PlayerColor.white;
                                            }
                                            _stopWatchTimerfirst.onExecute
                                                .add(StopWatchExecute.reset);
                                            _stopWatchTimersecond.onExecute
                                                .add(StopWatchExecute.reset);
                                            _stopWatchTimerfirst.onExecute
                                                .add(StopWatchExecute.start);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButtonSimple(
                                          child: TextPlain("Back to Menu"),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MenuScreen()));
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  if (countmoves % 2 == 1) {
                                    //black chance to move
                                    _stopWatchTimerfirst.onExecute
                                        .add(StopWatchExecute.stop);
                                    _stopWatchTimersecond.onExecute
                                        .add(StopWatchExecute.start);
                                  } else {
                                    _stopWatchTimersecond.onExecute
                                        .add(StopWatchExecute.stop);
                                    _stopWatchTimerfirst.onExecute
                                        .add(StopWatchExecute.start);
                                    orientation = PlayerColor.white;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: h * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextPlain(user1name,
                                fontSize: 20*kh*h,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                            TextPlain(currtimefirst,
                                fontSize: 20*kh*h,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                            // IconButtonSimple(
                            //     onPressed: () {
                            //       pickcolor(context, false);
                            //     },
                            //     icon: Icon(Icons.color_lens_outlined))
                          ],
                        ),
                        SizedBox(
                          height: h * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            choosecolor(BoardColor.orange, '#CC723A'),
                            choosecolor(BoardColor.brown, '#B58763'),
                            choosecolor(BoardColor.darkBrown, '#7E6C62'),
                            choosecolor(BoardColor.green, '#00A6AC')
                          ],
                        )
                      ],
                    );
                  },
                );
              },
            ),
            Container(
              height: 30*kh*h + count * 12*kh*h,
              child: ValueListenableBuilder<Chess>(
                valueListenable: controller,
                builder: (context, game, _) {
                  count++;
                  return TextPlain(
                    controller.getSan().fold(
                          '',
                          (previousValue, element) =>
                              previousValue + '\n' + (element ?? ''),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getStringValuesSF(int user) async {
    //get user name
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = 'User';
    if (prefs.containsKey('user1') && user == 1) {
      setState(() {
        user1name = prefs.getString('user1')!;
      });
    }
    if (prefs.containsKey('user2') && user == 2) {
      setState(() {
        user2name = prefs.getString('user2')!;
      });
    }
  }

  Widget choosecolor(BoardColor color, String hexcode) {
    return InkWell(
      child: Row(
        children: [
          Container(
            height: 30*kh*h,
            width: 30*kw*w,
            decoration: BoxDecoration(
              color: HexColor(hexcode),
              border: currcolor == color
                  ? Border.all(color: Colors.black, width: 3*kw*w)
                  : null,
            ),
          ),
          SizedBox(
            width: w * 0.01,
          )
        ],
      ),
      onTap: () {
        setState(() {
          currcolor = color;
        });
      },
    );
  }
}
