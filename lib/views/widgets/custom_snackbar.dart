import 'package:flutter/material.dart';

enum Message { success, error, info, warning }

class CustomSnackBar {
  static void snackBar(BuildContext context,
      {required String text, required Message message}) {
    Color color = Colors.white;
    Color bgColor;
    switch (message) {
      case Message.warning:
        bgColor = Colors.orange[900]!;
        break;
      case Message.error:
        bgColor = Colors.red[900]!;
        break;
      case Message.info:
        bgColor = Colors.blue;
        break;
      default:
        bgColor = Colors.teal;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
      backgroundColor: bgColor,
      duration: Duration(seconds: 3),
    ));
  }
}
