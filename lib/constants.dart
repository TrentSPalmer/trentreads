import 'package:flutter/material.dart';

int oneMinute = 60;
int sixHours = 21600;
int oneDay = 86400;
int updateInterval = oneDay;
String defaultImageUrl =
    "https://static.trentpalmer.org/audio/images/302px-plutarchs_lives.jpg";
String defaultImageFileName =
    defaultImageUrl.substring(defaultImageUrl.indexOf('audio/images') + 13);

class AppColors {
  Color navy;
  Color peacockBlue;
  Color ivory;
  Color candyApple;

  AppColors(this.navy, this.peacockBlue, this.ivory, this.candyApple);
}

AppColors appColors = AppColors(
  Color(0xff00293C),
  Color(0xff1e656d),
  Color(0xfff1f3ce),
  Color(0xfff62a00),
);

BoxDecoration myBoxDecoration(Color appColor) {
  return BoxDecoration(
    color: appColor,
    border: Border.all(
      width: 2.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    boxShadow: [
      BoxShadow(
        offset: Offset(2.0, 1.0),
        blurRadius: 1.0,
        spreadRadius: 1.0,
      )
    ],
  );
}
