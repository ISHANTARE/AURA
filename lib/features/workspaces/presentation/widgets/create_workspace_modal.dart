import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/icons.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';
import '../providers/workspace_providers.dart';

/// Neubrutalist modal bottom sheet for creating or editing a Workspace.
/// Wireframe source: 04_workspace_screen.md — Create New Workspace Flow
class CreateWorkspaceModal extends ConsumerStatefulWidget {
  final Workspace? initialWorkspace;

  const CreateWorkspaceModal({super.key, this.initialWorkspace});

  static Future<void> show(BuildContext context, {Workspace? workspace}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateWorkspaceModal(initialWorkspace: workspace),
    );
  }

  @override
  ConsumerState<CreateWorkspaceModal> createState() =>
      _CreateWorkspaceModalState();
}

class _CreateWorkspaceModalState extends ConsumerState<CreateWorkspaceModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  // Icon options: key maps to AuraIcons.forWorkspace internally
  static const List<({String key, IconData icon, String label})> _iconOptions = [
    (key: 'college',   icon: AuraIcons.wsCollege,   label: 'College'),
    (key: 'gate',      icon: AuraIcons.wsGate,       label: 'GATE/IIT'),
    (key: 'work',      icon: AuraIcons.wsWork,        label: 'Work'),
    (key: 'personal',  icon: AuraIcons.wsPersonal,   label: 'Personal'),
    (key: 'health',    icon: AuraIcons.wsHealth,      label: 'Health'),
    (key: 'finance',   icon: AuraIcons.wsFinance,     label: 'Finance'),
    (key: 'projects',  icon: AuraIcons.wsProjects,   label: 'Projects'),
    (key: 'placement', icon: AuraIcons.wsPlacement,  label: 'Career'),
    (key: 'research',  icon: AuraIcons.wsResearch,   label: 'Research'),
    (key: 'custom',    icon: AuraIcons.wsCustom,      label: 'Folder'),
  ];

  static const List<String> _colorOptions = [
    '#C8FF00', // Lime (AURA primary)
    '#4DFFFF', // Cyan
    '#FF7A29', // Orange
    '#FF3B3B', // Red
    '#B57BFF', // Purple
    '#39FF88', // Green
    '#FFD600', // Yellow
  ];

  late String _selectedIconKey;
  late String _selectedColorHex;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialWorkspace?.name ?? '',
    );
    _selectedIconKey = widget.initialWorkspace?.iconKey ?? 'college';
    _selectedColorHex = widget.initialWorkspace?.colorHex ?? '#C8FF00';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AuraColors.accentLime;
    }
  }

  IconData _selectedIcon() {
    for (final opt in _iconOptions) {
      if (opt.key == _selectedIconKey) return opt.icon;
    }
    return AuraIcons.wsCustom;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final notifier = ref.read(workspaceActionNotifierProvider.notifier);
    final isEdit = widget.initialWorkspace != null;

    if (isEdit) {
      final success = await notifier.updateWorkspace(
        id: widget.initialWorkspace!.id,
        name: _nameController.text.trim(),
        iconKey: _selectedIconKey,
        colorHex: _selectedColorHex,
      );
      if (mounted && success) Navigator.of(context).pop();
    } else {
      final id = await notifier.createWorkspace(
        name: _nameController.text.trim(),
        iconKey: _selectedIconKey,
        colorHex: _selectedColorHex,
      );
      if (mounted && id != null) Navigator.of(context).pop();
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialWorkspace != null;
    final activeColor = _parseColor(_selectedColorHex);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AuraColors.bgElevated,
          border: Border(
            top:   BorderSide(color: AuraColors.border, width: 2.0),
            left:  BorderSide(color: AuraColors.border, width: 2.0),
            right: BorderSide(color: AuraColors.border, width: 2.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'EDIT WORKSPACE' : 'NEW WORKSPACE',
                      style: AuraTypography.cardTitle.copyWith(
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(AuraIcons.close,
                          color: AuraColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                // ── Name Input ───────────────────────────────────────────
                Text('WORKSPACE NAME', style: AuraTypography.badgeText),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  style: AuraTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'e.g. VIT Academics, GATE Prep…',
                    hintStyle: AuraTypography.bodySmall
                        .copyWith(color: AuraColors.textDisabled),
                    filled: true,
                    fillColor: AuraColors.bgCard,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AuraColors.border, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AuraColors.accentRed, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AuraColors.accentRed, width: 1.5),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a workspace name'
                      : null,
                ),

                const SizedBox(height: 20.0),

                // ── Icon Grid ────────────────────────────────────────────
                Text('ICON', style: AuraTypography.badgeText),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _iconOptions.map((opt) {
                    final isSelected = _selectedIconKey == opt.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIconKey = opt.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 7.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor
                              : AuraColors.bgCard,
                          border: Border.all(
                            color: isSelected
                                ? AuraColors.border
                                : AuraColors.borderMuted,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              opt.icon,
                              size: AuraIcons.sizeStandard,
                              color: isSelected
                                  ? AuraColors.textOnAccent
                                  : AuraColors.textPrimary,
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              opt.label,
                              style: AuraTypography.bodySmall.copyWith(
                                color: isSelected
                                    ? AuraColors.textOnAccent
                                    : AuraColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20.0),

                // ── Color Swatches ───────────────────────────────────────
                Text('ACCENT COLOR', style: AuraTypography.badgeText),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _colorOptions.map((hex) {
                    final color = _parseColor(hex);
                    final isSelected = _selectedColorHex == hex;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColorHex = hex),
                      child: Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: isSelected
                                ? AuraColors.border
                                : Colors.transparent,
                            width: 3.0,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                AuraIcons.done,
                                size: AuraIcons.sizeInline,
                                color: AuraColors.textOnAccent,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24.0),

                // ── Live Preview ─────────────────────────────────────────
                Text('PREVIEW', style: AuraTypography.badgeText),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    border: Border.all(
                        color: AuraColors.border, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: AuraColors.shadow,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.15),
                          border: Border.all(color: activeColor, width: 1.5),
                        ),
                        child: Icon(_selectedIcon(),
                            color: activeColor,
                            size: AuraIcons.sizeStandard),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.trim().isEmpty
                                  ? 'Workspace Name'
                                  : _nameController.text.trim(),
                              style: AuraTypography.cardTitle,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'TASKS: 0   EVENTS: 0',
                              style: AuraTypography.bentoMetricLabel.copyWith(
                                  color: AuraColors.textSecondary,
                                  fontSize: 10.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28.0),

                // ── Submit CTA ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AuraColors.textOnAccent,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEdit ? 'SAVE CHANGES' : 'CREATE WORKSPACE',
                            style: AuraTypography.buttonText,
                          ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
