import 'package:flutter/material.dart';
import '../../utils/api_service.dart';
import 'otp_verification_view.dart';

class EmailVerificationView extends StatefulWidget {
  final String name;
  final String email;
  final String address;

  const EmailVerificationView({
    super.key,
    required this.name,
    required this.email,
    required this.address,
  });

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  late final TextEditingController _emailController;
  bool _isLoading = false;

  static const Color _green = Color(0xFF80C400);
  static const Color _text = Color(0xFF171923);
  static const Color _muted = Color(0xFF737987);
  static const Color _field = Color(0xFFF5FCEC);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.sendOtp(email);
      debugPrint('Send OTP Response: $response');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success'] == true) {
        _showMessage('Verification code sent to your email.');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationView(
              name: widget.name,
              email: email,
              address: widget.address,
            ),
          ),
        );
      } else {
        _showMessage(response['message']?.toString() ?? 'Failed to send OTP.');
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showMessage('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  color: _text,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                "We'll send a verification code to this email to confirm your account.",
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Email Address',
                style: TextStyle(
                  color: _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(color: _muted, fontSize: 13),
                  prefixIcon: const Icon(Icons.email_outlined, color: _muted, size: 19),
                  filled: true,
                  fillColor: _field,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: Color(0xFFEAF2E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: _green, width: 1.3),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
