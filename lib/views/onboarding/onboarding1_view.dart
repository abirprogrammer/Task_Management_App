
import 'package:flutter/material.dart';

import 'onboarding2_view.dart';

class OnboardingView1 extends StatelessWidget {
  const OnboardingView1({super.key});

  static const Color green = Color(0xFF80C400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onSkip: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingView2(),
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
                          'assets/images/onbinding_img1.png',
                          width: 280,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Text(
                      'Manage Everything in One Place',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171923),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create, categorize, and keep track of all your personal '
                          'and work tasks effortlessly — right from your dashboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.55,
                        color: Color(0xFF737987),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _PageIndicator(current: 0),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
            _BottomButton(
              text: 'Next',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingView2(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _OnboardingHeader({
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 22),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSkip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: OnboardingView1.green,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int current;

  const _PageIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: current == index ? 23 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: current == index
                ? OnboardingView1.green
                : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _BottomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 48),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: OnboardingView1.green,
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
    );
  }
}
