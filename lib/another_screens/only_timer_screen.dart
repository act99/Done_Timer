import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:vibration/vibration.dart';

class OnlyTimerScreen extends StatefulWidget {
  final double changeFontSize;
  OnlyTimerScreen({this.changeFontSize});
  @override
  _OnlyTimerScreenState createState() => _OnlyTimerScreenState();
}

class _OnlyTimerScreenState extends State<OnlyTimerScreen> {
  CountDownController _controller = CountDownController();
  bool _isStart = false;
  bool _isPause = false;
  int _currentSecond = 1;
  int _currentMinute = 1;
  int _currentHour = 1;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return _isStart
        ? Scaffold(
            body: Center(
                child: CircularCountDownTimer(
              duration:
                  _currentSecond + _currentMinute * 60 + _currentHour * 3600,
              controller: _controller,
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 1.2,
              color: Colors.grey,
              fillColor: Colors.pink,
              backgroundColor: null,
              strokeWidth: height * 0.01,
              textStyle: TextStyle(
                  fontSize: widget.changeFontSize * 0.6,
                  color: Theme.of(context).shadowColor,
                  fontWeight: FontWeight.bold),
              isReverse: false,
              isReverseAnimation: false,
              isTimerTextShown: true,
              onComplete: () {
                Vibration.vibrate(duration: 1000);
                setState(() {
                  _isStart = false;
                });
                print('Countdown Ended');
              },
            )),
            floatingActionButton: _isPause
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                          elevation: 0.0,
                          onPressed: () {
                            setState(() {
                              _isPause = false;
                              _controller.restart();
                              _controller.pause();
                              _isStart = false;
                            });
                          },
                          icon: Icon(Icons.stop),
                          label: Text("Stop")),
                      FloatingActionButton.extended(
                          elevation: 0.0,
                          onPressed: () {
                            setState(() {
                              _isPause = false;
                              _controller.resume();
                            });
                          },
                          icon: Icon(Icons.play_arrow),
                          label: Text("Start")),
                    ],
                  )
                : FloatingActionButton.extended(
                    elevation: 0.0,
                    onPressed: () {
                      setState(() {
                        _isPause = true;
                        _controller.pause();
                      });
                    },
                    label: Text("Pause"),
                    icon: Icon(Icons.pause_sharp),
                  ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            width: width * 0.5,
            height: height * 1,
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: height * 0.15,
                    ),
                    Container(
                      height: height * 0.15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: width * 0.166,
                            child: Center(
                              child: Text(
                                'Hour',
                                style: TextStyle(
                                    color: Theme.of(context).shadowColor,
                                    fontSize: height * 0.048),
                              ),
                            ),
                          ),
                          Container(
                            width: width * 0.166,
                            child: Center(
                              child: Text(
                                'Minute',
                                style: TextStyle(
                                    color: Theme.of(context).shadowColor,
                                    fontSize: height * 0.048),
                              ),
                            ),
                          ),
                          Container(
                            width: width * 0.166,
                            child: Center(
                              child: Text(
                                'Second',
                                style: TextStyle(
                                    color: Theme.of(context).shadowColor,
                                    fontSize: height * 0.048),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: height * 0.4,
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: width * 0.05, left: width * 0.05),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10)),
                              height: height * 0.12,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              NumberPicker.integer(
                                  selectedTextStyle: TextStyle(
                                      color: Theme.of(context).shadowColor),
                                  textStyle: TextStyle(
                                      color: Theme.of(context).shadowColor),
                                  initialValue: _currentHour,
                                  minValue: 0,
                                  maxValue: 12,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _currentHour = newValue;
                                    });
                                  }),
                              NumberPicker.integer(
                                selectedTextStyle: TextStyle(
                                    color: Theme.of(context).shadowColor),
                                textStyle: TextStyle(
                                    color: Theme.of(context).shadowColor),
                                initialValue: _currentMinute,
                                minValue: 0,
                                maxValue: 60,
                                onChanged: (value) => setState(
                                  () => _currentMinute = value,
                                ),
                              ),
                              NumberPicker.integer(
                                selectedTextStyle: TextStyle(
                                    color: Theme.of(context).shadowColor),
                                textStyle: TextStyle(
                                    color: Theme.of(context).shadowColor),
                                initialValue: _currentSecond,
                                minValue: 0,
                                maxValue: 60,
                                onChanged: (value) => setState(
                                  () => _currentSecond = value,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    Container(
                      height: height * 0.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton(
                            child: Text(
                              "Start",
                              style: TextStyle(
                                  color: Theme.of(context).shadowColor,
                                  fontSize: width * 0.032),
                            ),
                            onPressed: () {
                              // createUserTimer(
                              //     _currentHour, _currentMinute, _currentSecond);

                              // setState(() {
                              //   _currentHour = 0;
                              //   _currentMinute = 0;
                              //   _currentSecond = 0;
                              // });
                              // Navigator.pop(context);
                              // Navigator.pop(context);
                              setState(() {
                                _isStart = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
