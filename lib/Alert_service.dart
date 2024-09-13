import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

class AlertService {
  static void showToast({
    required BuildContext context, // Add context parameter
    required String text,
    IconData icon = Icons.info,
    Color color = Colors.black,
    Color bgcolor = Colors.blueGrey,
  }) {
    try {
      DelightToastBar(
        autoDismiss: true,
        position: DelightSnackbarPosition.top,
        builder: (context) {
          return ToastCard(
            leading: Icon(
              icon,
              size: 28,
              color: color,
            ),
            title: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white
              ),
            ),
            color: bgcolor,
          );
        },
      ).show(context); // Use the passed context
    } catch (e) {
      print(e);
    }
  }
}
