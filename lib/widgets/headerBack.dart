import 'package:flutter/material.dart';

AppBar headerBack(context,
    {bool isAppTitle = false,
    String titleText = "",
    removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      titleText,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: "Signatra",
        fontSize: 40.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
