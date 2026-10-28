
import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../utils/api_service.dart';
import '../../utils/shared_prefs_helper.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../home/screens/home_view.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';

class LoginView extends StatefulWidget {
const LoginView({super.key});

@override
State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

bool _isLoading = false;
bool _obscurePassword = true;
bool _rememberMe = false;

static const Color _green = Color(0xFF80C400);
static const Color _text = Color(0xFF202533);
static const Color _muted = Color(0xFF778091);
static const Color _field = Color(0xFFF5FCEC);

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

Future<void> _handleLogin() async {
if (_isLoading) return;

final email = _emailController.text.trim();
final password = _passwordController.text;

if (email.isEmpty || password.isEmpty) {
_showMessage('Please enter your email and password.');
return;
}

final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

if (!emailRegex.hasMatch(email)) {
_showMessage('Please enter a valid email address.');
return;
}

setState(() => _isLoading = true);

try {
final response = await ApiService.login(email, password);

if (!mounted) return;

if (response['success'] == true &&
response['user'] != null) {
final user = UserModel.fromJson(response['user']);

await SharedPrefsHelper.saveUser(user);

if (!mounted) return;

Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(
builder: (_) => HomeView(user: user),
),
(route) => false,
);
} else {
_showMessage(
response['message']?.toString() ??
'Login failed. Please try again.',
);
}
} catch (e) {
if (mounted) {
_showMessage(
'Unable to log in. Please check your connection.',
);
}

debugPrint('Login error: $e');
} finally {
if (mounted) {
setState(() => _isLoading = false);
}
}
}

void _showMessage(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
),
);
}

InputDecoration _decoration({
required String hint,
required IconData icon,
Widget? suffix,
}) {
return InputDecoration(
hintText: hint,
hintStyle: const TextStyle(
color: _muted,
fontSize: 13,
),
prefixIcon: Icon(
icon,
color: _muted,
size: 19,
),
suffixIcon: suffix,
filled: true,
fillColor: _field,
contentPadding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 17,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(7),
borderSide: BorderSide.none,
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(7),
borderSide: const BorderSide(
color: Color(0xFFEAF2E1),
),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(7),
borderSide: const BorderSide(
color: _green,
width: 1.3,
),
),
);
}

Widget _label(String text) {
return Padding(
padding: const EdgeInsets.only(bottom: 7),
child: Text(
text,
style: const TextStyle(
color: _text,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
);
}

Widget _emailField() {
return TextField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
textInputAction: TextInputAction.next,
autofillHints: const [AutofillHints.email],
decoration: _decoration(
hint: AppStrings.emailHint,
icon: Icons.email_outlined,
),
);
}

Widget _passwordField() {
return TextField(
controller: _passwordController,
obscureText: _obscurePassword,
textInputAction: TextInputAction.done,
autofillHints: const [AutofillHints.password],
onSubmitted: (_) => _handleLogin(),
decoration: _decoration(
hint: AppStrings.passwordHint,
icon: Icons.lock_outline_rounded,
suffix: IconButton(
tooltip: _obscurePassword
? 'Show password'
    : 'Hide password',
onPressed: () {
setState(() {
_obscurePassword = !_obscurePassword;
});
},
icon: Icon(
_obscurePassword
? Icons.visibility_off_outlined
    : Icons.visibility_outlined,
size: 19,
color: _muted,
),
),
),
);
}

Widget _rememberMeCheckbox() {
return Row(
children: [
SizedBox(
width: 22,
height: 22,
child: Checkbox(
value: _rememberMe,
onChanged: (value) {
setState(() {
_rememberMe = value ?? false;
});
},
activeColor: _green,
checkColor: Colors.white,
side: const BorderSide(
color: _green,
width: 1.3,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(4),
),
materialTapTargetSize:
MaterialTapTargetSize.shrinkWrap,
),
),
const SizedBox(width: 8),
GestureDetector(
onTap: () {
setState(() {
_rememberMe = !_rememberMe;
});
},
child: const Text(
'Remember me',
style: TextStyle(
color: _muted,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
),
],
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: LayoutBuilder(
builder: (context, constraints) {
return SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
20,
38,
20,
24,
),
child: ConstrainedBox(
constraints: BoxConstraints(
minHeight: constraints.maxHeight - 62,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 28),

const Text(
'Welcome Back!',
style: TextStyle(
color: _text,
fontSize: 28,
fontWeight: FontWeight.w700,
letterSpacing: -0.7,
),
),

const SizedBox(height: 9),

const Text(
'Sign in to continue managing your tasks and '
'stay in control of your day.',
style: TextStyle(
color: _muted,
fontSize: 12,
height: 1.6,
),
),

const SizedBox(height: 34),

_label('Email Address'),
_emailField(),

const SizedBox(height: 20),

_label('Password'),
_passwordField(),

const SizedBox(height: 10),

// Remember me and Forgot Password.
Row(
children: [
Expanded(
child: _rememberMeCheckbox(),
),
TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const ForgotPasswordView(),
),
);
},
style: TextButton.styleFrom(
foregroundColor: _green,
padding: const EdgeInsets.symmetric(
horizontal: 4,
vertical: 8,
),
),
child: const Text(
'Forgot Password?',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 26),

Row(
children: [
const Expanded(
child: Divider(
color: Color(0xFFD5DCE4),
),
),
Padding(
padding: const EdgeInsets.symmetric(
horizontal: 12,
),
child: Text(
'OR',
style: const TextStyle(
color: _muted,
fontSize: 11,
fontWeight: FontWeight.w700,
),
),
),
const Expanded(
child: Divider(
color: Color(0xFFD5DCE4),
),
),
],
),

const SizedBox(height: 24),

Row(
mainAxisAlignment: MainAxisAlignment.start,
children: [
const Flexible(
child: Text(
"Don't have an account? ",
style: TextStyle(
color: _muted,
fontSize: 12,
),
),
),
TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const RegisterView(),
),
);
},
style: TextButton.styleFrom(
foregroundColor: _green,
padding: const EdgeInsets.symmetric(
horizontal: 4,
),
),
child: const Text(
'Sign Up',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w700,
),
),
),
],
),

const SizedBox(height: 14),

SizedBox(
width: double.infinity,
height: 49,
child: CustomButton(
text: AppStrings.loginButton,
onPressed: _handleLogin,
isLoading: _isLoading,
),
),
],
),
),
);
},
),
),
);
}
}
