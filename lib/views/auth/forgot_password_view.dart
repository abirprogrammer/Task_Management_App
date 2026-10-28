import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  void _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your registered email")),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulated api call
    setState(() {
      _isLoading = false;
      _isSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reset Password", style: AppStyles.heading1),
              const SizedBox(height: 8),
              Text(
                "Enter your email address and we'll send you instructions to reset your password.",
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_isSent)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lowPriority.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lowPriority),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.lowPriority),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Password reset instructions have been sent to your email.",
                          style: AppStyles.bodyMedium.copyWith(color: AppColors.lowPriority, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                CustomTextField(
                  controller: _emailController,
                  hintText: "Enter your email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Send Reset Link",
                  onPressed: _handleReset,
                  isLoading: _isLoading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
