import 'package:flutter/material.dart';

AppBar headerTitle(context,
    {bool isAppTitle = false, String titleText = "", removeBackButton = true}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      titleText,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: "Signatra",
        fontSize: 30.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
