
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/api_service.dart';
import 'set_password_view.dart';

class OtpVerificationView extends StatefulWidget {
final String name;
final String email;
final String address;

const OtpVerificationView({
super.key,
required this.name,
required this.email,
required this.address,
});

@override
State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

bool _isLoading = false;

static const Color _green = Color(0xFF80C400);
static const Color _text = Color(0xFF171923);
static const Color _muted = Color(0xFF737987);
static const Color _boxBg = Color(0xFFF7F9FC);

@override
void dispose() {
for (var c in _controllers) {
c.dispose();
}
for (var f in _focusNodes) {
f.dispose();
}
super.dispose();
}

void _showMessage(String message) {
if (!mounted) return;
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

String get _otpCode => _controllers.map((c) => c.text).join();

Future<void> _handleConfirm() async {
final otp = _otpCode;
if (otp.length < 6) {
_showMessage('Please enter the complete 6-digit code.');
return;
}

setState(() => _isLoading = true);

try {
final response = await ApiService.verifyOtp(widget.email, otp);
if (!mounted) return;

if (response['success'] == true) {
_showMessage('Email verified successfully!');
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => SetPasswordView(
name: widget.name,
email: widget.email,
address: widget.address,
),
),
);
} else {
_showMessage(response['message']?.toString() ?? 'Invalid verification code.');
}
} catch (e) {
_showMessage('Network error: $e');
} finally {
if (mounted) setState(() => _isLoading = false);
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
'6-digit code',
style: TextStyle(
color: _text,
fontSize: 27,
fontWeight: FontWeight.w700,
letterSpacing: -0.7,
),
),
const SizedBox(height: 9),
Text(
"Please enter the code we've sent to\n${widget.email}",
style: const TextStyle(
color: _muted,
fontSize: 12,
height: 1.6,
),
),
const SizedBox(height: 36),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: List.generate(6, (index) {
return SizedBox(
width: 48,
height: 54,
child: TextField(
controller: _controllers[index],
focusNode: _focusNodes[index],
keyboardType: TextInputType.number,
textAlign: TextAlign.center,
maxLength: 1,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.w600,
color: _text,
),
decoration: InputDecoration(
counterText: '',
filled: true,
fillColor: _boxBg,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(9),
borderSide: BorderSide.none,
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9),
borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9),
borderSide: const BorderSide(color: _green, width: 1.5),
),
),
onChanged: (value) {
if (value.isNotEmpty && index < 5) {
_focusNodes[index + 1].requestFocus();
} else if (value.isEmpty && index > 0) {
_focusNodes[index - 1].requestFocus();
}
if (index == 5 && value.isNotEmpty && _otpCode.length == 6) {
_handleConfirm();
}
},
),
);
}),
),
const Spacer(),
SizedBox(
width: double.infinity,
height: 49,
child: ElevatedButton(
onPressed: _isLoading ? null : _handleConfirm,
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
'Confirm',
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