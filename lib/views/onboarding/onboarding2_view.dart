
import 'package:flutter/material.dart';

import 'onboarding1_view.dart';
import 'onboarding3_view.dart';


class OnboardingView2 extends StatelessWidget {
  const OnboardingView2({super.key});

  static const Color green = Color(0xFF80C400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingView1(),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 22),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingView3(),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Image.asset(
                          'assets/images/onbinding_img2.png',
                          width: 280,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Text(
                      'Focus on What Matters Most',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171923),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Set priorities, add deadlines, and sort tasks by '
                          'importance so you can tackle what truly moves you '
                          'forward.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.55,
                        color: Color(0xFF737987),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _Dots2(),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 48),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingView3(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded, size: 13),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots2 extends StatelessWidget {
  const _Dots2();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == 1 ? 23 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == 1 ? const Color(0xFF80C400) : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
