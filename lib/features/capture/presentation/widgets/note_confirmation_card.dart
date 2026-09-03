import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../domain/entities/intent_result.dart';
import '../providers/capture_provider.dart';
import 'voice_capture_overlay.dart';

/// Dedicated Confirmation Card for Plain Notes (Sprint 8)
class NoteConfirmationCard extends ConsumerStatefulWidget {
  final IntentResult intent;

  const NoteConfirmationCard({super.key, required this.intent});

  @override
  ConsumerState<NoteConfirmationCard> createState() =>
      _NoteConfirmationCardState();
}

class _NoteConfirmationCardState extends ConsumerState<NoteConfirmationCard> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.intent.title ?? '');
    _notesController = TextEditingController(text: widget.intent.notes ?? widget.intent.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.borderOf(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.fileText, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'ADD NOTE',
                      style: AuraTypography.label.copyWith(
                        color: primaryColor,
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
                  if (context.mounted) VoiceCaptureOverlay.closeOverlay(context);
                },
                child: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: AuraSpacing.md),

          // Title
          Text('Title / Topic', style: AuraTypography.overline),
          const SizedBox(height: AuraSpacing.xs),
          TextField(
            controller: _titleController,
            style: AuraTypography.cardTitle,
            decoration: InputDecoration(
              hintText: 'Note title...',
              filled: true,
              fillColor: AuraColors.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AuraColors.border),
              ),
            ),
            onChanged: (val) {
              ref.read(captureProvider.notifier).updateIntent(
                    widget.intent.copyWith(title: val),
                  );
            },
          ),

          const SizedBox(height: AuraSpacing.md),

          // Full Body Text Editor
          Text('Full Note Details', style: AuraTypography.overline),
          const SizedBox(height: AuraSpacing.xs),
          TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            style: AuraTypography.bodyPrimary,
            decoration: InputDecoration(
              hintText: 'Spoken note details...',
              filled: true,
              fillColor: AuraColors.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AuraColors.border),
              ),
            ),
            onChanged: (val) {
              ref.read(captureProvider.notifier).updateIntent(
                    widget.intent.copyWith(notes: val),
                  );
            },
          ),

          const SizedBox(height: AuraSpacing.lg),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(captureProvider.notifier).confirmAndSave();
              },
              child: Text(
                'SAVE NOTE',
                style: AuraTypography.label.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
