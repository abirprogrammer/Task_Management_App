import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../utils/api_service.dart';
import '../../utils/shared_prefs_helper.dart';
import '../auth/login_view.dart';
import '../home/widgets/custom_warning_aleart_dialog.dart';
import '../home/widgets/success_alert_dialog.dart';
import 'my_profile_view.dart';
import 'account_setting_view.dart';
import 'terms_condition_view.dart';
import 'privacy_policy_view.dart';
import 'help_support_view.dart';

class ProfileView extends StatefulWidget {
  final UserModel user;
  final String? profileImageBase64;
  final ValueChanged<UserModel>? onUserUpdated;
  final ValueChanged<String?>? onImageUpdated;
  final VoidCallback? onMyTasksTap;
  final VoidCallback? onAddTaskTap;

  const ProfileView({
    super.key,
    required this.user,
    this.profileImageBase64,
    this.onUserUpdated,
    this.onImageUpdated,
    this.onMyTasksTap,
    this.onAddTaskTap,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const Color green = Color(0xFF80C900);
  static const Color lightGreen = Color(0xFFF3FBE9);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF788195);

  late UserModel _currentUser;
  File? _profileImage;
  String? _profileImageBase64;
  bool _isPickingImage = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _profileImageBase64 = widget.profileImageBase64 ?? widget.user.profileImage;
  }

