
import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import 'email_verification_view.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
const RegisterView({super.key});

@override
State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
final _firstNameController = TextEditingController();
final _lastNameController = TextEditingController();
final _emailController = TextEditingController();
final _addressController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();

bool _acceptedTerms = false;
bool _isPasswordVisible = false;
bool _isConfirmPasswordVisible = false;

static const Color _green = Color(0xFF80C400);
static const Color _text = Color(0xFF202533);
static const Color _muted = Color(0xFF778091);
static const Color _field = Color(0xFFF5FCEC);

@override
void dispose() {
_firstNameController.dispose();
_lastNameController.dispose();
_emailController.dispose();
_addressController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();

super.dispose();
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

void _handleContinue() {
final firstName = _firstNameController.text.trim();
final lastName = _lastNameController.text.trim();
final email = _emailController.text.trim();
final address = _addressController.text.trim();
final password = _passwordController.text;
final confirmPassword = _confirmPasswordController.text;

if (firstName.isEmpty ||
lastName.isEmpty ||
email.isEmpty ||
address.isEmpty ||
password.isEmpty ||
confirmPassword.isEmpty) {
_showMessage('Please fill in all fields.');
return;
}

final emailRegex = RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
);

if (!emailRegex.hasMatch(email)) {
_showMessage('Please enter a valid email address.');
return;
}

if (password.length < 8) {
_showMessage(
'Password must be at least 8 characters long.',
);
return;
}

if (password != confirmPassword) {
_showMessage('Passwords do not match.');
return;
}

if (!_acceptedTerms) {
_showMessage('Please accept the Terms & Conditions.');
return;
}

final fullName = '$firstName $lastName'.trim();

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => EmailVerificationView(
name: fullName,
email: email,
address: address,
),
),
);
}

InputDecoration _decoration({
required String hint,
required IconData icon,
Widget? suffixIcon,
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
suffixIcon: suffixIcon,
filled: true,
fillColor: _field,
contentPadding: const EdgeInsets.symmetric(
horizontal: 13,
vertical: 15,
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

Widget _buildTextField({
required String label,
required String hint,
required IconData icon,
required TextEditingController controller,
TextInputType keyboardType = TextInputType.text,
TextInputAction textInputAction = TextInputAction.next,
bool isPassword = false,
bool isPasswordVisible = false,
VoidCallback? onVisibilityToggle,
}) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_label(label),
TextField(
controller: controller,
keyboardType: keyboardType,
textInputAction: textInputAction,
obscureText: isPassword && !isPasswordVisible,
autocorrect: !isPassword,
enableSuggestions: !isPassword,
decoration: _decoration(
hint: hint,
icon: icon,
suffixIcon: isPassword
? IconButton(
onPressed: onVisibilityToggle,
tooltip: isPasswordVisible
? 'Hide password'
    : 'Show password',
icon: Icon(
isPasswordVisible
? Icons.visibility_rounded
    : Icons.visibility_off_rounded,
color: _muted,
size: 19,
),
)
    : null,
),
),
],
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
scrolledUnderElevation: 0,
leading: IconButton(
icon: const Icon(
Icons.arrow_back_rounded,
color: _text,
),
onPressed: () => Navigator.maybePop(context),
),
),
body: SafeArea(
top: false,
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Create Your Account',
style: TextStyle(
color: _text,
fontSize: 27,
fontWeight: FontWeight.w700,
letterSpacing: -0.7,
),
),
const SizedBox(height: 9),
const Text(
'Join Task Manager today — organize better, '
'work smarter, and stay in control of your day.',
style: TextStyle(
color: _muted,
fontSize: 12,
height: 1.6,
),
),

const SizedBox(height: 25),

_buildTextField(
label: 'First Name',
hint: 'e.g. Kristin',
icon: Icons.person_outline_rounded,
controller: _firstNameController,
),

const SizedBox(height: 18),

_buildTextField(
label: 'Last Name',
hint: 'e.g. Cooper',
icon: Icons.person_outline_rounded,
controller: _lastNameController,
),

const SizedBox(height: 18),

_buildTextField(
label: 'Email Address',
hint: 'e.g. kristin.cooper@example.com',
icon: Icons.email_outlined,
controller: _emailController,
keyboardType: TextInputType.emailAddress,
),

const SizedBox(height: 18),

_buildTextField(
label: 'Address',
hint: 'e.g. 1234 Elm Street',
icon: Icons.location_on_outlined,
controller: _addressController,
textInputAction: TextInputAction.next,
),

const SizedBox(height: 18),

// Password field with show/hide icon.
_buildTextField(
label: 'Password',
hint: 'Enter your password',
icon: Icons.lock_outline_rounded,
controller: _passwordController,
isPassword: true,
isPasswordVisible: _isPasswordVisible,
onVisibilityToggle: () {
setState(() {
_isPasswordVisible = !_isPasswordVisible;
});
},
),

const SizedBox(height: 18),

// Confirm Password field with independent icon.
_buildTextField(
label: 'Confirm Password',
hint: 'Re-enter your password',
icon: Icons.lock_outline_rounded,
controller: _confirmPasswordController,
textInputAction: TextInputAction.done,
isPassword: true,
isPasswordVisible: _isConfirmPasswordVisible,
onVisibilityToggle: () {
setState(() {
_isConfirmPasswordVisible =
!_isConfirmPasswordVisible;
});
},
),

const SizedBox(height: 16),

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(
width: 22,
height: 22,
child: Checkbox(
value: _acceptedTerms,
onChanged: (value) {
setState(() {
_acceptedTerms = value ?? false;
});
},
activeColor: _green,
side: const BorderSide(
color: _green,
width: 1.2,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(3),
),
materialTapTargetSize:
MaterialTapTargetSize.shrinkWrap,
),
),
const SizedBox(width: 7),
Expanded(
child: Padding(
padding: const EdgeInsets.only(top: 2),
child: Wrap(
children: [
const Text(
'I agree to the ',
style: TextStyle(
color: _muted,
fontSize: 11,
height: 1.5,
),
),
GestureDetector(
onTap: () {
_showMessage(
'Add your Terms & Conditions page here.',
);
},
child: const Text(
'Terms & Conditions',
style: TextStyle(
color: _green,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
),
const Text(
' and ',
style: TextStyle(
color: _muted,
fontSize: 11,
),
),
GestureDetector(
onTap: () {
_showMessage(
'Add your Privacy Policy page here.',
);
},
child: const Text(
'Privacy Policy',
style: TextStyle(
color: _green,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
),
],
),

const SizedBox(height: 18),

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

const SizedBox(height: 12),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Flexible(
child: Text(
'Already have an account? ',
style: TextStyle(
color: _muted,
fontSize: 12,
),
),
),
TextButton(
onPressed: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => const LoginView(),
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
'Log In',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w700,
),
),
),
],
),

const SizedBox(height: 12),

SizedBox(
width: double.infinity,
height: 49,
child: CustomButton(
text: 'Continue',
onPressed: _handleContinue,
),
),
],
),
),
),
);
}
}
