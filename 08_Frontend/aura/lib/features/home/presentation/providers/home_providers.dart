import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../domain/services/nudge_engine.dart';

export '../../../../core/providers/providers.dart';

/// Watch item count for a workspace.
final workspaceItemCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, workspaceId) {
  final wsDao = ref.watch(workspaceDaoProvider);
  return wsDao.watchItemCount(workspaceId);
});

/// NudgeEngine provider for proactive nudges
final nudgeEngineProvider = Provider<NudgeEngine>((ref) {
  final itemDao = ref.watch(itemDaoProvider);
  return NudgeEngine(itemDao: itemDao);
});
