import 'package:flutter_test/flutter_test.dart';

import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/workspace_router_usecase.dart';

void main() {
  final nowMs = DateTime.now().millisecondsSinceEpoch;

  final sampleWorkspaces = [
    Workspace(
      id: 'ws-work',
      name: 'Work & Projects',
      colorHex: '#7B6FF0',
      iconKey: 'briefcase',
      sortOrder: 0,
      createdBy: 'user',
      isArchived: false,
      createdAt: nowMs,
      updatedAt: nowMs,
    ),
    Workspace(
      id: 'ws-college',
      name: 'VIT Academics',
      colorHex: '#22D3EE',
      iconKey: 'book',
      sortOrder: 1,
      createdBy: 'user',
      isArchived: false,
      createdAt: nowMs,
      updatedAt: nowMs,
    ),
    Workspace(
      id: 'ws-personal',
      name: 'Personal Life',
      colorHex: '#C084FC',
      iconKey: 'user',
      sortOrder: 2,
      createdBy: 'user',
      isArchived: false,
      createdAt: nowMs,
      updatedAt: nowMs,
    ),
    Workspace(
      id: 'ws-health',
      name: 'Fitness & Health',
      colorHex: '#C8FF00',
      iconKey: 'heart',
      sortOrder: 3,
      createdBy: 'user',
      isArchived: false,
      createdAt: nowMs,
      updatedAt: nowMs,
    ),
  ];

  group('WorkspaceRouterUseCase Tests', () {
    test('Tier 1: Exact Name Match (case-insensitive) matches with confidence 1.0', () {
      final result = WorkspaceRouterUseCase.route(
        workspaceHint: 'vit academics',
        workspaces: sampleWorkspaces,
      );

      expect(result.workspace, isNotNull);
      expect(result.workspace!.id, 'ws-college');
      expect(result.matchConfidence, 1.0);
      expect(result.isNewWorkspaceSuggestion, false);
    });

    test('Tier 2: Fuzzy Containment matches with confidence 0.85', () {
      final result = WorkspaceRouterUseCase.route(
        workspaceHint: 'Fitness',
        workspaces: sampleWorkspaces,
      );

      expect(result.workspace, isNotNull);
      expect(result.workspace!.id, 'ws-health');
      expect(result.matchConfidence, 0.85);
    });

    test('Tier 3: Taxonomy keyword match maps "gym / workout" to Fitness & Health', () {
      final result = WorkspaceRouterUseCase.route(
        workspaceHint: null,
        transcript: 'remind me to go to gym and do leg workout today',
        workspaces: sampleWorkspaces,
      );

      expect(result.workspace, isNotNull);
      expect(result.workspace!.id, 'ws-health');
      expect(result.matchConfidence, 0.70);
    });

    test('Tier 3: Taxonomy keyword match maps "exam / study / vit" to VIT Academics', () {
      final result = WorkspaceRouterUseCase.route(
        workspaceHint: null,
        transcript: 'study for upcoming final exam assignment',
        workspaces: sampleWorkspaces,
      );

      expect(result.workspace, isNotNull);
      expect(result.workspace!.id, 'ws-college');
      expect(result.matchConfidence, 0.70);
    });

    test('Tier 4: Unmatched unknown workspace hint returns New Workspace suggestion', () {
      final result = WorkspaceRouterUseCase.route(
        workspaceHint: 'Quantum Computing Club',
        workspaces: sampleWorkspaces,
      );

      expect(result.workspace, isNull);
      expect(result.isNewWorkspaceSuggestion, true);
      expect(result.suggestedNewWorkspaceName, 'Quantum Computing Club');
    });

    test('Returns none when workspace list is empty and no hint provided', () {
      final result = WorkspaceRouterUseCase.route(
        workspaceHint: null,
        workspaces: [],
      );

      expect(result.workspace, isNull);
      expect(result.isNewWorkspaceSuggestion, false);
      expect(result.matchConfidence, 0.0);
    });
  });
}
