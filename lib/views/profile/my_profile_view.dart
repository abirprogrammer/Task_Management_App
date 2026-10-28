import 'dart:convert';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/user_model.dart';
import 'edit_profile_view.dart';

class MyProfileView extends StatefulWidget {
  final UserModel user;
  final String? profileImageBase64;

  const MyProfileView({
    super.key,
    required this.user,
    this.profileImageBase64,
  });

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  late UserModel _currentUser;
  String? _currentImageBase64;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentImageBase64 = widget.profileImageBase64;
  }

  @override
  Widget build(BuildContext context) {
    final initial = _currentUser.name.trim().isNotEmpty
        ? _currentUser.name.trim()[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5FCEC),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
              onPressed: () => Navigator.pop(context, {'user': _currentUser, 'image': _currentImageBase64}),
            ),
          ),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5FCEC),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileView(
                        user: _currentUser,
                        profileImageBase64: _currentImageBase64,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      if (result['user'] != null) {
                        _currentUser = result['user'];
                      }
                      if (result['image'] != null) {
                        _currentImageBase64 = result['image'];
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Centered Avatar matching screenshot
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  backgroundImage: _currentImageBase64 != null
                      ? MemoryImage(base64Decode(_currentImageBase64!))
                      : null,
                  child: _currentImageBase64 == null
                      ? Text(
                          initial,
                          style: AppStyles.heading1.copyWith(
                            color: AppColors.primary,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _currentUser.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 30),

            // Info Card 1: Name matching screenshot
            _buildInfoCard(
              icon: Icons.person_outline_rounded,
              value: _currentUser.name,
            ),
            const SizedBox(height: 14),

            // Info Card 2: Email matching screenshot
            _buildInfoCard(
              icon: Icons.alternate_email_rounded,
              value: _currentUser.email,
            ),
            const SizedBox(height: 14),

            // Info Card 3: Address matching screenshot
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              value: _currentUser.address.isNotEmpty ? _currentUser.address : 'No address provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Container(
            height: 22,
            width: 1.5,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
