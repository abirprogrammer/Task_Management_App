import 'package:flutter/material.dart';

class SuccessAlertDialog {
  SuccessAlertDialog._();

  static const Color successGreen = Color(0xFF80C900);
  static const Color titleColor = Color(0xFF111111);
  static const Color descriptionColor = Color(0xFF506078);

  static Future<void> show({
    required BuildContext context,
    String title = 'Success',
    required String description,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: successGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 54,
                    color: successGreen,
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: titleColor,
                  ),
                ),

                const SizedBox(height: 5),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: descriptionColor,
                  ),
                ),

                const SizedBox(height: 20),

                // OK button
                SizedBox(
                  width: 115,
                  height: 40,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onPressed?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: successGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
