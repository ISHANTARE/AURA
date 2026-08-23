import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../platform/speech_channel.dart';
import '../../data/datasources/llm_api_datasource.dart';
import '../../domain/entities/capture_state.dart';
import '../../domain/entities/intent_result.dart';
import '../../domain/entities/workspace_match_result.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/execute_ai_action_usecase.dart';
import '../../domain/usecases/queue_offline_transcript_usecase.dart';
import '../../domain/usecases/workspace_router_usecase.dart';

/// SharedPreferences key holding an optional BCP-47 voice-locale override
/// (Settings → Voice). Null/unset ⇒ follow the device's default locale.
const String kVoiceLocalePrefKey = 'VOICE_LOCALE';

final speechChannelProvider = Provider<SpeechChannel>((ref) {
  final channel = SpeechChannel();
  ref.onDispose(channel.dispose);
  return channel;
});

final llmApiDataSourceProvider = Provider<LlmApiDataSource>((ref) {
  return LlmApiDataSource();
});

final workspaceRouterUseCaseProvider = Provider<WorkspaceRouterUseCase>((ref) {
  return WorkspaceRouterUseCase();
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return CreateTaskUseCase(db);
});

final queueOfflineTranscriptUseCaseProvider =
    Provider<QueueOfflineTranscriptUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return QueueOfflineTranscriptUseCase(db);
});

final executeAiActionUseCaseProvider = Provider<ExecuteAiActionUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return ExecuteAiActionUseCase(db);
});

final captureProvider =
    StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final speechChannel = ref.watch(speechChannelProvider);
  final llmDataSource = ref.watch(llmApiDataSourceProvider);
  final workspaceRouter = ref.watch(workspaceRouterUseCaseProvider);
  final executeAiActionUseCase = ref.watch(executeAiActionUseCaseProvider);
  final queueOfflineUseCase = ref.watch(queueOfflineTranscriptUseCaseProvider);
  final db = ref.watch(databaseProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return CaptureNotifier(
    speechChannel: speechChannel,
    llmDataSource: llmDataSource,
    workspaceRouter: workspaceRouter,
    executeAiActionUseCase: executeAiActionUseCase,
    queueOfflineUseCase: queueOfflineUseCase,
    db: db,
    connectivityService: connectivityService,
  );
});

class CaptureNotifier extends StateNotifier<CaptureState> {
  final SpeechChannel _speechChannel;
  final LlmApiDataSource _llmDataSource;
  final WorkspaceRouterUseCase _workspaceRouter;
  final ExecuteAiActionUseCase _executeAiActionUseCase;
  final QueueOfflineTranscriptUseCase _queueOfflineUseCase;
  final AppDatabase _db;
  final ConnectivityService _connectivityService;

  StreamSubscription<String>? _transcriptSub;
  StreamSubscription<double>? _audioLevelSub;
  StreamSubscription<String>? _stateSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<String>? _finalTranscriptSub;

  /// Highest-accuracy result delivered by the native recognizer's
  /// onResults callback; preferred over partials at processing time.
  String? _lastFinalTranscript;

  Timer? _silenceTimer;

  CaptureNotifier({
    required SpeechChannel speechChannel,
    required LlmApiDataSource llmDataSource,
    required WorkspaceRouterUseCase workspaceRouter,
    required ExecuteAiActionUseCase executeAiActionUseCase,
    required QueueOfflineTranscriptUseCase queueOfflineUseCase,
    required AppDatabase db,
    required ConnectivityService connectivityService,
  })  : _speechChannel = speechChannel,
        _llmDataSource = llmDataSource,
        _workspaceRouter = workspaceRouter,
        _executeAiActionUseCase = executeAiActionUseCase,
        _queueOfflineUseCase = queueOfflineUseCase,
        _db = db,
        _connectivityService = connectivityService,
        super(const CaptureState());

