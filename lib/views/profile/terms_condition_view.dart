import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class TermsConditionView extends StatelessWidget {
  const TermsConditionView({super.key});

  @override
  Widget build(BuildContext context) {
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
          AppStrings.termsAndConditionsTitle,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: _buildFormattedContent(AppStrings.termsAndConditionsContent),
        ),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    final lines = content.split('\n');
    List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Check if line is a numbered heading (e.g. "1. Use of the App") or main title
      bool isNumberedHeading = RegExp(r'^\d+\.\s+').hasMatch(line);
      bool isMainTitle = i == 0 || (i == 1 && !lines[0].contains('1.'));

      double fontSize = isMainTitle ? 15 : (isNumberedHeading ? 15 : 14);
      FontWeight fontWeight = (isMainTitle || isNumberedHeading) ? FontWeight.w600 : FontWeight.w400;
      Color textColor = (isMainTitle || isNumberedHeading) ? AppColors.textPrimary : AppColors.textSecondary;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: (isMainTitle || isNumberedHeading) ? 6 : 10),
          child: Text(
            line,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
