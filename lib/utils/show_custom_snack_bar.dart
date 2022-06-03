import 'package:flutter/material.dart';

showCustomSnackBar(String msg, BuildContext context,
    {bool taskSuccess = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
      ),
      backgroundColor: taskSuccess == true
          ? Colors.green.withOpacity(0.6)
          : Colors.red.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1500),
    ),
  );
}