  /// Start voice capture flow.
  Future<void> startCapture() async {
    state = const CaptureState(status: CaptureStatus.starting);

    await _cancelSubscriptions();

    _transcriptSub =
        _speechChannel.partialTranscriptStream.listen(_onPartialTranscript);
    _finalTranscriptSub =
        _speechChannel.finalTranscriptStream.listen(_onFinalTranscript);
    _audioLevelSub =
        _speechChannel.audioLevelStream.listen(_onAudioLevel);
    _stateSub = _speechChannel.speechStateStream.listen(_onSpeechState);
    _errorSub = _speechChannel.errorStream.listen(_onError);

    // Optional user override; null ⇒ recognizer follows the device locale.
    final prefs = await SharedPreferences.getInstance();
    final localeId = prefs.getString(kVoiceLocalePrefKey);

    final success = await _speechChannel.startListening(localeId: localeId);
    if (success) {
      state = state.copyWith(status: CaptureStatus.listening);
      _resetSilenceTimer();
    } else {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: 'Microphone or Speech Recognizer unavailable',
      );
    }
  }

  void _onFinalTranscript(String text) {
    if (text.isEmpty) return;
    _lastFinalTranscript = text;
    if (state.transcript != text) {
      state = state.copyWith(transcript: text);
    }
    _resetSilenceTimer();
  }

  void _onPartialTranscript(String text) {
    if (text.isEmpty) return;
    state = state.copyWith(transcript: text);
    _resetSilenceTimer();
  }

  void _onAudioLevel(double level) {
    state = state.copyWith(audioLevel: level);
  }

  void _onSpeechState(String speechState) {
    if (speechState == 'autoStopped') {
      if (state.status == CaptureStatus.listening) {
        stopAndProcess();
      }
    }
  }

  void _onError(String errorMsg) {
    state = state.copyWith(
      status: CaptureStatus.error,
      errorMessage: errorMsg,
    );
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 2500), () {
      if (state.status == CaptureStatus.listening &&
          state.transcript.trim().isNotEmpty) {
        stopAndProcess();
      }
    });
  }

  /// Stop listening and transition to AI processing state.
  Future<void> stopAndProcess() async {
    _silenceTimer?.cancel();
    await _speechChannel.stopListening();

    // Prefer the recognizer's final result over the last partial — give it a
    // short grace window to arrive, then fall back to what we have.
    var transcriptText = state.transcript.trim();
    if (_lastFinalTranscript == null) {
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (_lastFinalTranscript != null &&
            _lastFinalTranscript!.trim().isNotEmpty) {
          break;
        }
      }
    }
    final finalText = _lastFinalTranscript?.trim();
    if (finalText != null && finalText.isNotEmpty) {
      transcriptText = finalText;
      state = state.copyWith(transcript: transcriptText);
    }
    _lastFinalTranscript = null;

    if (transcriptText.isEmpty) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage:
            "No speech detected. Try speaking clearly or type manually.",
      );
      return;
    }

    state = state.copyWith(status: CaptureStatus.processing);

    // Probe connectivity at the decision point (never trust a stale snapshot).
    final isOnline = await _connectivityService.isOnline();

    // If device is offline, queue to local DB offline_queue
    if (!isOnline) {
      try {
        await _queueOfflineUseCase.execute(transcriptText);
        state = state.copyWith(
          status: CaptureStatus.savedSuccess,
          isOfflineSaved: true,
        );
      } catch (e) {
        state = state.copyWith(
          status: CaptureStatus.error,
          errorMessage: "Offline queue error: $e",
        );
      }
      return;
    }

    // Device is online: send transcript to the configured LLM provider
    try {
      final existingWorkspaces = await _db.workspaceDao.getAll();
      final workspaceNames = existingWorkspaces.map((w) => w.name).toList();

      final outcome = await _llmDataSource.extractIntentWithMeta(
        transcript: transcriptText,
        userWorkspaces: workspaceNames,
      );

      final workspaceMatch = _workspaceRouter.routeWorkspace(
        workspaceHint: outcome.result.workspaceHint,
        existingWorkspaces: existingWorkspaces,
      );

      state = state.copyWith(
        status: CaptureStatus.confirming,
        intentResult: outcome.result,
        workspaceMatch: workspaceMatch,
        aiNotice: outcome.fallbackNotice,
        clearAiNotice: outcome.fallbackNotice == null,
        hardError: false,
      );
    } on LlmApiException catch (e) {
      // Config-level AI failure (bad key / dead model): never mask it —
      // surface an actionable error instead of silently degrading.
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: e.message,
        hardError: e.isConfigError,
      );
    } catch (e) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: "AI Processing Error: $e",
      );
    }
  }

  /// Update parsed intent when user manually edits fields in ConfirmationBox
  void updateIntent(IntentResult newIntent) {
    state = state.copyWith(intentResult: newIntent);
  }

  /// Update workspace match when user manually picks a workspace in ConfirmationBox
  void updateWorkspaceMatch(WorkspaceMatchResult? match) {
    state = state.copyWith(workspaceMatch: match);
  }

  /// Update both intent and workspace match
  void updateIntentAndWorkspace(IntentResult newIntent, WorkspaceMatchResult? match) {
    state = state.copyWith(
      intentResult: newIntent,
      workspaceMatch: match,
    );
  }

  /// Confirm and save/execute action via ExecuteAiActionUseCase
  Future<void> confirmAndSave() async {
    final intent = state.intentResult;
    if (intent == null) return;

    state = state.copyWith(isSaving: true);

    try {
      final workspaceMatch = state.workspaceMatch;
      String wsId = 'NEW';
      String? newWsName;

      if (workspaceMatch != null) {
        if (workspaceMatch.matchedWorkspace != null) {
          wsId = workspaceMatch.matchedWorkspace!.id;
        } else if (workspaceMatch.suggestedWorkspaceName != null) {
          newWsName = workspaceMatch.suggestedWorkspaceName;
        }
      }

      // Fallback workspace if none provided
      if (wsId == 'NEW' && (newWsName == null || newWsName.isEmpty)) {
        final workspaces = await _db.workspaceDao.getAll();
        if (workspaces.isNotEmpty) {
          wsId = workspaces.first.id;
          newWsName = null;
        } else {
          newWsName = 'General';
        }
      }

      await _executeAiActionUseCase.execute(
        intent: intent,
        workspaceId: wsId,
        workspaceNameToCreate: newWsName,
        originalTranscript: state.transcript,
      );

      state = state.copyWith(
        status: CaptureStatus.savedSuccess,
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: "Failed to execute AI action: $e",
        isSaving: false,
      );
    }
  }

  /// Switch to manual text input mode fallback.
  Future<void> switchToTextInput() async {
    _silenceTimer?.cancel();
    await _speechChannel.stopListening();
    state = state.copyWith(status: CaptureStatus.textInput);
  }

  /// Update transcript manually (when typing).
  void updateTypedTranscript(String text) {
    state = state.copyWith(transcript: text);
  }

  /// Submit typed transcript for processing.
  void submitTypedTranscript() {
    if (state.transcript.trim().isEmpty) return;
    stopAndProcess();
  }

  /// Cancel capture flow and reset to idle.
  Future<void> cancelCapture() async {
    _silenceTimer?.cancel();
    await _speechChannel.cancelListening();
    await _cancelSubscriptions();
    state = const CaptureState(status: CaptureStatus.idle);
  }

  /// Reset state to idle. Awaits subscription cancellation so a late speech
  /// event can never land in the fresh idle state.
  Future<void> reset() async {
    _silenceTimer?.cancel();
    await _cancelSubscriptions();
    if (!mounted) return;
    state = const CaptureState(status: CaptureStatus.idle);
  }

  Future<void> _cancelSubscriptions() async {
    await _transcriptSub?.cancel();
    await _finalTranscriptSub?.cancel();
    await _audioLevelSub?.cancel();
    await _stateSub?.cancel();
    await _errorSub?.cancel();
    _transcriptSub = null;
    _finalTranscriptSub = null;
    _audioLevelSub = null;
    _stateSub = null;
    _errorSub = null;
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _cancelSubscriptions();
    super.dispose();
  }
}
