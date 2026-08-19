import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/icons.dart';
import '../../../../core/constants/typography.dart';
import '../../domain/entities/workspace_models.dart';

/// Soft dark workspace card for Workspace List Screen.
class WorkspaceCard extends StatefulWidget {
  final WorkspaceWithStats item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WorkspaceCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<WorkspaceCard> {
  bool _isPressed = false;

  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return AuraColors.accentLime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = widget.item.workspace;
    final iconColor = _parseColor(ws.colorHex);
    final iconData = AuraIcons.forWorkspace(ws.name);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AuraColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? Colors.transparent
                  : AuraColors.shadow,
              blurRadius: _isPressed ? 0 : 12,
              offset: _isPressed ? Offset.zero : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon + Workspace Name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    size: AuraIcons.sizeStandard,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    ws.name,
                    style: AuraTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),
            const Divider(color: AuraColors.borderMuted, height: 1.0),
            const SizedBox(height: 8.0),

            // Stats row: TASKS: N  EVENTS: N
            Text(
              'TASKS: ${widget.item.activeTaskCount}   EVENTS: ${widget.item.eventCount}',
              style: AuraTypography.bentoMetricLabel.copyWith(
                color: AuraColors.textSecondary,
                fontSize: 10.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6.0),

            // Preview or Overdue Warning
            if (widget.item.overdueCount > 0)
              Row(
                children: [
                  const Icon(
                    AuraIcons.overdue,
                    size: AuraIcons.sizeInline,
                    color: AuraColors.accentRed,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      '${widget.item.overdueCount} overdue',
                      style: AuraTypography.badgeText.copyWith(
                        color: AuraColors.accentRed,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              Text(
                widget.item.previewText ?? 'Tap to view',
                style: AuraTypography.bodySmall.copyWith(
                  color: AuraColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
