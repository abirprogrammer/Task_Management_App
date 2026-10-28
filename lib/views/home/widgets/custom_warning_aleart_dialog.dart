
import 'package:flutter/material.dart';

class CustomAlertDialog {
  CustomAlertDialog._();

  static const Color defaultGreen = Color(0xFF80C900);
  static const Color defaultTextColor = Color(0xFF111111);
  static const Color defaultDescriptionColor = Color(0xFF506078);

  /// Displays a reusable, customizable alert dialog.
  ///
  /// Returns true when confirmed, false when cancelled,
  /// and null when dismissed externally.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color iconColor = const Color(0xFFFFB000),
    Color confirmColor = defaultGreen,
    Color? cancelColor,
    Color titleColor = defaultTextColor,
    Color descriptionColor = defaultDescriptionColor,
    bool showCancelButton = true,
    double iconSize = 42,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final effectiveCancelColor = cancelColor ?? confirmColor;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container.
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: iconColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Dialog title.
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: titleColor,
                  ),
                ),

                const SizedBox(height: 7),

                // Dialog description.
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: descriptionColor,
                  ),
                ),

                const SizedBox(height: 22),

                // Action buttons.
                Row(
                  children: [
                    if (showCancelButton) ...[
                      Expanded(
                        child: SizedBox(
                          height: 43,
                          child: OutlinedButton(
                            onPressed: () {
                              onCancel?.call();
                              Navigator.of(dialogContext).pop(false);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: effectiveCancelColor,
                              side: BorderSide(
                                color: effectiveCancelColor,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: Text(
                              cancelText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                    ],

                    Expanded(
                      child: SizedBox(
                        height: 43,
                        child: FilledButton(
                          onPressed: () {
                            onConfirm?.call();
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                          child: Text(
                            confirmText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
