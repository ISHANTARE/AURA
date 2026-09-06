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

  Color _parseColor(String hex) =>
      hexToColor(hex, fallback: AuraColors.accentLime);

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
    final onActiveColor = ThemeData.estimateBrightnessForColor(activeColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AuraColors.elevatedOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          border: Border.all(color: AuraColors.borderOf(context), width: 1.5),
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
                        color: AuraColors.textPrimaryOf(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(AuraIcons.close,
                          color: AuraColors.textPrimaryOf(context)),
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
                  style: AuraTypography.bodyMedium.copyWith(color: AuraColors.textPrimaryOf(context)),
                  decoration: InputDecoration(
                    hintText: 'e.g. VIT Academics, GATE Prep…',
                    hintStyle: AuraTypography.bodySmall
                        .copyWith(color: AuraColors.textDisabled),
                    filled: true,
                    fillColor: AuraColors.cardOf(context),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AuraColors.borderOf(context), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AuraColors.accentRed, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                            horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor
                              : AuraColors.cardOf(context),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelected
                                ? activeColor
                                : AuraColors.borderOf(context),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              opt.icon,
                              size: AuraIcons.sizeStandard,
                              color: isSelected
                                  ? onActiveColor
                                  : AuraColors.textPrimaryOf(context),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              opt.label,
                              style: AuraTypography.bodySmall.copyWith(
                                color: isSelected
                                    ? onActiveColor
                                    : AuraColors.textPrimaryOf(context),
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
                    final isDarkSwatch = ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColorHex = hex),
                      child: Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                : AuraColors.borderOf(context),
                            width: isSelected ? 3.0 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.45),
                                    blurRadius: 8.0,
                                    spreadRadius: 1.0,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                AuraIcons.done,
                                size: AuraIcons.sizeInline,
                                color: isDarkSwatch ? Colors.white : Colors.black,
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
                    color: AuraColors.cardOf(context),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                        color: AuraColors.borderOf(context), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AuraColors.isDarkMode(context)
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, 4),
                        blurRadius: 12.0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.0),
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
                              style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimaryOf(context)),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'TASKS: 0   EVENTS: 0',
                              style: AuraTypography.bentoMetricLabel.copyWith(
                                  color: AuraColors.textSecondaryOf(context),
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
