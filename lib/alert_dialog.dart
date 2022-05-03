import 'package:flutter/material.dart';

Future<void> showAlert(BuildContext context, String msg) async {
  final _alert = AlertDialog(
    title: const Text('Error'),
    content: Text(msg),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: const BorderSide(color: Colors.purpleAccent)),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'))
    ],
  );

  showDialog(context: context, builder: (context) => _alert);
}
