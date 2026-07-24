import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/router/app_router.dart';

/// Onboarding screen — Sprint 10 will build the full 4-screen flow.
/// Sprint 1 stub sets the onboarding_complete flag so routing works.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _complete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (context.mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuraSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AuraColors.accentLime,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AuraColors.orbGlow, blurRadius: 28, spreadRadius: 8),
                  ],
                ),
                child: Center(child: Text('A', style: AuraTypography.orbLabel.copyWith(fontSize: 28))),
              ),
              const SizedBox(height: AuraSpacing.xl),
              Text('AURA', style: AuraTypography.display),
              const SizedBox(height: AuraSpacing.sm),
              Text('AI-Unified Reality Assistant', style: AuraTypography.body),
              const SizedBox(height: AuraSpacing.xl2),
              Text(
                'One tap. You speak.\nLife organizes itself.',
                textAlign: TextAlign.center,
                style: AuraTypography.sectionHeader,
              ),
              const SizedBox(height: AuraSpacing.xl2),
              ElevatedButton(
                onPressed: () => _complete(context),
                child: const Text('GET STARTED'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
