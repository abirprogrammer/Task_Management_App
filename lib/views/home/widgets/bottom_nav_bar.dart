import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import '../../../constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final MotionTabBarController controller;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.controller,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MotionTabBar(
      controller: controller,
      initialSelectedTab: "Home",
      labels: const ["Home", "Add Task", "Profile"],
      icons: const [Icons.home_outlined, Icons.add, Icons.person_outline],
      tabSize: 50,
      tabBarColor: AppColors.surface,
      tabIconColor: AppColors.textSecondary,
      tabSelectedColor: AppColors.primary,
      tabIconSelectedColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      onTabItemSelected: onTabSelected,
    );
  }
}
