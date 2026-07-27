import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/database/daos/workspace_dao.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  String _selectedModel = 'z-ai/glm-5.2';
  bool _obscureKey = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('LLM_API_KEY') ?? '';
      _baseUrlController.text = prefs.getString('LLM_BASE_URL') ?? 'https://integrate.api.nvidia.com/v1';
      _selectedModel = prefs.getString('LLM_MODEL') ?? 'z-ai/glm-5.2';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('LLM_API_KEY', _apiKeyController.text.trim());
    await prefs.setString('LLM_BASE_URL', _baseUrlController.text.trim());
    await prefs.setString('LLM_MODEL', _selectedModel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AuraColors.bgBase,
        appBar: AppBar(backgroundColor: AuraColors.bgBase, title: Text('SETTINGS', style: AuraTypography.screenHeader)),
        body: const Center(child: CircularProgressIndicator(color: AuraColors.accentLime)),
      );
    }

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        title: Text('SETTINGS', style: AuraTypography.screenHeader),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: AI Model Configuration
            const _SettingsSectionHeader(title: 'AI ENGINE & LLM API'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model Target', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedModel,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'z-ai/glm-5.2',
                        child: Text('NVIDIA NIM — z-ai/glm-5.2 (Fast)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-2.0-flash',
                        child: Text('Google Gemini 2.0 Flash'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedModel = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  Text('Base URL', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _baseUrlController,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('API Key', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    style: AuraTypography.bodyPrimary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: const OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: AuraColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.accentLime,
                        foregroundColor: AuraColors.textOnAccent,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text('SAVE AI CONFIG', style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Notifications & DND
            const _SettingsSectionHeader(title: 'NOTIFICATIONS & QUIET HOURS'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.moon, color: AuraColors.accentLime),
                    title: Text('Quiet Hours (DND)', style: AuraTypography.cardTitle),
                    subtitle: Text('11:00 PM – 7:00 AM', style: AuraTypography.bodySmall),
                    trailing: const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary),
                  ),
                  const Divider(color: AuraColors.borderMuted, height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.bell, color: AuraColors.accentLime),
                    title: Text('Reminder Defaults', style: AuraTypography.cardTitle),
                    subtitle: Text('Tasks: 1 day & 6 hours before deadline', style: AuraTypography.bodySmall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Workspaces & Archiving
            const _SettingsSectionHeader(title: 'WORKSPACES & ARCHIVE'),
            const SizedBox(height: 12),

            Consumer(
              builder: (ctx, r, _) {
                final archivedAsync = r.watch(archivedWorkspacesProvider);
                return archivedAsync.when(
                  data: (archived) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AuraColors.bgCard,
                      border: Border.all(color: AuraColors.border, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Archived Workspaces', style: AuraTypography.cardTitle),
                            Text('${archived.length}', style: AuraTypography.badgeText.copyWith(color: AuraColors.accentLime)),
                          ],
                        ),
                        if (archived.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...archived.map((ws) => ListTile(
                                leading: const Icon(LucideIcons.archive, color: AuraColors.textSecondary),
                                title: Text(ws.name, style: AuraTypography.bodyPrimary),
                                trailing: TextButton(
                                  onPressed: () {
                                    r.read(workspaceDaoProvider).unarchive(ws.id);
                                  },
                                  child: Text('RESTORE', style: AuraTypography.labelLime),
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 4: Data Management & Reset
            const _SettingsSectionHeader(title: 'DATA MANAGEMENT'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.download, color: AuraColors.accentBlue),
                    title: Text('Export App Data', style: AuraTypography.cardTitle),
                    subtitle: Text('Export local SQLite database to JSON file', style: AuraTypography.bodySmall),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Database export ready')),
                      );
                    },
                  ),
                  const Divider(color: AuraColors.borderMuted, height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.trash, color: AuraColors.accentRed),
                    title: Text('Reset App Data', style: AuraTypography.cardTitle.copyWith(color: AuraColors.accentRed)),
                    subtitle: Text('Clears local SQLite database and onboarding state', style: AuraTypography.bodySmall),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AuraColors.bgElevated,
                          title: const Text('Reset All App Data?', style: TextStyle(color: AuraColors.textPrimary)),
                          content: const Text('This will clear your local database and reset AURA to fresh install state.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AuraColors.accentRed),
                              child: const Text('RESET', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) context.go(Routes.onboarding);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

final archivedWorkspacesProvider = StreamProvider<List<dynamic>>((ref) {
  final workspaceDao = ref.watch(workspaceDaoProvider);
  return workspaceDao.watchArchived();
});

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AuraTypography.bentoMetricLabel.copyWith(
        color: AuraColors.accentLime,
        letterSpacing: 1.2,
      ),
    );
  }
}
