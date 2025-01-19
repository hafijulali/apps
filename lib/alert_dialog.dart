import 'package:flutter/material.dart';

Future<String?> showAlertDialog(
  BuildContext context,
  String title,
  String message,
) async =>
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => safePopWithResult(context, 'CANCEL'),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => safePopWithResult(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );

Future<String?> safePopWithResult(BuildContext context, String result) async {
  if (Navigator.canPop(context)) {
    Navigator.pop(context, result);
  }
  return 'NONE';
}
