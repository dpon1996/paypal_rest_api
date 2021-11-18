import 'package:flutter/material.dart';

showSnackbarMessage(BuildContext context,
    String message, {
      Color color = Colors.red,
      String actionLabel = "Try Again",
      second = 3,
      required GestureTapCallback onTap,
    }) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: second),
      action: SnackBarAction(label: actionLabel, onPressed: onTap),
    ),
  );
}
