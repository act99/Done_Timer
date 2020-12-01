import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:timer/another_screens/datetime_screen.dart';
import 'package:timer/another_screens/only_timer_screen.dart';
import 'package:timer/another_screens/stop_watch_screen.dart';
import 'package:timer/model/db_helper.dart';
import 'package:timer/model/user_setting.dart';
import 'package:timer/widget/spinkitpourhourglass.dart';
import 'package:vibration/vibration.dart';

class TimerPage extends StatefulWidget {
  final UserSetting userSetting;
  TextStyle textTheme;
  TimerPage({this.textTheme, this.userSetting});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
// 탭 컨트롤
  TabController _controller;
  int _currentIndex = 0;
  int _prevControllerIndex = 0;
  List _keys = [];
  AnimationController _animationControllerOn;
  AnimationController _animationControllerOff;

  Animation _colorTweenBackgroundOn;
  Animation _colorTweenBackgroundOff;

  Animation _colorTweenForegroundOn;
  Animation _colorTweenForegroundOff;
  double _aniValue = 0.0;
  double _prevAniValue = 0.0;

  Color _foregroundOn = Colors.white;
  Color _foregroundOff = Colors.black;

  Color _backgroundOn = Colors.blue;
  Color _backgroundOff = Colors.grey[300];
  bool _buttonTap = false;

//-------------------------------

  List<UserSetting> userSettingList;
  double _changeFontSize = 96.0;
  ScrollController _scrollController = ScrollController();
  bool _changeVibration = false;
  int currentSecond = 0;
  int currentMinute = 0;
  int currentHour = 0;

  int settingHours = 1;
  int settingMinutes = 1;
  int settingSeconds = 1;

  NumberPicker hourPicker;
  NumberPicker minutePicker;
  NumberPicker secondPicker;

  bool startButtonSelected = true;
  String startButtonText = 'Start';
  DBHelper dbHelper = DBHelper();

