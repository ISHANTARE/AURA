import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/spacing.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/providers/providers.dart';
import 'package:aura/core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController(text: 'Ishant');
  int _currentPage = 0;

  // Selected workspaces for Screen 3
  final Set<String> _selectedWorkspaces = {'VIT', 'GATE Prep'};

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref.read(userNameProvider.notifier).setName(name);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go(Routes.home);
  }

  void _nextPage() {
    if (_currentPage == 0) {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        ref.read(userNameProvider.notifier).setName(name);
      }
    }
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(4, (index) {
                      final isSelected = _currentPage == index;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AuraColors.accentLime : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AuraColors.accentLime : AuraColors.borderMuted,
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text('Skip →', style: AuraTypography.bodySmall),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildWelcomeSlide(),
                  _buildPermissionsSlide(),
                  _buildWorkspacesSlide(),
                  _buildTryItNowSlide(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 1: Welcome
  Widget _buildWelcomeSlide() {
    return SingleChildScrollView(
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
              child: Center(
                child: Text('A', style: AuraTypography.orbLabel.copyWith(fontSize: 28)),
              ),
            ),
            const SizedBox(height: AuraSpacing.xl),
            Text('AURA', style: AuraTypography.display),
            const SizedBox(height: AuraSpacing.sm),
            Text('AI-Unified Reality Assistant', style: AuraTypography.body),
            const SizedBox(height: AuraSpacing.lg),
            Text(
              'One tap. You speak.\nLife organizes itself.',
              textAlign: TextAlign.center,
              style: AuraTypography.sectionHeader,
            ),
            const SizedBox(height: AuraSpacing.xl),

            // Name Input Field
            Container(
              padding: const EdgeInsets.all(AuraSpacing.md),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AuraColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What should AURA call you?',
                    style: AuraTypography.label.copyWith(color: AuraColors.accentLime, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: AuraTypography.cardTitle,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: AuraTypography.body,
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AuraColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuraSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AuraColors.accentLime,
                  foregroundColor: AuraColors.textOnAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'GET STARTED →',
                  style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 2: Permissions
  Widget _buildPermissionsSlide() {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.shieldCheck, size: 48, color: AuraColors.accentLime),
          const SizedBox(height: 16),
          Text('Permissions for AURA', style: AuraTypography.display.copyWith(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            'AURA works as a voice assistant. To unlock its full power, please grant permissions below.',
            style: AuraTypography.bodySmall,
          ),
          const SizedBox(height: 32),

          _PermissionItem(
            icon: LucideIcons.layers,
            title: 'Floating Orb Overlay',
            desc: 'Allows the AURA orb to float above all apps.',
            onRequest: () async {
              await Permission.systemAlertWindow.request();
            },
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            icon: LucideIcons.mic,
            title: 'Microphone Access',
            desc: 'Required for real-time voice capture.',
            onRequest: () async {
              await Permission.microphone.request();
            },
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            icon: LucideIcons.bell,
            title: 'Notifications & Alarms',
            desc: 'Ensures deadlines and reminders fire on time.',
            onRequest: () async {
              await Permission.notification.request();
            },
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.accentLime,
                foregroundColor: AuraColors.textOnAccent,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'CONTINUE →',
                style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: First Workspaces
  Widget _buildWorkspacesSlide() {
    const suggestions = ['VIT', 'GATE Prep', 'Internship', 'Personal', 'Health', 'Placements'];

    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you working on?', style: AuraTypography.display.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            'Select your initial workspaces. You can add or rename more anytime.',
            style: AuraTypography.bodySmall,
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: suggestions.map((ws) {
              final isSelected = _selectedWorkspaces.contains(ws);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedWorkspaces.remove(ws);
                    } else {
                      _selectedWorkspaces.add(ws);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AuraColors.accentLime : AuraColors.bgCard,
                    border: Border.all(
                      color: isSelected ? AuraColors.accentLime : AuraColors.border,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    ws,
                    style: AuraTypography.badgeText.copyWith(
                      color: isSelected ? AuraColors.textOnAccent : AuraColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedWorkspaces.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.accentLime,
                foregroundColor: AuraColors.textOnAccent,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'CONTINUE →',
                style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 4: Try It Now
  Widget _buildTryItNowSlide() {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You\'re all set.', style: AuraTypography.display),
          const SizedBox(height: 8),
          Text(
            'Try AURA now by tapping the orb below and speaking your first thought.',
            textAlign: TextAlign.center,
            style: AuraTypography.bodySmall,
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuraColors.bgCard,
              border: Border.all(color: AuraColors.accentLime, width: 2),
            ),
            child: Text(
              '"ML assignment due Friday 11:59 PM, remind me 1 day before."',
              textAlign: TextAlign.center,
              style: AuraTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 40),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AuraColors.accentLime,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: AuraColors.orbGlow, blurRadius: 24, spreadRadius: 6),
              ],
            ),
            child: Center(
              child: Text('A', style: AuraTypography.orbLabel.copyWith(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Tap orb to speak', style: AuraTypography.bodySmall),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.accentLime,
                foregroundColor: AuraColors.textOnAccent,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'OPEN AURA →',
                style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onRequest;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        border: Border.all(color: AuraColors.borderMuted, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AuraColors.accentLime, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AuraTypography.cardTitle),
                Text(desc, style: AuraTypography.bodySmall),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onRequest,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AuraColors.accentLime),
            ),
            child: Text('GRANT', style: AuraTypography.badgeText.copyWith(color: AuraColors.accentLime)),
          ),
        ],
      ),
    );
  }
}
