import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';

/// Floating AURA orb button — draggable, always above bottom nav.
/// Per ADR-012 this is the ONLY element with glow effect.
class FloatingOrb extends StatefulWidget {
  const FloatingOrb({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _glowAnim;

  // Drag position (from bottom-center by default)
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final size = MediaQuery.sizeOf(context);
        setState(() {
          _position = Offset(
            size.width / 2 - AuraSpacing.orbSize / 2,
            size.height -
                AuraSpacing.bottomNavHeight -
                AuraSpacing.orbSize -
                AuraSpacing.md -
                MediaQuery.paddingOf(context).bottom,
          );
          _initialized = true;
        });
      });
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          final size = MediaQuery.sizeOf(context);
          final pad = MediaQuery.paddingOf(context);
          setState(() {
            _position = Offset(
              (_position.dx + details.delta.dx).clamp(
                  0, size.width - AuraSpacing.orbSize),
              (_position.dy + details.delta.dy).clamp(
                  pad.top,
                  size.height -
                      AuraSpacing.bottomNavHeight -
                      AuraSpacing.orbSize -
                      pad.bottom),
            );
          });
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) {
            return Transform.scale(
              scale: _isDragging ? 1.1 : _pulseAnim.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Atmospheric glow — THE ONLY GLOW in AURA
                  Container(
                    width: AuraSpacing.orbSize + 24,
                    height: AuraSpacing.orbSize + 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AuraColors.orbGlow
                              .withValues(alpha: _glowAnim.value * 0.08),
                          blurRadius: 28,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  // Orb body
                  Container(
                    width: AuraSpacing.orbSize,
                    height: AuraSpacing.orbSize,
                    decoration: BoxDecoration(
                      color: AuraColors.accentLime,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(
                            _isDragging ? 2 : 4,
                            _isDragging ? 2 : 4,
                          ),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('A', style: AuraTypography.orbLabel),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── BOTTOM NAV BAR ───────────────────────────────────────────────────────────

/// AURA bottom navigation bar — Neubrutalist style, Lucide icons.
class AuraBottomNav extends StatelessWidget {
  const AuraBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AuraColors.bgCard,
        border: Border(
          top: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AuraSpacing.bottomNavHeight,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              _NavItem(
                icon: Icons.access_alarm_outlined,
                label: 'Alarms',
                isSelected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              _NavItem(
                icon: Icons.dashboard_outlined,
                label: 'Workspaces',
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                label: 'Notes',
                isSelected: selectedIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: selectedIndex == 4,
                onTap: () => onDestinationSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AuraColors.accentLime : AuraColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AuraTypography.label.copyWith(
                color: isSelected
                    ? AuraColors.textPrimary
                    : AuraColors.textSecondary,
                letterSpacing: 0.4,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
