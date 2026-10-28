import 'package:flutter/material.dart';
import '../../utils/api_service.dart';
import '../../utils/shared_prefs_helper.dart';
import '../../models/user_model.dart';
import '../home/screens/home_view.dart';

class SetPasswordView extends StatefulWidget {
  final String name;
  final String email;
  final String address;

  const SetPasswordView({
    super.key,
    required this.name,
    required this.email,
    required this.address,
  });

  @override
  State<SetPasswordView> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const Color _green = Color(0xFF80C400);
  static const Color _text = Color(0xFF171923);
  static const Color _muted = Color(0xFF737987);
  static const Color _field = Color(0xFFF5FCEC);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleCompleteRegistration() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      _showMessage('Please enter and confirm your password.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters long.');
      return;
    }

    if (password != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
        widget.name,
        widget.email,
        widget.address,
        password,
      );

      if (!mounted) return;

      if (response['success'] == true && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);
        await SharedPrefsHelper.saveUser(user);

        if (!mounted) return;

        _showMessage('Account created successfully!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeView(user: user)),
          (route) => false,
        );
      } else {
        _showMessage(response['message']?.toString() ?? 'Registration failed.');
      }
    } catch (e) {
      _showMessage('Network error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration({required String hint, required Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      prefixIcon: const Icon(Icons.lock_outline_rounded, color: _muted, size: 19),
      suffixIcon: suffix,
      filled: true,
      fillColor: _field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
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
    );
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
                'Set Your New Password',
                style: TextStyle(
                  color: _text,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Create a secure password to protect your account and get started seamlessly!',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'New Password',
                style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _decoration(
                  hint: '••••••••',
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 19,
                      color: _muted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'New Confirm Password',
                style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                onSubmitted: (_) => _handleCompleteRegistration(),
                decoration: _decoration(
                  hint: '••••••••',
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 19,
                      color: _muted,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCompleteRegistration,
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
                          'Continue',
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
