import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:timer/another_screens/datetime_screen.dart';
import 'package:timer/another_screens/timer_screen.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIOverlays([]);
  Screen.keepOn(true);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme customAppBlack() {
    return AppTheme(
      id: 'black',
      description: "Custom Color Scheme1",
      data: ThemeData(
          textTheme: TextTheme(headline3: TextStyle(color: Colors.white)),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          buttonColor: Colors.black,
          primaryColor: Color(0xff737373),
          shadowColor: Colors.white,
          accentColor: Colors.black),
    );
  }

  AppTheme customAppWhite() {
    return AppTheme(
      id: 'white',
      description: "Custom Color Scheme2",
      data: ThemeData(
          textTheme: TextTheme(headline3: TextStyle(color: Colors.black)),
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          buttonColor: Colors.white,
          primaryColor: Colors.black,
          shadowColor: Colors.black,
          accentColor: Color(0xff737373)),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    return ThemeProvider(
        themes: <AppTheme>[
          // AppTheme.dark(id: 'dark'),
          customAppWhite(),
          customAppBlack(),
        ],
        saveThemesOnChange: true,
        loadThemeOnInit: false,
        onInitCallback: (controller, previouslySavedThemeFuture) async {
          String savedTheme = await previouslySavedThemeFuture;
          if (savedTheme != null) {
            controller.setTheme(savedTheme);
          } else {
            Brightness platformBrightness =
                SchedulerBinding.instance.window.platformBrightness;
            if (platformBrightness == Brightness.dark) {
              controller.setTheme('black');
            } else {
              controller.setTheme('white');
            }
            controller.forgetSavedTheme();
          }
        },
        child: ThemeConsumer(
          child: Builder(
            builder: (themeContext) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Just Timer',
              theme: ThemeProvider.themeOf(themeContext).data,
              home: TimerPage(),
            ),
          ),
        ));
  }
}
