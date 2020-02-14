import 'package:flutter/material.dart';

class SnackUtil {
  static void show(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text((text == null || text.length <= 0) ? "" : text),
    ));
  }
}
