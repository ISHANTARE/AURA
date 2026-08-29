import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../platform/overlay_channel.dart';
import '../home/home_screen.dart' show userNameProvider;

// ── Settings Keys ─────────────────────────────────────────────────────────────

abstract final class SettingsKeys {
  static const userName = 'USER_NAME';
  static const themeMode = 'THEME_MODE';
  static const themeAccent = 'THEME_ACCENT';
  static const alarmSoundTitle = 'ALARM_SOUND_TITLE';
  static const alarmSoundUri = 'ALARM_SOUND_URI';
  static const notifSoundTitle = 'NOTIF_SOUND_TITLE';
  static const notifSoundUri = 'NOTIF_SOUND_URI';
  static const reminderDefault = 'REMINDER_DEFAULT';
  static const briefingHour = 'BRIEFING_HOUR';
  static const voiceLocale = 'VOICE_LOCALE';
  static const llmPreset = 'LLM_PROVIDER_PRESET';
  static const llmBaseUrl = 'LLM_BASE_URL';
  static const llmModel = 'LLM_MODEL';
  static const apiKey = 'apiKey';
}

final themeAccentProvider = StateProvider<String>((ref) => 'Indigo');

// ── Settings Screen ───────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _overlay = OverlayChannel();

  // Controllers
  final _nameController = TextEditingController();
  final _llmBaseUrlController = TextEditingController();
  final _llmModelController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _isApiKeyObscured = true;
  String _selectedAccent = 'Indigo';
  final String _selectedThemeMode = 'dark';
  final String _reminderDefault = '1 day & 6 hours before';
  int _briefingHour = 7;
  final String _voiceLocale = '';
  final String _llmPreset = 'Google Gemini (Recommended)';
  bool _isOrbActive = false;
  bool _isSaving = false;

  final _accents = [
    ('Indigo', 'Neon Indigo', 0xFF7B6FF0),
    ('Cyan', 'Cyber Cyan', 0xFF22D3EE),
    ('Purple', 'Electric Purple', 0xFFC084FC),
    ('Orange', 'Sunset Orange', 0xFFFF9966),
    ('Rose', 'Rose Gold', 0xFFF472B6),
    ('Lime', 'Acid Lime', 0xFFC8FF00),
  ];

  final _geminiModels = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _secureStorage.read(key: SettingsKeys.apiKey) ?? '';
    final orbRunning = await _overlay.isOverlayRunning();

    setState(() {
      _nameController.text = prefs.getString(SettingsKeys.userName) ?? ref.read(userNameProvider);
      _selectedAccent = prefs.getString(SettingsKeys.themeAccent) ?? 'Indigo';
      _briefingHour = prefs.getInt(SettingsKeys.briefingHour) ?? 7;
      _llmBaseUrlController.text = prefs.getString(SettingsKeys.llmBaseUrl) ?? 'https://generativelanguage.googleapis.com/v1beta/openai/';
      _llmModelController.text = prefs.getString(SettingsKeys.llmModel) ?? 'gemini-2.0-flash';
      _apiKeyController.text = key;
      _isOrbActive = orbRunning;
    });
  }

  Future<void> _saveAllSettings() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await prefs.setString(SettingsKeys.userName, name);
      ref.read(userNameProvider.notifier).state = name;
    }

    await prefs.setString(SettingsKeys.themeMode, _selectedThemeMode);
    await prefs.setString(SettingsKeys.themeAccent, _selectedAccent);
    ref.read(themeAccentProvider.notifier).state = _selectedAccent;

    await prefs.setString(SettingsKeys.reminderDefault, _reminderDefault);
    await prefs.setInt(SettingsKeys.briefingHour, _briefingHour);
    await prefs.setString(SettingsKeys.voiceLocale, _voiceLocale);
    await prefs.setString(SettingsKeys.llmPreset, _llmPreset);
    await prefs.setString(SettingsKeys.llmBaseUrl, _llmBaseUrlController.text.trim());
    await prefs.setString(SettingsKeys.llmModel, _llmModelController.text.trim());

    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      await _secureStorage.write(key: SettingsKeys.apiKey, value: apiKey);
    } else {
      await _secureStorage.delete(key: SettingsKeys.apiKey);
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _llmBaseUrlController.dispose();
    _llmModelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        title: Text('Settings', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textSecondary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpacing.md),
        children: [
          // 1. User Profile
          _buildSectionHeader('1. USER PROFILE', LucideIcons.user),
          BentoCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.15)),
                  child: Center(
                    child: Text(
                      _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A',
                      style: AuraTypography.cardTitle.copyWith(color: accent, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: AuraSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: TextStyle(color: AuraColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.md),

          // 2. Color Theme Accent & Mode
          _buildSectionHeader('2. COLOR THEME ACCENT', LucideIcons.palette),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _accents.map((acc) {
                    final isSelected = _selectedAccent == acc.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAccent = acc.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(acc.$3).withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AuraRadius.full),
                          border: Border.all(
                            color: isSelected ? Color(acc.$3) : AuraColors.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: Color(acc.$3), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              acc.$2,
                              style: AuraTypography.caption.copyWith(
                                color: isSelected ? Color(acc.$3) : AuraColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.md),

          // 3. Floating Assistant Orb
          _buildSectionHeader('3. FLOATING ASSISTANT ORB', LucideIcons.orbit),
          BentoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Floating Orb', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text(
                        _isOrbActive ? 'Active on screen' : 'Inactive / Hidden',
                        style: AuraTypography.caption.copyWith(color: _isOrbActive ? accent : AuraColors.textMuted),
                      ),
                    ],
                  ),
                ),
                AuraButton(
                  label: _isOrbActive ? 'HIDE ORB' : 'SHOW ORB',
                  variant: _isOrbActive ? AuraButtonVariant.destructive : AuraButtonVariant.outline,
                  onPressed: () async {
                    if (_isOrbActive) {
                      await _overlay.stopOverlay();
                    } else {
                      await _overlay.startOverlay();
                    }
                    final running = await _overlay.isOverlayRunning();
                    setState(() => _isOrbActive = running);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.md),

          // 4. Morning Briefing
          _buildSectionHeader('4. MORNING BRIEFING', LucideIcons.sunMedium),
          BentoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Briefing Delivery Hour', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text('Delivers daily plan overview at start of day', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                    ],
                  ),
                ),
                DropdownButton<int>(
                  value: _briefingHour,
                  dropdownColor: AuraColors.bgElevated,
                  style: AuraTypography.bodySmall.copyWith(color: accent, fontWeight: FontWeight.w700),
                  items: [5, 6, 7, 8, 9, 10].map((h) => DropdownMenuItem(value: h, child: Text('$h:00 AM'))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _briefingHour = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.md),

          // 5. AI Engine & LLM API
          _buildSectionHeader('5. AI ENGINE & LLM API', LucideIcons.sparkles),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Provider Preset', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                const SizedBox(height: 4),
                Text(_llmPreset, style: AuraTypography.bodySmall.copyWith(color: accent, fontWeight: FontWeight.w700)),
                const SizedBox(height: AuraSpacing.sm),

                TextField(
                  controller: _llmBaseUrlController,
                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Base URL',
                    labelStyle: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
                    filled: true,
                    fillColor: AuraColors.bgSubtle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
                  ),
                ),
                const SizedBox(height: AuraSpacing.sm),

                TextField(
                  controller: _llmModelController,
                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Model Target',
                    labelStyle: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
                    filled: true,
                    fillColor: AuraColors.bgSubtle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
                  ),
                ),
                const SizedBox(height: AuraSpacing.xs),

                Wrap(
                  spacing: 6,
                  children: _geminiModels.map((m) {
                    return ActionChip(
                      label: Text(m, style: AuraTypography.caption.copyWith(fontSize: 10)),
                      backgroundColor: AuraColors.bgSubtle,
                      onPressed: () => setState(() => _llmModelController.text = m),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AuraSpacing.sm),

                TextField(
                  controller: _apiKeyController,
                  obscureText: _isApiKeyObscured,
                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key',
                    labelStyle: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
                    filled: true,
                    fillColor: AuraColors.bgSubtle,
                    suffixIcon: IconButton(
                      icon: Icon(_isApiKeyObscured ? LucideIcons.eye : LucideIcons.eyeOff, size: 16, color: AuraColors.textMuted),
                      onPressed: () => setState(() => _isApiKeyObscured = !_isApiKeyObscured),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
                  ),
                ),
                const SizedBox(height: AuraSpacing.xs),
                Text('Get a free API key at Google AI Studio (aistudio.google.com)', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.md),

          // Save Button
          AuraButton(
            label: 'SAVE ALL SETTINGS',
            fullWidth: true,
            isLoading: _isSaving,
            onPressed: _saveAllSettings,
          ),
          const SizedBox(height: AuraSpacing.xl),

          // 6. Data Management
          _buildSectionHeader('6. DATA MANAGEMENT', LucideIcons.database),
          BentoCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.download, color: AuraColors.accentGreen),
                  title: Text('Export App Data', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Export SQLite database to JSON backup', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                  onTap: _exportData,
                ),
                const Divider(color: AuraColors.border),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.trash2, color: AuraColors.accentRed),
                  title: Text('Reset App Data', style: AuraTypography.bodySmall.copyWith(color: AuraColors.accentRed, fontWeight: FontWeight.w600)),
                  subtitle: Text('Wipe all local data and reset onboarding gate', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs, top: AuraSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AuraColors.textMuted),
          const SizedBox(width: 6),
          Text(
            title,
            style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final itemDao = ref.read(itemDaoProvider);
    final wsDao = ref.read(workspaceDaoProvider);
    final items = await itemDao.watchAllActive().first;
    final workspaces = await wsDao.watchAll().first;

    final exportJson = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'workspaces_count': workspaces.length,
      'items_count': items.length,
      'workspaces': workspaces.map((w) => {'id': w.id, 'name': w.name, 'color': w.colorHex}).toList(),
      'items': items.map((i) => {'id': i.id, 'title': i.title, 'status': i.status, 'category': i.category}).toList(),
    };

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/aura_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(exportJson));

    await Share.shareXFiles([XFile(file.path)], text: 'AURA Backup Export');
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgElevated,
        title: const Text('Reset All Data?', style: TextStyle(color: AuraColors.accentRed)),
        content: const Text('This will delete all tasks, notes, workspaces, and settings. This action cannot be undone.', style: TextStyle(color: AuraColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeReset();
            },
            child: const Text('RESET EVERYTHING', style: TextStyle(color: AuraColors.accentRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();

    await ref.read(onboardingGateProvider).reset();

    if (mounted) context.go(Routes.onboarding);
  }
}
