import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';
import '../../../platform/overlay_channel.dart';

// ── Seed workspaces after onboarding ─────────────────────────────────────────

final _seedWorkspaces = [
  ('College', '#C8FF00', 'book'),
  ('Academics', '#00D4FF', 'graduationCap'),
  ('Personal', '#FF6B6B', 'user'),
  ('Work', '#A78BFA', 'briefcase'),
  ('IIT Prep', '#34D399', 'code'),
];

const _accentPalette = ['#C8FF00', '#00D4FF', '#FF6B6B', '#A78BFA', '#34D399', '#FBBF24'];

// ── Onboarding Screen ─────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Slide 1
  final _nameController = TextEditingController(text: '');
  String _nameError = '';

  // Slide 2: permissions
  bool _micGranted = false;
  bool _notifsGranted = false;
  bool _overlayGranted = false;

  // Slide 3: workspace selection
  final Set<String> _selectedWorkspaces = {'College', 'Academics'};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final mic = await Permission.microphone.isGranted;
    final notif = await Permission.notification.isGranted;
    final overlay = await OverlayChannel().checkOverlayPermission();
    if (mounted) setState(() { _micGranted = mic; _notifsGranted = notif; _overlayGranted = overlay; });
  }

  void _nextPage() {
    if (_currentPage == 0) {
      final name = _nameController.text.trim();
      if (name.length < 2 || name.toLowerCase() == 'your name') {
        setState(() => _nameError = 'Please enter a valid name (2+ characters)');
        return;
      }
      setState(() => _nameError = '');
      SharedPreferences.getInstance().then((p) => p.setString('USER_NAME', name));
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    final dao = ref.read(workspaceDaoProvider);
    final uuid = const Uuid();
    var colorIndex = 0;

    for (final ws in _seedWorkspaces) {
      if (!_selectedWorkspaces.contains(ws.$1)) continue;
      final color = _accentPalette[colorIndex % _accentPalette.length];
      colorIndex++;
      await dao.insertWorkspace(WorkspacesCompanion.insert(
        id: uuid.v4(),
        name: ws.$1,
        colorHex: drift.Value(color),
        iconKey: drift.Value(ws.$3),
        sortOrder: drift.Value(colorIndex),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    await ref.read(onboardingGateProvider).complete();
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: Row(
                children: [
                  ...List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: i == _currentPage ? accent : AuraColors.border,
                      borderRadius: BorderRadius.circular(AuraRadius.full),
                    ),
                  )),
                  const Spacer(),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: _finish,
                      child: Text('Skip', style: AuraTypography.body.copyWith(color: AuraColors.textMuted)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _Slide1Welcome(controller: _nameController, error: _nameError),
                  _Slide2Permissions(
                    micGranted: _micGranted,
                    notifsGranted: _notifsGranted,
                    overlayGranted: _overlayGranted,
                    onRefresh: _checkPermissions,
                  ),
                  _Slide3Workspaces(
                    selected: _selectedWorkspaces,
                    onToggle: (name) => setState(() {
                      if (_selectedWorkspaces.contains(name)) {
                        _selectedWorkspaces.remove(name);
                      } else {
                        _selectedWorkspaces.add(name);
                      }
                    }),
                  ),
                  _Slide4TryIt(onFinish: _finish),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: AuraButton(
                label: _currentPage == 3 ? 'GET STARTED →' : 'CONTINUE →',
                fullWidth: true,
                onPressed: _currentPage == 3 ? _finish : _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide 1: Welcome & Name ───────────────────────────────────────────────────

class _Slide1Welcome extends StatelessWidget {
  final TextEditingController controller;
  final String error;
  const _Slide1Welcome({required this.controller, required this.error});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PulsingOrb(color: accent),
          const SizedBox(height: AuraSpacing.lg),
          Text('AURA',
              style: AuraTypography.display.copyWith(color: accent, letterSpacing: 6)),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'AI-Unified Reality Assistant',
            style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'One tap. You speak. Life organizes.',
            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AuraSpacing.xl),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What should AURA call you?',
                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary)),
                const SizedBox(height: AuraSpacing.sm),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Your name...',
                    hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: AuraSpacing.xs),
                  Text(error, style: AuraTypography.caption.copyWith(color: AuraColors.accentRed)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 2: Permissions ──────────────────────────────────────────────────────

class _Slide2Permissions extends StatelessWidget {
  final bool micGranted;
  final bool notifsGranted;
  final bool overlayGranted;
  final VoidCallback onRefresh;

  const _Slide2Permissions({
    required this.micGranted,
    required this.notifsGranted,
    required this.overlayGranted,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Up Permissions', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
          const SizedBox(height: AuraSpacing.xs),
          Text('Required for the full AURA experience', style: AuraTypography.body.copyWith(color: AuraColors.textSecondary)),
          const SizedBox(height: AuraSpacing.lg),
          _PermissionCard(
            icon: LucideIcons.mic,
            title: 'Microphone Access',
            subtitle: 'Required for on-device voice capture and speech recognition.',
            granted: micGranted,
            onRequest: () async {
              await Permission.microphone.request();
              onRefresh();
            },
          ),
          const SizedBox(height: AuraSpacing.sm),
          _PermissionCard(
            icon: LucideIcons.bell,
            title: 'Notifications & Alarms',
            subtitle: 'Required for high-priority reminders and exact wake-up alarms.',
            granted: notifsGranted,
            onRequest: () async {
              await Permission.notification.request();
              onRefresh();
            },
          ),
          const SizedBox(height: AuraSpacing.sm),
          _PermissionCard(
            icon: LucideIcons.orbit,
            title: 'Floating Orb (Draw Over Apps)',
            subtitle: 'Displays the floating assistant orb over other apps.',
            granted: overlayGranted,
            onRequest: () async {
              await OverlayChannel().requestOverlayPermission();
              onRefresh();
            },
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onRequest;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return BentoCard(
      borderColor: granted ? AuraColors.accentGreen.withOpacity(0.4) : AuraColors.border,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (granted ? AuraColors.accentGreen : accent).withOpacity(0.12),
              borderRadius: BorderRadius.circular(AuraRadius.sm),
            ),
            child: Icon(icon, size: 18, color: granted ? AuraColors.accentGreen : accent),
          ),
          const SizedBox(width: AuraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                Text(subtitle, style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: AuraSpacing.sm),
          granted
              ? const Icon(LucideIcons.checkCircle2, size: 20, color: AuraColors.accentGreen)
              : GestureDetector(
                  onTap: onRequest,
                  child: Text('GRANT', style: AuraTypography.caption.copyWith(color: accent, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
    );
  }
}

// ── Slide 3: Workspace Seeding ────────────────────────────────────────────────

class _Slide3Workspaces extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _Slide3Workspaces({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Your Workspaces', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
          const SizedBox(height: AuraSpacing.xs),
          Text('Select areas you want AURA to organize', style: AuraTypography.body.copyWith(color: AuraColors.textSecondary)),
          const SizedBox(height: AuraSpacing.lg),
          Wrap(
            spacing: AuraSpacing.sm,
            runSpacing: AuraSpacing.sm,
            children: _seedWorkspaces.map((ws) {
              final isSelected = selected.contains(ws.$1);
              return AuraChip(
                label: ws.$1,
                selected: isSelected,
                onTap: () => onToggle(ws.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: AuraSpacing.lg),
          Text(
            'You can always add, edit, or archive workspaces later.',
            style: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Slide 4: Try It ───────────────────────────────────────────────────────────

class _Slide4TryIt extends StatelessWidget {
  final VoidCallback onFinish;
  const _Slide4TryIt({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PulsingOrb(color: accent),
          const SizedBox(height: AuraSpacing.lg),
          Text("You're all set!", style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
          const SizedBox(height: AuraSpacing.md),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Orb Quick Guide', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: AuraSpacing.sm),
                const _TipRow(icon: LucideIcons.touchpad, text: 'Single tap → Instant voice capture'),
                const SizedBox(height: AuraSpacing.xs),
                const _TipRow(icon: LucideIcons.timer, text: 'Hold 600ms → Quick actions menu'),
                const SizedBox(height: AuraSpacing.xs),
                const _TipRow(icon: LucideIcons.moveHorizontal, text: 'Drag to move, releases snap to edge'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 14, color: accent),
        const SizedBox(width: AuraSpacing.sm),
        Expanded(child: Text(text, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary))),
      ],
    );
  }
}

// ── Pulsing Orb Widget ────────────────────────────────────────────────────────

class _PulsingOrb extends StatefulWidget {
  final Color color;
  const _PulsingOrb({required this.color});

  @override
  State<_PulsingOrb> createState() => _PulsingOrbState();
}

class _PulsingOrbState extends State<_PulsingOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [widget.color, widget.color.withOpacity(0.5)],
          ),
          boxShadow: [
            BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 32, spreadRadius: 8),
          ],
        ),
      ),
    );
  }
}
