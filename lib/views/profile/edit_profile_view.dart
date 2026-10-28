import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/user_model.dart';
import '../../utils/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;
  final String? profileImageBase64;

  const EditProfileView({
    super.key,
    required this.user,
    this.profileImageBase64,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  String? _imageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _addressController = TextEditingController(text: widget.user.address);
    _imageBase64 = widget.profileImageBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null || !mounted) return;

    try {
      final bytes = await File(pickedFile.path).readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: $e')),
      );
    }
  }

  void _saveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update profile details in database
      final response = await ApiService.updateProfile(widget.user.id, name, email, address);

      // Upload image if changed
      if (_imageBase64 != null && _imageBase64 != widget.profileImageBase64) {
        await ApiService.uploadProfileImage(widget.user.id, _imageBase64!);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success'] == true) {
        UserModel updatedUser = UserModel(
          id: widget.user.id,
          name: name,
          email: email,
          address: address,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, {'user': updatedUser, 'image': _imageBase64});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']?.toString() ?? 'Failed to update profile.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U';

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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        backgroundImage: _imageBase64 != null
                            ? MemoryImage(base64Decode(_imageBase64!))
                            : null,
                        child: _imageBase64 == null
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
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Full Name", style: AppStyles.heading3),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nameController,
              hintText: "Enter full name",
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Email Address", style: AppStyles.heading3),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: "Enter email address",
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Address", style: AppStyles.heading3),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _addressController,
              hintText: "Enter your address",
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 36),
            CustomButton(
              text: "Save Changes",
              onPressed: _saveChanges,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
