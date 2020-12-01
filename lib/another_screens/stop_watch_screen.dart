import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopWatchScreen extends StatefulWidget {
  final double changeFontSize;
  StopWatchScreen({this.changeFontSize});
  @override
  _StopWatchScreenState createState() => _StopWatchScreenState();
}

class _StopWatchScreenState extends State<StopWatchScreen> {
  final _isHours = true;
  bool startButtonSelected = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) =>
        print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    _stopWatchTimer.records.listen((value) => print('records $value'));

    /// Can be set preset time. This case is "00:01.23".
    // _stopWatchTimer.setPresetTime(mSec: 1234);
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: height * 0.15,
                    ),
                    Text(
                      'Lap List',
                      style: TextStyle(
                          color: Theme.of(context).shadowColor,
                          fontSize: height * 0.048),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Theme.of(context).shadowColor)),
                      width: width * 0.25,
                      height: height * 0.7,
                      margin: const EdgeInsets.all(8),
                      child: StreamBuilder<List<StopWatchRecord>>(
                        stream: _stopWatchTimer.records,
                        initialData: _stopWatchTimer.records.value,
                        builder: (context, snap) {
                          final value = snap.data;
                          if (value.isEmpty) {
                            return Container();
                          }
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut);
                          });
                          print('Listen records. $value');
                          return ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              final data = value[index];
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${index + 1} ${data.displayTime}',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  )
                                ],
                              );
                            },
                            itemCount: value.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  width: width * 0.7,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData: _stopWatchTimer.rawTime.value,
                      builder: (context, snap) {
                        final value = snap.data;
                        final displayTime = StopWatchTimer.getDisplayTime(value,
                            hours: false, milliSecond: true);

                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: height * 0.08,
                            ),
                            Container(
                              height: height * 0.7,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(displayTime,
                                      style: TextStyle(
                                          fontSize:
                                              widget.changeFontSize * 0.6)),
                                ),
                              ),
                            ),
                            Container(
                              width: width * 1,
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  child: RaisedButton(
                                                    elevation: 0.0,
                                                    color: startButtonSelected
                                                        ? Theme.of(context)
                                                            .buttonColor
                                                        : Colors.red,
                                                    shape:
                                                        const StadiumBorder(),
                                                    onPressed: () {
                                                      if (startButtonSelected) {
                                                        _stopWatchTimer
                                                            .onExecute
                                                            .add(
                                                                StopWatchExecute
                                                                    .start);
                                                      } else {
                                                        _stopWatchTimer
                                                            .onExecute
                                                            .add(
                                                                StopWatchExecute
                                                                    .stop);
                                                      }
                                                      setState(() {
                                                        startButtonSelected =
                                                            !startButtonSelected;
                                                      });
                                                    },
                                                    child: Text(
                                                        startButtonSelected
                                                            ? 'Start'
                                                            : 'Stop',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .shadowColor,
                                                            fontSize: height *
                                                                0.048)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.01,
                                                ),
                                                Container(
                                                  child: RaisedButton(
                                                    elevation: 0.0,
                                                    color: startButtonSelected
                                                        ? Colors.pink
                                                        : Colors.blue,
                                                    shape:
                                                        const StadiumBorder(),
                                                    onPressed: () async {
                                                      if (startButtonSelected) {
                                                        _stopWatchTimer
                                                            .onExecute
                                                            .add(
                                                                StopWatchExecute
                                                                    .reset);
                                                      } else {
                                                        _stopWatchTimer
                                                            .onExecute
                                                            .add(
                                                                StopWatchExecute
                                                                    .lap);
                                                      }
                                                    },
                                                    child: Text(
                                                        startButtonSelected
                                                            ? 'Reset'
                                                            : 'Lap',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .shadowColor,
                                                            fontSize: height *
                                                                0.048)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Container(
            //   width: width * 1,
            //   height: height * 0.8,
            //   child: Row(
            //     children: <Widget>[
            //       Container(
            //         width: width * 0.3,
            //       ),
            //       Container(
            //         width: width * 0.7,
            //         child: Column(
            //           children: <Widget>[
            //             Padding(
            //               padding: EdgeInsets.only(top: height * 0.15),
            //               child: StreamBuilder<int>(
            //                 stream: _stopWatchTimer.rawTime,
            //                 initialData: _stopWatchTimer.rawTime.value,
            //                 builder: (context, snap) {
            //                   final value = snap.data;
            //                   final displayTime = StopWatchTimer.getDisplayTime(
            //                     value,
            //                     hours: false,
            //                   );
            //                   return Padding(
            //                     padding: EdgeInsets.all(8),
            //                     child: Text(
            //                       displayTime,
            //                       style: TextStyle(
            //                         fontSize: widget.changeFontSize * 0.7,
            //                         fontWeight: FontWeight.w600,
            //                       ),
            //                     ),
            //                   );
            //                 },
            //               ),
            //             ),
            //             // 분, 초 기록
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 /// Display every minute.

            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: 0),
            //                   child: StreamBuilder<int>(
            //                     stream: _stopWatchTimer.minuteTime,
            //                     initialData: _stopWatchTimer.minuteTime.value,
            //                     builder: (context, snap) {
            //                       final value = snap.data;
            //                       print('Listen every minute. $value');
            //                       return Column(
            //                         children: <Widget>[
            //                           Padding(
            //                               padding: EdgeInsets.all(8),
            //                               child: Row(
            //                                 mainAxisAlignment:
            //                                     MainAxisAlignment.center,
            //                                 crossAxisAlignment:
            //                                     CrossAxisAlignment.center,
            //                                 children: <Widget>[
            //                                   Padding(
            //                                     padding: EdgeInsets.symmetric(
            //                                         horizontal: 4),
            //                                     child: Text(
            //                                       'minute',
            //                                       style: TextStyle(
            //                                         fontSize:
            //                                             widget.changeFontSize *
            //                                                 0.1,
            //                                         fontFamily: 'Helvetica',
            //                                       ),
            //                                     ),
            //                                   ),
            //                                   Padding(
            //                                     padding: EdgeInsets.symmetric(
            //                                         horizontal: 4),
            //                                     child: Text(
            //                                       value.toString(),
            //                                       style: TextStyle(
            //                                           fontSize: widget
            //                                                   .changeFontSize *
            //                                               0.18,
            //                                           fontFamily: 'Helvetica',
            //                                           fontWeight:
            //                                               FontWeight.bold),
            //                                     ),
            //                                   ),
            //                                 ],
            //                               )),
            //                         ],
            //                       );
            //                     },
            //                   ),
            //                 ),

            //                 /// Display every second.

            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: 0),
            //                   child: StreamBuilder<int>(
            //                     stream: _stopWatchTimer.secondTime,
            //                     initialData: _stopWatchTimer.secondTime.value,
            //                     builder: (context, snap) {
            //                       final value = snap.data;
            //                       print('Listen every second. $value');
            //                       return Column(
            //                         children: <Widget>[
            //                           Padding(
            //                               padding: EdgeInsets.all(8),
            //                               child: Row(
            //                                 mainAxisAlignment:
            //                                     MainAxisAlignment.center,
            //                                 crossAxisAlignment:
            //                                     CrossAxisAlignment.center,
            //                                 children: <Widget>[
            //                                   Padding(
            //                                     padding: EdgeInsets.symmetric(
            //                                         horizontal: 4),
            //                                     child: Text(
            //                                       'second',
            //                                       style: TextStyle(
            //                                         fontSize:
            //                                             widget.changeFontSize *
            //                                                 0.1,
            //                                         fontFamily: 'Helvetica',
            //                                       ),
            //                                     ),
            //                                   ),
            //                                   Padding(
            //                                     padding: EdgeInsets.symmetric(
            //                                         horizontal: 4),
            //                                     child: Text(
            //                                       value.toString(),
            //                                       style: TextStyle(
            //                                           fontSize: widget
            //                                                   .changeFontSize *
            //                                               0.18,
            //                                           fontFamily: 'Helvetica',
            //                                           fontWeight:
            //                                               FontWeight.bold),
            //                                     ),
            //                                   ),
            //                                 ],
            //                               )),
            //                         ],
            //                       );
            //                     },
            //                   ),
            //                 ),
            //               ],
            //             )
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