  @override
  void didUpdateWidget(covariant ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      _currentUser = widget.user;
    }
    if (widget.profileImageBase64 != oldWidget.profileImageBase64) {
      _profileImageBase64 = widget.profileImageBase64 ?? widget.user.profileImage;
    }
  }

  String get _userName {
    final name = _currentUser.name.trim();
    return name.isEmpty ? 'User' : name;
  }

  String get _initial => _userName.substring(0, 1).toUpperCase();

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF263128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // Select and preview a profile image locally and upload to database.
  Future<void> _pickProfileImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final XFile? selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (selectedImage == null || !mounted) return;

      setState(() {
        _profileImage = File(selectedImage.path);
      });

      final bytes = await File(selectedImage.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await ApiService.uploadProfileImage(_currentUser.id, base64Image);
      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _profileImageBase64 = base64Image;
          _currentUser = _currentUser.copyWith(profileImage: base64Image);
        });
        await SharedPrefsHelper.saveUser(_currentUser);
        if (widget.onImageUpdated != null) {
          widget.onImageUpdated!(base64Image);
        }
        _showMessage('Profile photo updated and saved to database successfully.');
      } else {
        _showMessage(response['message']?.toString() ?? 'Failed to save image in database.');
      }
    } catch (error, stackTrace) {
      debugPrint('Profile image error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Unable to select image. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final confirmed = await CustomAlertDialog.show(
      context: context,
      title: 'Warning',
      description: 'Are you sure you want to log out of your account?',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFFFB000),
      confirmText: 'Confirm',
      confirmColor: AppColors.primary,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await SharedPrefsHelper.logout();

      if (!mounted) return;
      setState(() => _isLoggingOut = false);

      SuccessAlertDialog.show(
        context: context,
        title: 'Success',
        description: 'You have been logged out successfully.',
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => const LoginView(),
            ),
            (route) => false,
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Logout error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() => _isLoggingOut = false);
        _showMessage('Logout failed. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF10130E)
        : const Color(0xFFF7F9F5);

    final cardColor = isDark
        ? const Color(0xFF20251E)
        : Colors.white;

    final primaryText = isDark ? Colors.white : textDark;

    final secondaryText =
        isDark ? const Color(0xFFB8C0B3) : textGrey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Scrollable profile content.
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Profile banner and overlapping avatar.
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 174,
                          child: ClipPath(
                            clipper: ProfileHeaderClipper(),
                            child: Image.asset(
                              'assets/images/profilebanner.png',
                              width: double.infinity,
                              height: 174,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const ColoredBox(
                                  color: green,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Circular profile avatar.
                        Positioned(
                          top: 112,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 86,
                                  height: 86,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _profileImageBase64 != null
                                        ? Image.memory(
                                            base64Decode(_profileImageBase64!),
                                            fit: BoxFit.cover,
                                          )
                                        : _profileImage != null
                                            ? Image.file(
                                                _profileImage!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return _InitialAvatar(
                                                    initial: _initial,
                                                  );
                                                },
                                              )
                                            : _InitialAvatar(
                                                initial: _initial,
                                              ),
                                  ),
                                ),

                                // Camera badge.
                                Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cardColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: _isPickingImage
                                        ? const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // User name and email.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _userName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _currentUser.email,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF293421)
                                  : lightGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 14,
                                  color: green,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Personal Account',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // All menu items are individual cards.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeading(
                            title: 'Account',
                            textColor: primaryText,
                          ),
                          const SizedBox(height: 11),

                          _ProfileMenuCard(
                            backgroundColor: cardColor,
                            isDark: isDark,
                            child: _ProfileMenuTile(
                              icon: Icons.person_outline_rounded,
                              title: 'My Profile',
                              subtitle: 'View or change your profile details',
                              textColor: primaryText,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyProfileView(
                                      user: _currentUser,
                                      profileImageBase64: _profileImageBase64,
                                    ),
                                  ),
                                );
                                if (result != null && result is Map) {
                                  setState(() {
                                    if (result['user'] != null) {
                                      _currentUser = result['user'];
                                      if (widget.onUserUpdated != null) {
                                        widget.onUserUpdated!(_currentUser);
                                      }
                                    }
                                    if (result['image'] != null) {
                                      _profileImageBase64 = result['image'];
                                      if (widget.onImageUpdated != null) {
                                        widget.onImageUpdated!(_profileImageBase64);
                                      }
                                    }
                                  });
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 5),

                          _ProfileMenuCard(
                            backgroundColor: cardColor,
                            isDark: isDark,
                            child: _ProfileMenuTile(
                              icon: Icons.settings_outlined,
                              title: 'Account Setting',
                              subtitle: 'Manage your account preferences',
                              textColor: primaryText,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountSettingView(user: _currentUser),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 15),

                          _SectionHeading(
                            title: 'More',
                            textColor: primaryText,
                          ),
                          const SizedBox(height: 5),

                          _ProfileMenuCard(
                            backgroundColor: cardColor,
                            isDark: isDark,
                            child: _ProfileMenuTile(
                              icon: Icons.description_outlined,
                              title: 'Terms & Conditions',
                              subtitle: 'Read the terms of using this app',
                              textColor: primaryText,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TermsConditionView(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 5),

                          _ProfileMenuCard(
                            backgroundColor: cardColor,
                            isDark: isDark,
                            child: _ProfileMenuTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Learn how your data is handled',
                              textColor: primaryText,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PrivacyPolicyView(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 5),

                          _ProfileMenuCard(
                            backgroundColor: cardColor,
                            isDark: isDark,
                            child: _ProfileMenuTile(
                              icon: Icons.help_outline_rounded,
                              title: 'Help / Support',
                              subtitle: 'Get help with the application',
                              textColor: primaryText,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HelpSupportView(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 5),

                          _ProfileMenuCard(
                            backgroundColor: cardColor,
                            isDark: isDark,
                            child: _ProfileMenuTile(
                              icon: Icons.logout_rounded,
                              title: _isLoggingOut
                                  ? 'Logging Out...'
                                  : 'Log Out',
                              subtitle: 'Sign out of your account',
                              textColor: primaryText,
                              onTap: _logout,
                              isLogout: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Symmetrical curved bottom edge of the banner.
class ProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height * 0.62)
      ..cubicTo(
        width * 0.78,
        height * 0.90,
        width * 0.22,
        height * 0.90,
        0,
        height * 0.62,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant ProfileHeaderClipper oldClipper) {
    return false;
  }
}

// Fallback avatar when no profile photo is selected.
class _InitialAvatar extends StatelessWidget {
  final String initial;

  const _InitialAvatar({
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3FBE9),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Color(0xFF80C900),
        ),
      ),
    );
  }
}

// Section heading.
class _SectionHeading extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeading({
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }
}

// Individual menu card.
class _ProfileMenuCard extends StatelessWidget {
  final Color backgroundColor;
  final bool isDark;
  final Widget child;

  const _ProfileMenuCard({
    required this.backgroundColor,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : const Color(0xFFE8EDE3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Menu row with a green icon background.
class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color textColor;
  final bool isLogout;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final iconBackground = isLogout
        ? (isDark
            ? const Color(0xFF402523)
            : const Color(0xFFFFF0ED))
        : (isDark
            ? const Color(0xFF293421)
            : const Color(0xFFF3FBE9));

    final iconColor =
        isLogout ? const Color(0xFFE65B4F) : const Color(0xFF80C900);

    final subtitleColor =
        isDark ? const Color(0xFFADB5A7) : const Color(0xFF788195);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 21,
                  color: iconColor,
                ),
              ),
              const _WidthSpacer(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLogout ? iconColor : textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.3,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: iconColor.withOpacity(0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidthSpacer extends StatelessWidget {
  final double width;
  const _WidthSpacer({required this.width});

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
