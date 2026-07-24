import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../database/app_database.dart';
import '../../../../platform/speech_channel.dart';
import '../../data/datasources/llm_api_datasource.dart';
import '../../domain/entities/capture_state.dart';
import '../../domain/entities/intent_result.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/queue_offline_transcript_usecase.dart';
import '../../domain/usecases/workspace_router_usecase.dart';

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

final captureProvider =
    StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final speechChannel = ref.watch(speechChannelProvider);
  final llmDataSource = ref.watch(llmApiDataSourceProvider);
  final workspaceRouter = ref.watch(workspaceRouterUseCaseProvider);
  final createTaskUseCase = ref.watch(createTaskUseCaseProvider);
  final queueOfflineUseCase = ref.watch(queueOfflineTranscriptUseCaseProvider);
  final db = ref.watch(databaseProvider);
  final isOnline = ref.watch(isOnlineProvider);

  return CaptureNotifier(
    speechChannel: speechChannel,
    llmDataSource: llmDataSource,
    workspaceRouter: workspaceRouter,
    createTaskUseCase: createTaskUseCase,
    queueOfflineUseCase: queueOfflineUseCase,
    db: db,
    isOnline: isOnline,
  );
});

class CaptureNotifier extends StateNotifier<CaptureState> {
  final SpeechChannel _speechChannel;
  final LlmApiDataSource _llmDataSource;
  final WorkspaceRouterUseCase _workspaceRouter;
  final CreateTaskUseCase _createTaskUseCase;
  final QueueOfflineTranscriptUseCase _queueOfflineUseCase;
  final AppDatabase _db;
  final bool _isOnline;

  StreamSubscription<String>? _transcriptSub;
  StreamSubscription<double>? _audioLevelSub;
  StreamSubscription<String>? _stateSub;
  StreamSubscription<String>? _errorSub;

  Timer? _silenceTimer;

  CaptureNotifier({
    required SpeechChannel speechChannel,
    required LlmApiDataSource llmDataSource,
    required WorkspaceRouterUseCase workspaceRouter,
    required CreateTaskUseCase createTaskUseCase,
    required QueueOfflineTranscriptUseCase queueOfflineUseCase,
    required AppDatabase db,
    required bool isOnline,
  })  : _speechChannel = speechChannel,
        _llmDataSource = llmDataSource,
        _workspaceRouter = workspaceRouter,
        _createTaskUseCase = createTaskUseCase,
        _queueOfflineUseCase = queueOfflineUseCase,
        _db = db,
        _isOnline = isOnline,
        super(const CaptureState());

  /// Start voice capture flow.
  Future<void> startCapture() async {
    state = const CaptureState(status: CaptureStatus.starting);

    await _cancelSubscriptions();

    _transcriptSub =
        _speechChannel.partialTranscriptStream.listen(_onPartialTranscript);
    _audioLevelSub =
        _speechChannel.audioLevelStream.listen(_onAudioLevel);
    _stateSub = _speechChannel.speechStateStream.listen(_onSpeechState);
    _errorSub = _speechChannel.errorStream.listen(_onError);

    final success = await _speechChannel.startListening();
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

  void _onPartialTranscript(String text) {
    if (text.isEmpty) return;

    final contextHint = _detectContextHint(text);

    state = state.copyWith(
      transcript: text,
      detectedContext: contextHint,
    );

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
    _silenceTimer = Timer(const Duration(milliseconds: 1500), () {
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

    final transcriptText = state.transcript.trim();
    if (transcriptText.isEmpty) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage:
            "No speech detected. Try speaking clearly or type manually.",
      );
      return;
    }

    state = state.copyWith(status: CaptureStatus.processing);

    // If device is offline, queue to local DB offline_queue
    if (!_isOnline) {
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

    // Device is online: send transcript to Gemini / NVIDIA NIM
    try {
      final existingWorkspaces = await _db.workspaceDao.getAll();
      final workspaceNames = existingWorkspaces.map((w) => w.name).toList();

      final intentResult = await _llmDataSource.extractIntent(
        transcript: transcriptText,
        userWorkspaces: workspaceNames,
      );

      final workspaceMatch = _workspaceRouter.routeWorkspace(
        workspaceHint: intentResult.workspaceHint,
        existingWorkspaces: existingWorkspaces,
      );

      state = state.copyWith(
        status: CaptureStatus.confirming,
        intentResult: intentResult,
        workspaceMatch: workspaceMatch,
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

  /// Confirm and save task to SQLite Drift database
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

      await _createTaskUseCase.execute(
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
        errorMessage: "Failed to save task: $e",
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
    final contextHint = _detectContextHint(text);
    state = state.copyWith(
      transcript: text,
      detectedContext: contextHint,
    );
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

  /// Reset state to idle.
  void reset() {
    _silenceTimer?.cancel();
    _cancelSubscriptions();
    state = const CaptureState(status: CaptureStatus.idle);
  }

  String? _detectContextHint(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('assignment') ||
        lower.contains('exam') ||
        lower.contains('lab') ||
        lower.contains('vtop') ||
        lower.contains('vit')) {
      return 'Academics · VIT';
    }
    if (lower.contains('internship') ||
        lower.contains('standup') ||
        lower.contains('sprint') ||
        lower.contains('pr')) {
      return 'Internship';
    }
    if (lower.contains('gate') ||
        lower.contains('iit') ||
        lower.contains('pyq') ||
        lower.contains('algo')) {
      return 'IIT / GATE Prep';
    }
    if (lower.contains('gym') ||
        lower.contains('workout') ||
        lower.contains('water') ||
        lower.contains('run')) {
      return 'Fitness & Health';
    }
    return null;
  }

  Future<void> _cancelSubscriptions() async {
    await _transcriptSub?.cancel();
    await _audioLevelSub?.cancel();
    await _stateSub?.cancel();
    await _errorSub?.cancel();
    _transcriptSub = null;
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
