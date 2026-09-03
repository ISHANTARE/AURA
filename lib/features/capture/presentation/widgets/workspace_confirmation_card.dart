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

/// Dedicated Confirmation Card for Workspace Creation (Sprint 8)
class WorkspaceConfirmationCard extends ConsumerStatefulWidget {
  final IntentResult intent;

  const WorkspaceConfirmationCard({super.key, required this.intent});

  @override
  ConsumerState<WorkspaceConfirmationCard> createState() =>
      _WorkspaceConfirmationCardState();
}

class _WorkspaceConfirmationCardState
    extends ConsumerState<WorkspaceConfirmationCard> {
  late TextEditingController _nameController;
  late String _selectedColor;

  static const List<String> _presetColors = [
    '#6C63FF', // Purple
    '#22C55E', // Green
    '#F59E0B', // Amber
    '#3B82F6', // Blue
    '#EF4444', // Red
    '#C8FF00', // Lime
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.intent.title ?? '');
    _selectedColor = widget.intent.workspaceColorHex ?? '#6C63FF';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        border: Border.all(color: AuraColors.borderOf(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action Badge Header
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
                    Icon(LucideIcons.folderPlus, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'CREATE WORKSPACE',
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

          // Workspace Name Input
          Text('Workspace Name', style: AuraTypography.overline),
          const SizedBox(height: AuraSpacing.xs),
          TextField(
            controller: _nameController,
            style: AuraTypography.cardTitle,
            decoration: InputDecoration(
              hintText: 'Workspace name...',
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

          // Color Swatch Selector
          Text('Workspace Accent Color', style: AuraTypography.overline),
          const SizedBox(height: AuraSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presetColors.map((colorHex) {
              final isSelected = _selectedColor == colorHex;
              final color = hexToColor(colorHex, fallback: AuraColors.accentLime);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedColor = colorHex);
                  ref.read(captureProvider.notifier).updateIntent(
                        widget.intent.copyWith(workspaceColorHex: colorHex),
                      );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(LucideIcons.check, size: 18, color: Colors.black)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AuraSpacing.lg),

          // Confirm Button
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
                'CREATE WORKSPACE NOW',
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
