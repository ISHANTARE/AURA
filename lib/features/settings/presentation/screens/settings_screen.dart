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

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/core/security/secret_store.dart';
import 'package:aura/core/theme/theme_provider.dart';
import 'package:aura/core/providers/providers.dart';
import 'package:aura/platform/overlay_channel.dart';
import 'package:aura/features/reminders/data/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _userNameController = TextEditingController(text: 'Ishan T');
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  static const String _defaultProviderPreset = 'Google Gemini (Recommended)';
  String _selectedProviderPreset = _defaultProviderPreset;
  String _selectedReminderDefault = '1 day & 6 hours before';

  /// '' ⇒ follow the device locale (recognizer default).
  String _selectedVoiceLocale = '';

  int _selectedBriefingHour = 7;
  static const List<(String, String)> _voiceLocales = [
    ('', 'Device default'),
    ('en-US', 'English (US)'),
    ('en-GB', 'English (UK)'),
    ('en-IN', 'English (India)'),
    ('hi-IN', 'Hindi'),
    ('es-ES', 'Spanish'),
    ('fr-FR', 'French'),
    ('de-DE', 'German'),
    ('pt-BR', 'Portuguese (Brazil)'),
    ('ar-SA', 'Arabic'),
    ('ja-JP', 'Japanese'),
    ('ko-KR', 'Korean'),
    ('zh-CN', 'Chinese (Mandarin)'),
  ];

  String _selectedAlarmSound = 'System Alarm';
  String _selectedNotificationSound = 'Soft Chime';
  bool _obscureKey = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await SecretStore().readApiKey();
    setState(() {
      _userNameController.text = prefs.getString('USER_NAME') ?? '';
      _apiKeyController.text = apiKey;
      _baseUrlController.text = prefs.getString('LLM_BASE_URL') ?? 'https://generativelanguage.googleapis.com/v1beta/openai/';
      _modelController.text = prefs.getString('LLM_MODEL') ?? 'gemini-2.0-flash';
      _selectedReminderDefault = prefs.getString('REMINDER_DEFAULT') ?? '1 day & 6 hours before';
      _selectedVoiceLocale = prefs.getString('VOICE_LOCALE') ?? '';
      _selectedBriefingHour = prefs.getInt('BRIEFING_HOUR') ?? 7;
      _selectedProviderPreset =
          prefs.getString('LLM_PROVIDER_PRESET') ?? _defaultProviderPreset;
      _selectedAlarmSound = prefs.getString('ALARM_SOUND') ?? 'System Alarm';
      _selectedNotificationSound = prefs.getString('NOTIF_SOUND') ?? 'Soft Chime';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final newName = _userNameController.text.trim();
    await ref.read(userNameProvider.notifier).setName(newName);
    final prefs = await SharedPreferences.getInstance();
    // API key goes to encrypted storage, never plaintext prefs.
    await SecretStore().writeApiKey(_apiKeyController.text.trim());
    await prefs.setString('LLM_BASE_URL', _baseUrlController.text.trim());
    await prefs.setString('LLM_MODEL', _modelController.text.trim());
    await prefs.setString('REMINDER_DEFAULT', _selectedReminderDefault);
    await prefs.setString('VOICE_LOCALE', _selectedVoiceLocale);
    await prefs.setString('LLM_PROVIDER_PRESET', _selectedProviderPreset);
    await prefs.setString('ALARM_SOUND', _selectedAlarmSound);
    await prefs.setString('NOTIF_SOUND', _selectedNotificationSound);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  List<String> _getQuickModelSuggestions() {
    if (_selectedProviderPreset.startsWith('Google Gemini')) {
      return ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];
    } else if (_selectedProviderPreset == 'NVIDIA NIM') {
      return [
        'meta/llama-3.3-70b-instruct',
        'nvidia/nemotron-4-340b-instruct',
        'mistralai/mixtral-8x7b-instruct',
        'deepseek-ai/deepseek-r1',
      ];
    } else if (_selectedProviderPreset == 'Groq Cloud') {
      return ['llama-3.3-70b-versatile', 'llama3-70b-8192', 'mixtral-8x7b-32768'];
    } else if (_selectedProviderPreset == 'OpenRouter') {
      return ['google/gemini-2.0-flash-001', 'anthropic/claude-3.5-haiku', 'meta-llama/llama-3.3-70b-instruct'];
    } else if (_selectedProviderPreset == 'Local LLM (Ollama / LM Studio)') {
      return ['llama3.2', 'qwen2.5:3b', 'mistral'];
    }
    return ['meta/llama-3.3-70b-instruct', 'gemini-2.0-flash', 'llama3.2'];
  }

  @override
  Widget build(BuildContext context) {
    final activeAccent = ref.watch(themeAccentProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AuraColors.bgBase,
        appBar: AppBar(backgroundColor: AuraColors.bgBase, title: Text('SETTINGS', style: AuraTypography.screenHeader)),
        body: Center(child: CircularProgressIndicator(color: activeAccent.color)),
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
            // ── Section 1: User Profile ─────────────────────────────────────
            const _SettingsSectionHeader(title: 'USER PROFILE'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: activeAccent.color,
                        child: Text(
                          _userNameController.text.isNotEmpty
                              ? _userNameController.text[0].toUpperCase()
                              : 'A',
                          style: AuraTypography.orbLabel.copyWith(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DISPLAY NAME', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _userNameController,
                              style: AuraTypography.cardTitle,
                              onChanged: (val) {
                                setState(() {});
                                final trimmed = val.trim();
                                if (trimmed.isNotEmpty) {
                                  ref.read(userNameProvider.notifier).setName(trimmed);
                                }
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                filled: true,
                                fillColor: AuraColors.bgElevated,
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 2: Color Theme Accent ──────────────────────────────
            const _SettingsSectionHeader(title: 'COLOR THEME ACCENT'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ThemeAccent.values.map((accent) {
                  final isSelected = activeAccent == accent;
                  return GestureDetector(
                    onTap: () {
                      ref.read(themeAccentProvider.notifier).setAccent(accent);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AuraColors.border : Colors.transparent,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(LucideIcons.check, size: 20, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(accent.label.split(' ').first, style: AuraTypography.badgeText),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Floating Orb Control ──────────────────────────────────────────
            const _SettingsSectionHeader(title: 'FLOATING ASSISTANT ORB'),
            const SizedBox(height: 12),

            FutureBuilder<bool>(
              future: OverlayChannel.isRunning(),
              builder: (context, snapshot) {
                final isRunning = snapshot.data ?? false;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    border: Border.all(color: AuraColors.border, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('System Floating Orb', style: AuraTypography.cardTitle),
                          const SizedBox(height: 4),
                          Text(
                            isRunning ? 'Active on screen' : 'Inactive / Dismissed',
                            style: AuraTypography.bodySmall.copyWith(
                              color: isRunning ? activeAccent.color : AuraColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRunning ? AuraColors.bgElevated : activeAccent.color,
                          foregroundColor: isRunning ? AuraColors.textPrimary : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (isRunning) {
                            await OverlayChannel.stopOverlay();
                          } else {
                            final granted = await OverlayChannel.isPermissionGranted();
                            if (!granted) {
                              await OverlayChannel.requestPermission();
                            } else {
                              await OverlayChannel.startOverlay();
                            }
                          }
                          setState(() {});
                        },
                        child: Text(isRunning ? 'HIDE ORB' : 'SHOW ORB'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Section 3: Sound & Ringtone Settings ────────────────────────
            const _SettingsSectionHeader(title: 'SOUNDS & RINGTONES'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alarm Ringtone', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedAlarmSound,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'System Alarm', child: Text('System Alarm (Loud Ringing)')),
                      DropdownMenuItem(value: 'Radar', child: Text('Radar Chime')),
                      DropdownMenuItem(value: 'Beacon', child: Text('Beacon Alert')),
                      DropdownMenuItem(value: 'Beep', child: Text('Digital Beep')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAlarmSound = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  Text('Notification Sound', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedNotificationSound,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Soft Chime', child: Text('Soft Chime')),
                      DropdownMenuItem(value: 'Crystal', child: Text('Crystal Bell')),
                      DropdownMenuItem(value: 'Pop', child: Text('Subtle Pop')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedNotificationSound = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 4: Editable Reminder Defaults ───────────────────────
            const _SettingsSectionHeader(title: 'REMINDER DEFAULTS'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Default Task Reminder', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedReminderDefault,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1 day & 6 hours before', child: Text('1 day & 6 hours before deadline')),
                      DropdownMenuItem(value: '2 hours before', child: Text('2 hours before deadline')),
                      DropdownMenuItem(value: '1 hour before', child: Text('1 hour before deadline')),
                      DropdownMenuItem(value: '15 minutes before', child: Text('15 minutes before deadline')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedReminderDefault = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 4a: Briefing Time ──────────────────────────────────
            const _SettingsSectionHeader(title: 'MORNING BRIEFING'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Briefing hour', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: _selectedBriefingHour,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5:00 AM')),
                      DropdownMenuItem(value: 6, child: Text('6:00 AM')),
                      DropdownMenuItem(value: 7, child: Text('7:00 AM')),
                      DropdownMenuItem(value: 8, child: Text('8:00 AM')),
                      DropdownMenuItem(value: 9, child: Text('9:00 AM')),
                      DropdownMenuItem(value: 10, child: Text('10:00 AM')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _selectedBriefingHour = val);
                      // Persist immediately; the scheduler reads it daily.
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setInt('BRIEFING_HOUR', val);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A summary notification with your top focus item.',
                    style: AuraTypography.label.copyWith(color: AuraColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 4b: Voice Input Language ────────────────────────────
            const _SettingsSectionHeader(title: 'VOICE INPUT LANGUAGE'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Speech recognition language', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedVoiceLocale,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: _voiceLocales
                        .map((locale) => DropdownMenuItem(
                              value: locale.$1,
                              child: Text(locale.$2),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedVoiceLocale = val ?? '');
                      // Persist immediately so the next capture uses it.
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('VOICE_LOCALE', _selectedVoiceLocale);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“Device default” follows your phone’s language.',
                    style: AuraTypography.label.copyWith(color: AuraColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 5: AI Engine & LLM API ──────────────────────────────
            const _SettingsSectionHeader(title: 'AI ENGINE & LLM API'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Provider Preset (Auto-fill)',
                      style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedProviderPreset,
                    dropdownColor: AuraColors.bgElevated,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Google Gemini (Recommended)',
                        child: Text('Google Gemini (Recommended)'),
                      ),
                      DropdownMenuItem(
                        value: 'NVIDIA NIM',
                        child: Text('NVIDIA NIM'),
                      ),
                      DropdownMenuItem(
                        value: 'Groq Cloud',
                        child: Text('Groq Cloud (Superfast)'),
                      ),
                      DropdownMenuItem(
                        value: 'OpenRouter',
                        child: Text('OpenRouter (Universal Gateway)'),
                      ),
                      DropdownMenuItem(
                        value: 'Local LLM (Ollama / LM Studio)',
                        child: Text('Local LLM (Ollama / PC Server)'),
                      ),
                      DropdownMenuItem(
                        value: 'Custom / Other Provider',
                        child: Text('Custom Provider'),
                      ),
                    ],
                    onChanged: (preset) {
                      if (preset == null) return;
                      setState(() {
                        _selectedProviderPreset = preset;
                        if (preset == 'Google Gemini (Recommended)') {
                          _baseUrlController.text = 'https://generativelanguage.googleapis.com/v1beta/openai/';
                          _modelController.text = 'gemini-2.0-flash';
                        } else if (preset == 'NVIDIA NIM') {
                          _baseUrlController.text = 'https://integrate.api.nvidia.com/v1';
                          _modelController.text = 'meta/llama-3.3-70b-instruct';
                        } else if (preset == 'Groq Cloud') {
                          _baseUrlController.text = 'https://api.groq.com/openai/v1';
                          _modelController.text = 'llama-3.3-70b-versatile';
                        } else if (preset == 'OpenRouter') {
                          _baseUrlController.text = 'https://openrouter.ai/api/v1';
                          _modelController.text = 'google/gemini-2.0-flash-001';
                        } else if (preset == 'Local LLM (Ollama / LM Studio)') {
                          _baseUrlController.text = 'http://10.0.2.2:11434/v1';
                          _modelController.text = 'llama3.2';
                        }
                      });
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
                      hintText: 'e.g. https://integrate.api.nvidia.com/v1',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Model Target (Editable)', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _modelController,
                    style: AuraTypography.bodyPrimary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AuraColors.bgElevated,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AuraColors.border)),
                      hintText: 'e.g. meta/llama-3.3-70b-instruct or nvidia/nemotron-4-340b-instruct',
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text('Quick Model Suggestions:', style: AuraTypography.caption.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _getQuickModelSuggestions().map((m) {
                      final isSelected = _modelController.text.trim() == m;
                      return ChoiceChip(
                        label: Text(m, style: AuraTypography.bodySmall.copyWith(
                          color: isSelected ? Colors.white : AuraColors.textPrimary,
                          fontSize: 11,
                        )),
                        selected: isSelected,
                        selectedColor: activeAccent.color,
                        backgroundColor: AuraColors.bgElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: isSelected ? activeAccent.color : AuraColors.border),
                        ),
                        onSelected: (_) {
                          setState(() => _modelController.text = m);
                        },
                      );
                    }).toList(),
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
                      hintText: 'Paste API Key (nvapi-..., gsk_..., etc.)',
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
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeAccent.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'SAVE ALL SETTINGS',
                        style: AuraTypography.buttonText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 6: Workspaces & Archiving ────────────────────────────
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Archived Workspaces', style: AuraTypography.cardTitle),
                            Text('${archived.length}', style: AuraTypography.badgeText.copyWith(color: activeAccent.color)),
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
                                  child: Text('RESTORE', style: AuraTypography.labelLime.copyWith(color: activeAccent.color)),
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

            // ── Section 7: Data Management ──────────────────────────────────
            const _SettingsSectionHeader(title: 'DATA MANAGEMENT'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                border: Border.all(color: AuraColors.border, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.download, color: AuraColors.accentBlue),
                    title: Text('Export App Data', style: AuraTypography.cardTitle),
                    subtitle: Text('Export local SQLite database to JSON file', style: AuraTypography.bodySmall),
                    onTap: () async {
                      try {
                        // Fetch data from both DAOs
                        final allItems = await ref.read(itemDaoProvider).watchAllActive().first;
                        final allWorkspaces = await ref.read(workspaceDaoProvider).getAll();

                        final exportMap = {
                          'exportedAt': DateTime.now().toIso8601String(),
                          'version': 1,
                          'items': allItems.map((i) => {
                            'id': i.id,
                            'title': i.title,
                            'category': i.category,
                            'kind': i.kind,
                            'status': i.status,
                            'notes': i.notes,
                            'priority': i.priority,
                            'workspaceId': i.workspaceId,
                            'deadline': i.deadline,
                            'fireAt': i.fireAt,
                            'createdAt': i.createdAt,
                            'updatedAt': i.updatedAt,
                          }).toList(),
                          'workspaces': allWorkspaces.map((w) => {
                            'id': w.id,
                            'name': w.name,
                            'colorHex': w.colorHex,
                            'iconKey': w.iconKey,
                            'createdAt': w.createdAt,
                          }).toList(),
                        };

                        final dir = await getApplicationDocumentsDirectory();
                        final ts = DateTime.now().millisecondsSinceEpoch;
                        final file = File('${dir.path}/aura_export_$ts.json');
                        await file.writeAsString(jsonEncode(exportMap));

                        await Share.shareXFiles(
                          [XFile(file.path)],
                          text: 'AURA Data Export — ${DateTime.now().toLocal()}',
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Export failed: $e')),
                          );
                        }
                      }
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
                        // 0. Cancel all scheduled system notifications & alarms
                        await NotificationService().cancelAll();

                        // 1. Wipe all SQLite tables in FK-safe order
                        final db = ref.read(databaseProvider);
                        await db.customStatement('DELETE FROM reminders_schedule');
                        await db.customStatement('DELETE FROM notes');
                        await db.customStatement('DELETE FROM shared_contents');
                        await db.customStatement('DELETE FROM notification_logs');
                        await db.customStatement('DELETE FROM ai_actions_logs');
                        await db.customStatement('DELETE FROM offline_queues');
                        await db.customStatement('DELETE FROM daily_logs');
                        await db.customStatement('DELETE FROM sync_queues');
                        await db.customStatement('DELETE FROM items');
                        await db.customStatement('DELETE FROM workspace_sections');
                        await db.customStatement('DELETE FROM workspaces');

                        // 2. Clear native orb prefs (position/color/dismissed
                        // survived a full reset before).
                        try {
                          await OverlayChannel.clearNativePrefs();
                        } catch (e) {
                          debugPrint('Reset: native prefs clear failed: $e');
                        }

                        // 3. Clear SharedPreferences + the stored API key.
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        try {
                          await const FlutterSecureStorage()
                              .deleteAll();
                        } catch (_) {
                          // Secure storage unavailable — nothing to scrub.
                        }

                        // 4. Invalidate live providers so no stale state
                        // (accent, name, gate) survives into onboarding.
                        await ref
                            .read(themeAccentProvider.notifier)
                            .resetToDefault();
                        ref.read(userNameProvider.notifier).reset();
                        await ref.read(onboardingGateProvider.notifier).reset();

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
      style: AuraTypography.label.copyWith(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
        fontSize: 11,
      ),
    );
  }
}
