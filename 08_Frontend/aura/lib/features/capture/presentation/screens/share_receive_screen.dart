import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/database/daos/shared_content_dao.dart';
import 'package:aura/platform/share_channel.dart';
import '../../domain/usecases/process_shared_content_usecase.dart';

import '../widgets/voice_capture_overlay.dart';

final shareChannelProvider = Provider<ShareChannel>((ref) => ShareChannel());

final processSharedContentUseCaseProvider = Provider<ProcessSharedContentUseCase>((ref) {
  return ProcessSharedContentUseCase(
    sharedContentDao: ref.watch(sharedContentDaoProvider),
  );
});

class ShareReceiveScreen extends ConsumerStatefulWidget {
  const ShareReceiveScreen({super.key});

  @override
  ConsumerState<ShareReceiveScreen> createState() => _ShareReceiveScreenState();
}

class _ShareReceiveScreenState extends ConsumerState<ShareReceiveScreen> {
  final TextEditingController _instructionController = TextEditingController();
  ProcessedShareResult? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndProcessPayload();
  }

  Future<void> _fetchAndProcessPayload() async {
    final payload = await ref.read(shareChannelProvider).getInitialSharePayload();
    if (payload != null) {
      final processed = await ref.read(processSharedContentUseCaseProvider).execute(payload);
      if (mounted) {
        setState(() {
          _result = processed;
          _isLoading = false;
        });
        // Auto-trigger voice capture modal immediately upon receiving share payload
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) VoiceCaptureOverlay.show(context);
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AuraColors.accentLime),
              SizedBox(height: 16),
              Text('Analyzing shared content...', style: TextStyle(color: AuraColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_result == null) {
      return Scaffold(
        backgroundColor: AuraColors.bgBase,
        appBar: AppBar(backgroundColor: AuraColors.bgBase),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.share2, color: AuraColors.textDisabled, size: 48),
              const SizedBox(height: 16),
              Text('No shared payload detected', style: AuraTypography.body),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(Routes.home),
                style: ElevatedButton.styleFrom(backgroundColor: AuraColors.accentLime),
                child: Text('GO TO HOME', style: AuraTypography.buttonText),
              ),
            ],
          ),
        ),
      );
    }

    final res = _result!;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AuraColors.textPrimary),
          onPressed: () => context.go(Routes.home),
        ),
        title: Text('SHARED TO AURA', style: AuraTypography.screenHeader),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AuraColors.bgCard,
                  border: Border.all(color: AuraColors.border, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          res.imagePath != null
                              ? LucideIcons.image
                              : (res.url != null ? LucideIcons.link : LucideIcons.fileText),
                          color: AuraColors.accentLime,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            res.title,
                            style: AuraTypography.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Image preview if available
                    if (res.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.file(
                          File(res.imagePath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Extracted OCR text or link summary
                    if (res.extractedText.isNotEmpty) ...[
                      Text('EXTRACTED CONTENT', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        res.extractedText,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AuraTypography.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instruction Field
              Text('WHAT SHOULD AURA DO WITH THIS?', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.accentLime)),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionController,
                autofocus: true,
                maxLines: 2,
                style: AuraTypography.bodyPrimary,
                decoration: const InputDecoration(
                  hintText: 'e.g. "Remind me to read this paper tomorrow at 10 AM"',
                  hintStyle: TextStyle(color: AuraColors.textDisabled),
                  filled: true,
                  fillColor: AuraColors.bgCard,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AuraColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AuraColors.accentLime, width: 2),
                  ),
                ),
              ),
              const Spacer(),

              // Action CTA Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task created from shared content!')),
                    );
                    context.go(Routes.home);
                  },
                  icon: const Icon(LucideIcons.check, size: 18, color: AuraColors.textOnAccent),
                  label: Text('CONFIRM & SAVE TASK', style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.accentLime,
                    foregroundColor: AuraColors.textOnAccent,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
