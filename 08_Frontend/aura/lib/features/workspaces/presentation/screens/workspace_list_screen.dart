import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/empty_state.dart';

/// Workspace List Screen — AURA v2 Workspaces Management
class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(workspacesListProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        title: Text('WORKSPACES', style: AuraTypography.screenHeader),
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
      ),
      body: workspacesAsync.when(
        data: (workspaces) {
          if (workspaces.isEmpty) {
            return const AuraEmptyState(
              icon: LucideIcons.layoutGrid,
              title: 'No Workspaces',
              subtitle: 'Workspaces organize your life into distinct contexts (e.g. Prep, VIT, Personal).',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AuraSpacing.md),
            itemCount: workspaces.length,
            separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
            itemBuilder: (context, index) {
              final ws = workspaces[index];
              return InkWell(
                onTap: () => context.push('/workspace/${ws.id}'),
                child: Container(
                  padding: const EdgeInsets.all(AuraSpacing.md),
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 36,
                        color: Color(int.tryParse(ws.colorHex.replaceFirst('#', '0xFF')) ?? 0xFFC8FF00),
                      ),
                      const SizedBox(width: AuraSpacing.md),
                      Expanded(
                        child: Text(ws.name, style: AuraTypography.cardTitle),
                      ),
                      const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
    );
  }
}
