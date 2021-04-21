import 'package:flutter/material.dart';

AppBar headerWidget({String title, Key key}) {
  return AppBar(
    title: Text(title, style: TextStyle(color: Colors.black)),
    key: key,
    // elevation: 0,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
  );
}
