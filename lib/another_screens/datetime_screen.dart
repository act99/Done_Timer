import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

import 'package:timer_builder/timer_builder.dart';

class DateTimeClock extends StatelessWidget {
  final double changeFontSize;
  DateTimeClock({this.changeFontSize});
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
          return Center(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.05,
                ),
                Text(
                    formatDate(DateTime.now(), [
                      hh,
                      ':',
                      nn,
                    ]), // add pubspec.yaml the date_format: ^1.0.9
                    style: TextStyle(
                      fontSize: changeFontSize * 1.3,
                      fontWeight: FontWeight.w600,
                    )),
                Container(
                  margin: EdgeInsets.only(left: width * 0.6),
                  child: Text(
                      formatDate(DateTime.now(), [
                        am,
                      ]), // add pubspec.yaml the date_format: ^1.0.9
                      style: TextStyle(
                        fontSize: changeFontSize * 0.2,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          );
        })
      ],
    );
  }
}
