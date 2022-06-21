import 'package:flutter/material.dart';

Container floatingButton() {
  return Container(
    height: 60.0,
    width: 60.0,
    child: FittedBox(
      child: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    ),
  );
}
