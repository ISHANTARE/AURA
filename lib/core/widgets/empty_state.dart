import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// Reusable Theme-Aware Empty State Component for AURA
class AuraEmptyState extends StatelessWidget {
  const AuraEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = LucideIcons.sparkles,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cardBg = AuraColors.cardOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);
    final textSecondary = AuraColors.textSecondaryOf(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = AuraColors.isDarkMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AuraColors.shadow : AuraColors.lightShadow,
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AuraSpacing.lg),
            Text(
              title,
              style: AuraTypography.sectionHeader.copyWith(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.sm),
            Text(
              subtitle,
              style: AuraTypography.body.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AuraSpacing.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
