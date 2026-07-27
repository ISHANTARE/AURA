import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../domain/entities/intent_result.dart';
import '../providers/capture_provider.dart';

/// Dedicated Confirmation Card for Deletion Actions (Sprint 8)
class DeleteConfirmationCard extends ConsumerWidget {
  final IntentResult intent;

  const DeleteConfirmationCard({super.key, required this.intent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetName = intent.targetName ?? intent.title ?? 'Item';
    final isWorkspace = intent.intentType == 'delete_workspace';

    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.accentRed, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red Header Banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AuraColors.accentRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AuraColors.accentRed, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.trash2, size: 14, color: AuraColors.accentRed),
                    const SizedBox(width: 6),
                    Text(
                      isWorkspace ? 'DELETE WORKSPACE' : 'DELETE TASK',
                      style: AuraTypography.label.copyWith(
                        color: AuraColors.accentRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await ref.read(captureProvider.notifier).cancelCapture();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: AuraSpacing.md),

          // Target Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AuraSpacing.md),
            decoration: BoxDecoration(
              color: AuraColors.bgElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AuraColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AURA will remove:',
                  style: AuraTypography.overline.copyWith(color: AuraColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  targetName,
                  style: AuraTypography.cardTitle.copyWith(color: AuraColors.accentRed),
                ),
              ],
            ),
          ),

          const SizedBox(height: AuraSpacing.lg),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuraColors.accentRed,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(captureProvider.notifier).confirmAndSave();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'CONFIRM DELETE',
                      style: AuraTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AuraSpacing.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: AuraColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await ref.read(captureProvider.notifier).cancelCapture();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text('CANCEL', style: AuraTypography.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
