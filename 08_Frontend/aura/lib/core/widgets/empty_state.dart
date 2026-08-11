import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// Reusable Neubrutalist Empty State Component for AURA
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
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(AuraSpacing.shadowOffset, AuraSpacing.shadowOffset),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: AuraColors.accentLime,
                ),
              ),
            ),
            const SizedBox(height: AuraSpacing.lg),
            Text(
              title,
              style: AuraTypography.sectionHeader,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.sm),
            Text(
              subtitle,
              style: AuraTypography.body,
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