  void addDefaultValueToSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setDouble('fontsize', _changeFontSize);
  }

  Future<double> getFontSize() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getDouble('fontsize') ?? 96.0;
  }

  Future<void> updateFontSize(double updatedSize) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setDouble('fontsize', updatedSize);
  }

  void addVibrationPref() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool('vibration', false);
  }

  Future<bool> getVibration() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool('vibration') ?? false;
  }

  Future<void> updateVibration(bool updatedVibration) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setBool('fontsize', updatedVibration);
  }

  final _isHours = true;
  int valueCount = 0;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) {
      print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}');
    });
    _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    _stopWatchTimer.records.listen((value) => print('records $value'));
    // addDefaultValueToSharedPreferences(); // 에러날 가능성 있음
    // addVibrationPref();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFontSize().then((value) => setState(() {
            _changeFontSize = value;
          }));
      getVibration().then((value) => setState(() {
            _changeVibration = value;
          }));
      dbHelper.readAllData().then((value) => setState(() {
            userSettingList = value;
          }));
    });
    // 탭바 컨트롤
    for (int index = 0; index < 4; index++) {
      // create a GlobalKey for each Tab
      _keys.add(new GlobalKey());
      _controller = TabController(vsync: this, length: 4);
      // _controller.animation.addListener(_handleTabAnimation);
      // _controller.addListener(_handleTabChange);
      // _animationControllerOff = AnimationController(
      //     vsync: this, duration: Duration(milliseconds: 75));
      // _animationControllerOff.value = 1.0;
      // _colorTweenBackgroundOff =
      //     ColorTween(begin: _backgroundOn, end: _backgroundOff)
      //         .animate(_animationControllerOff);
      // _colorTweenForegroundOff =
      //     ColorTween(begin: _foregroundOn, end: _foregroundOff)
      //         .animate(_animationControllerOff);
      // _animationControllerOn = AnimationController(
      //     vsync: this, duration: Duration(milliseconds: 150));
      // _animationControllerOn.value = 1.0;
      // _colorTweenBackgroundOn =
      //     ColorTween(begin: _backgroundOff, end: _backgroundOn)
      //         .animate(_animationControllerOn);
      // _colorTweenForegroundOn =
      //     ColorTween(begin: _foregroundOff, end: _foregroundOn)
      //         .animate(_animationControllerOn);
    }
  }

  @override
  void dispose() async {
    _controller.dispose();

    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = ThemeProvider.controllerOf(context);
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    List<double> _fontSizeList = [
      width * 0.092,
      width * 0.128,
      width * 0.164,
      width * 0.2,
      width * 0.23,
    ];
    return Scaffold(
      body: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: [
                          FloatingActionButton(
                              child: Icon(
                                // (isBrightnessPress)
                                Icons.lightbulb,
                                // : Icons.wb_sunny,
                                color: Theme.of(context).shadowColor,
                              ),
                              backgroundColor: Theme.of(context).focusColor,
                              elevation: 0.0,
                              onPressed: () {
                                controller.nextTheme();
                              }),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: width * 0.28, top: height * 0.05),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: width * 0.01),
                              width: height * 0.2,
                              height: height * 0.2,
                              child: FlatButton(
                                  key: _keys[0],
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Image.asset(
                                        'assets/clock.png',
                                        width: height * 0.09,
                                        height: height * 0.09,
                                        color: Theme.of(context).shadowColor,
                                      ),
                                      SizedBox(
                                        height: height * 0.03,
                                      ),
                                      Text(
                                        '시계',
                                        style:
                                            TextStyle(fontSize: height * 0.036),
                                      ),
                                    ],
                                  ),
                                  color: Theme.of(context).focusColor,
                                  onPressed: () {
                                    _buttonTap = true;
                                    _controller.animateTo(0);
                                    // _setCurrentIndex(0);
                                    // _scrollTo(0);
                                  }),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: width * 0.01),
                              width: height * 0.2,
                              height: height * 0.2,
                              child: FlatButton(
                                  key: _keys[1],
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.013,
                                      ),
                                      Image.asset(
                                        'assets/repeat.png',
                                        width: height * 0.1,
                                        height: height * 0.1,
                                        color: Theme.of(context).shadowColor,
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Text(
                                        '  반복\n타이머',
                                        style:
                                            TextStyle(fontSize: height * 0.024),
                                      ),
                                    ],
                                  ),
                                  color: Theme.of(context).focusColor,
                                  onPressed: () {
                                    _buttonTap = true;
                                    _controller.animateTo(1);
                                    // _setCurrentIndex(1);
                                    // _scrollTo(1);
                                  }),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: width * 0.01),
                              width: height * 0.2,
                              height: height * 0.2,
                              child: FlatButton(
                                  key: _keys[2],
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.015,
                                      ),
                                      Image.asset(
                                        'assets/stopwatch.png',
                                        width: height * 0.1,
                                        height: height * 0.1,
                                        color: Theme.of(context).shadowColor,
                                      ),
                                      SizedBox(
                                        height: height * 0.03,
                                      ),
                                      Text(
                                        '스톱워치',
                                        style:
                                            TextStyle(fontSize: height * 0.024),
                                      ),
                                    ],
                                  ),
                                  color: Theme.of(context).focusColor,
                                  onPressed: () {
                                    _buttonTap = true;
                                    _controller.animateTo(2);
                                  }),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: width * 0.01),
                              width: height * 0.2,
                              height: height * 0.2,
                              child: FlatButton(
                                  key: _keys[3],
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Image.asset(
                                        'assets/sandtimer.png',
                                        width: height * 0.08,
                                        height: height * 0.08,
                                        color: Theme.of(context).shadowColor,
                                      ),
                                      SizedBox(
                                        height: height * 0.04,
                                      ),
                                      Text(
                                        '타이머',
                                        style:
                                            TextStyle(fontSize: height * 0.036),
                                      ),
                                    ],
                                  ),
                                  color: Theme.of(context).focusColor,
                                  onPressed: () {
                                    _buttonTap = true;
                                    _controller.animateTo(3);
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: height * 0.65, left: width * 0.3),
                        width: width * 0.42,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: width * 0.003,
                                color: Theme.of(context).primaryColor),
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    topLeft: Radius.circular(20)),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            width: width * 0.003,
                                            color:
                                                Theme.of(context).focusColor))),
                                child: MaterialButton(
                                    child: Center(
                                      child: Text('1',
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).buttonColor,
                                              fontSize: width * 0.024,
                                              decoration: TextDecoration.none)),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          topLeft: Radius.circular(20)),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    height: height * 0.1,
                                    minWidth: width * 0.08,
                                    onPressed: () async {
                                      setState(() {
                                        _changeFontSize = _fontSizeList[0];
                                      });
                                      await updateFontSize(_changeFontSize);
                                    }),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: width * 0.003,
                                          color:
                                              Theme.of(context).focusColor))),
                              child: MaterialButton(
                                  child: Center(
                                    child: Text('2',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).buttonColor,
                                            fontSize: width * 0.024,
                                            decoration: TextDecoration.none)),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  height: height * 0.1,
                                  minWidth: width * 0.08,
                                  onPressed: () async {
                                    setState(() {
                                      _changeFontSize = _fontSizeList[1];
                                    });
                                    await updateFontSize(_changeFontSize);
                                  }),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: width * 0.003,
                                          color:
                                              Theme.of(context).focusColor))),
                              child: MaterialButton(
                                  child: Center(
                                    child: Text('3',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).buttonColor,
                                            fontSize: width * 0.024,
                                            decoration: TextDecoration.none)),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  height: height * 0.1,
                                  minWidth: width * 0.08,
                                  onPressed: () async {
                                    setState(() {
                                      _changeFontSize = _fontSizeList[2];
                                    });
                                    await updateFontSize(_changeFontSize);
                                  }),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: width * 0.003,
                                          color:
                                              Theme.of(context).focusColor))),
                              child: MaterialButton(
                                  child: Center(
                                    child: Text('4',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).buttonColor,
                                            fontSize: width * 0.024,
                                            decoration: TextDecoration.none)),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  height: height * 0.1,
                                  minWidth: width * 0.08,
                                  onPressed: () async {
                                    setState(() {
                                      _changeFontSize = _fontSizeList[3];
                                    });
                                    await updateFontSize(_changeFontSize);
                                  }),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    topRight: Radius.circular(20)),
                              ),
                              child: MaterialButton(
                                  elevation: 0.0,
                                  child: Center(
                                    child: Text('5',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).buttonColor,
                                            fontSize: width * 0.024,
                                            decoration: TextDecoration.none)),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  height: height * 0.1,
                                  minWidth: width * 0.08,
                                  onPressed: () async {
                                    setState(() {
                                      _changeFontSize = _fontSizeList[4];
                                    });
                                    await updateFontSize(_changeFontSize);
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: DefaultTabController(
            length: 4,
            child: Scaffold(
              body: TabBarView(controller: _controller, children: <Widget>[
                DateTimeClock(changeFontSize: _changeFontSize),
                timerWidget(context),
                StopWatchScreen(changeFontSize: _changeFontSize),
                OnlyTimerScreen(changeFontSize: _changeFontSize),
              ]),
            ),
          )),
    );
  }

  Widget defaultNotSelected(
      BuildContext context, int hours, int minutes, int seconds) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    if (hours < 1 && minutes < 1 && seconds < 1) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(top: height * 0.72, left: width * 0.02),
        width: width * 0.1,
        height: width * 0.1,
        child: Row(
          children: [
            SpinKitPouringHourglass(
              vibration: _changeVibration,
              size: width * 0.05,
              color: Colors.pink,
              duration:
                  Duration(hours: hours, minutes: minutes, seconds: seconds),
            ),
            SizedBox(
              width: width * 0.01,
            ),
          ],
        ),
      );
    }
  }

  void createUserTimer(int hours, int minutes, int seconds) {
    UserSetting userSetting =
        UserSetting(hours: hours, minutes: minutes, seconds: seconds);
    DBHelper().createData(userSetting);
    setState(() {
      settingHours = hours;
      settingMinutes = minutes;
      settingSeconds = seconds;
    });
  }

  Widget timerListItem(
      BuildContext context, int index, int hours, int minutes, int seconds) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(height * 0.02),
        height: height * 0.2,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              height * 0.05, height * 0.05, height * 0.05, height * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$hours h $minutes m $seconds s',
                      style: TextStyle(fontSize: height * 0.064),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          settingHours = hours;
          settingMinutes = minutes;
          settingSeconds = seconds;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget timerWidget(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Center(
      child: Stack(
        children: <Widget>[
          startButtonSelected
              ? Container(
                  margin:
                      EdgeInsets.only(top: height * 0.77, left: width * 0.1),
                  child: FloatingActionButton(
                      child: _changeVibration
                          ? Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Theme.of(context).shadowColor,
                                ),
                                Text(
                                  ' Off',
                                  style: TextStyle(
                                      color: Theme.of(context).shadowColor,
                                      fontSize: height * 0.032),
                                )
                              ],
                            )
                          : Row(
                              children: [
                                Icon(Icons.vibration,
                                    color: Theme.of(context).shadowColor),
                                Text(
                                  ' On',
                                  style: TextStyle(
                                      color: Theme.of(context).shadowColor,
                                      fontSize: height * 0.032),
                                )
                              ],
                            ),
                      backgroundColor: Theme.of(context).buttonColor,
                      elevation: 0.0,
                      onPressed: () {
                        _changeVibration
                            ? Vibration.vibrate(duration: 300)
                            : null;
                        setState(() {
                          _changeVibration = !_changeVibration;
                        });
                        print(_changeVibration);
                      }),
                )
              : Container(),
          // 모레시계 & 카운트
          startButtonSelected
              ? Container()
              : defaultNotSelected(
                  context, settingHours, settingMinutes, settingSeconds),

          // 셋팅 버튼 & 페이지

          /// 스탑워치 타이머, 시간, 시계
          Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: _stopWatchTimer.rawTime.value,
              builder: (context, snap) {
                final value = snap.data;
                final displayTime = StopWatchTimer.getDisplayTime(value,
                    hours: _isHours, milliSecond: false);

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
                              style: TextStyle(fontSize: _changeFontSize)),
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
                                                ? Theme.of(context).buttonColor
                                                : Colors.red,
                                            shape: const StadiumBorder(),
                                            onPressed: () {
                                              if (startButtonSelected) {
                                                _stopWatchTimer.onExecute.add(
                                                    StopWatchExecute.start);
                                              } else {
                                                _stopWatchTimer.onExecute
                                                    .add(StopWatchExecute.stop);
                                                _stopWatchTimer.onExecute.add(
                                                    StopWatchExecute.reset);
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
                                                    color: Theme.of(context)
                                                        .shadowColor,
                                                    fontSize: height * 0.048)),
                                          ),
                                        ),
                                        Container(
                                            child: startButtonSelected
                                                ? RaisedButton(
                                                    shape: StadiumBorder(),
                                                    elevation: 0.0,
                                                    color: Theme.of(context)
                                                        .buttonColor,
                                                    child: Text('Set',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .shadowColor,
                                                            fontSize: height *
                                                                0.048)),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Scaffold(
                                                            appBar: AppBar(
                                                              iconTheme: IconThemeData(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .shadowColor),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              shadowColor: Colors
                                                                  .transparent,
                                                            ),
                                                            body: FutureBuilder(
                                                              future: DBHelper()
                                                                  .readAllData(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        width: width *
                                                                            0.5,
                                                                        color: Colors
                                                                            .transparent,
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.topCenter,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Container(
                                                                                height: height * 0.15,
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'History',
                                                                                    style: TextStyle(color: Theme.of(context).shadowColor, fontSize: height * 0.048),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                height: height * 0.65,
                                                                                child: ListView.builder(
                                                                                  shrinkWrap: true,
                                                                                  itemCount: snapshot.data.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    UserSetting item = snapshot.data[index];
                                                                                    return Dismissible(
                                                                                      key: UniqueKey(),
                                                                                      onDismissed: (direction) {
                                                                                        DBHelper().deleteData(item.id);
                                                                                        setState(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        margin: EdgeInsets.only(bottom: height * 0.03, right: width * 0.01, left: width * 0.01),
                                                                                        width: width * 0.4,
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(30),
                                                                                          border: Border(
                                                                                            bottom: BorderSide(color: Colors.grey),
                                                                                            top: BorderSide(color: Colors.grey),
                                                                                            right: BorderSide(color: Colors.grey),
                                                                                            left: BorderSide(color: Colors.grey),
                                                                                          ),
                                                                                        ),
                                                                                        child: ListTile(
                                                                                          trailing: Container(
                                                                                            width: width * 0.1,
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Text('<---', style: TextStyle(color: Colors.red, fontSize: height * 0.064)),
                                                                                                Icon(
                                                                                                  Icons.delete,
                                                                                                  color: Colors.red,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          title: Text('${item.hours}h ${item.minutes}m ${item.seconds}s'),
                                                                                          onTap: () async {
                                                                                            setState(() {
                                                                                              settingHours = item.hours;
                                                                                              settingMinutes = item.minutes;
                                                                                              settingSeconds = item.seconds;
                                                                                            });
                                                                                            await DBHelper().readAllData();
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.transparent,
                                                                            border: Border(left: BorderSide(width: 1.0, color: Colors.grey))),
                                                                        width: width *
                                                                            0.5,
                                                                        height:
                                                                            height *
                                                                                1,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Column(
                                                                              children: [
                                                                                SizedBox(
                                                                                  height: height * 0.28,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  height: height * 0.15,
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      Container(
                                                                                        width: width * 0.166,
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            'Hour',
                                                                                            style: TextStyle(color: Theme.of(context).shadowColor, fontSize: height * 0.048),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        width: width * 0.166,
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            'Minute',
                                                                                            style: TextStyle(color: Theme.of(context).shadowColor, fontSize: height * 0.048),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        width: width * 0.166,
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            'Second',
                                                                                            style: TextStyle(color: Theme.of(context).shadowColor, fontSize: height * 0.048),
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
                                                                                          margin: EdgeInsets.only(right: width * 0.05, left: width * 0.05),
                                                                                          decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                                                                                          height: height * 0.12,
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                        children: [
                                                                                          NumberPicker.integer(
                                                                                              selectedTextStyle: TextStyle(color: Theme.of(context).shadowColor),
                                                                                              textStyle: TextStyle(color: Theme.of(context).shadowColor),
                                                                                              initialValue: currentHour,
                                                                                              minValue: 0,
                                                                                              maxValue: 12,
                                                                                              onChanged: (newValue) {
                                                                                                setState(() {
                                                                                                  currentHour = newValue;
                                                                                                });
                                                                                              }),
                                                                                          NumberPicker.integer(
                                                                                            selectedTextStyle: TextStyle(color: Theme.of(context).shadowColor),
                                                                                            textStyle: TextStyle(color: Theme.of(context).shadowColor),
                                                                                            initialValue: currentMinute,
                                                                                            minValue: 0,
                                                                                            maxValue: 60,
                                                                                            onChanged: (value) => setState(
                                                                                              () => currentMinute = value,
                                                                                            ),
                                                                                          ),
                                                                                          NumberPicker.integer(
                                                                                            selectedTextStyle: TextStyle(color: Theme.of(context).shadowColor),
                                                                                            textStyle: TextStyle(color: Theme.of(context).shadowColor),
                                                                                            initialValue: currentSecond,
                                                                                            minValue: 0,
                                                                                            maxValue: 60,
                                                                                            onChanged: (value) => setState(
                                                                                              () => currentSecond = value,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: height * 0.2,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                    children: <Widget>[
                                                                                      FlatButton(
                                                                                        child: Text(
                                                                                          "Set",
                                                                                          style: TextStyle(color: Theme.of(context).shadowColor, fontSize: width * 0.032),
                                                                                        ),
                                                                                        onPressed: () {
                                                                                          createUserTimer(currentHour, currentMinute, currentSecond);

                                                                                          setState(() {
                                                                                            currentHour = 0;
                                                                                            currentMinute = 0;
                                                                                            currentSecond = 0;
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                          // Navigator.pop(context);
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  );
                                                                } else {
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  )
                                                : Container()),
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
        ],
      ),
    );
  }

  // _handleTabAnimation() {
  //   // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
  //   _aniValue = _controller.animation.value;

  //   // if the button wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
  //   if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
  //     // set the current tab index
  //     _setCurrentIndex(_aniValue.round());
  //   }

  //   // save the previous Animation Value
  //   _prevAniValue = _aniValue;
  // }

  // // runs when the displayed tab changes
  // _handleTabChange() {
  //   // if a button was tapped, change the current index
  //   if (_buttonTap) _setCurrentIndex(_controller.index);

  //   // this resets the button tap
  //   if ((_controller.index == _prevControllerIndex) ||
  //       (_controller.index == _aniValue.round())) _buttonTap = false;

  //   // save the previous controller index
  //   _prevControllerIndex = _controller.index;
  // }

  // _setCurrentIndex(int index) {
  //   // if we're actually changing the index
  //   if (index != _currentIndex) {
  //     setState(() {
  //       // change the index
  //       _currentIndex = index;
  //     });

  //     // trigger the button animation
  //     _triggerAnimation();
  //     // scroll the TabBar to the correct position (if we have a scrollable bar)
  //     _scrollTo(index);
  //   }
  // }

  // _triggerAnimation() {
  //   // reset the animations so they're ready to go
  //   _animationControllerOn.reset();
  //   _animationControllerOff.reset();

  //   // run the animations!
  //   _animationControllerOn.forward();
  //   _animationControllerOff.forward();
  // }

  // _scrollTo(int index) {
  //   // get the screen width. This is used to check if we have an element off screen
  //   double screenWidth = MediaQuery.of(context).size.width;

  //   // get the button we want to scroll to
  //   RenderBox renderBox = _keys[index].currentContext.findRenderObject();
  //   // get its size
  //   double size = renderBox.size.width;
  //   // and position
  //   double position = renderBox.localToGlobal(Offset.zero).dx;

  //   // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
  //   double offset = (position + size / 2) - screenWidth / 2;

  //   // if the button is to the left of the middle
  //   if (offset < 0) {
  //     // get the first button
  //     renderBox = _keys[0].currentContext.findRenderObject();
  //     // get the position of the first button of the TabBar
  //     position = renderBox.localToGlobal(Offset.zero).dx;

  //     // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
  //     if (position > offset) offset = position;
  //   } else {
  //     // if the button is to the right of the middle

  //     // get the last button
  //     renderBox = _keys[4 - 1].currentContext.findRenderObject();
  //     // get its position
  //     position = renderBox.localToGlobal(Offset.zero).dx;
  //     // and size
  //     size = renderBox.size.width;

  //     // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
  //     if (position + size < screenWidth) screenWidth = position + size;

  //     // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
  //     if (position + size - offset < screenWidth) {
  //       offset = position + size - screenWidth;
  //     }
  //   }

  //   // scroll the calculated ammount
  //   _scrollController.animateTo(offset + _scrollController.offset,
  //       duration: new Duration(milliseconds: 150), curve: Curves.easeInOut);
  // }

  // _getBackgroundColor(int index) {
  //   if (index == _currentIndex) {
  //     // if it's active button
  //     return _colorTweenBackgroundOn.value;
  //   } else if (index == _prevControllerIndex) {
  //     // if it's the previous active button
  //     return _colorTweenBackgroundOff.value;
  //   } else {
  //     // if the button is inactive
  //     return _backgroundOff;
  //   }
  // }

  // _getForegroundColor(int index) {
  //   // the same as the above
  //   if (index == _currentIndex) {
  //     return _colorTweenForegroundOn.value;
  //   } else if (index == _prevControllerIndex) {
  //     return _colorTweenForegroundOff.value;
  //   } else {
  //     return _foregroundOff;
  //   }
  // }
}
