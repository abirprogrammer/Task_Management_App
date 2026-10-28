import 'package:flutter/material.dart';
import 'onboarding2_view.dart';
import '../auth/login_view.dart';

class OnboardingView3 extends StatelessWidget {
  const OnboardingView3({super.key});

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
                          builder: (_) => const OnboardingView2(),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 22),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _finishOnboarding(context),
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
                          'assets/images/onbinding_img3.png',
                          width: 280,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Text(
                      'Visualize Progress, Stay on Track',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171923),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Monitor completed tasks, ongoing projects, and '
                          'upcoming deadlines — all in a clear, visual format.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.55,
                        color: Color(0xFF737987),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _Dots3(),
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
                  onPressed: () => _finishOnboarding(context),
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
                        'Continue',
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

  static void _finishOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }
}

class _Dots3 extends StatelessWidget {
  const _Dots3();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == 2 ? 23 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == 2 ? const Color(0xFF80C400) : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
