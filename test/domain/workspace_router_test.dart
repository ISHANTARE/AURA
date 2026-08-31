import 'package:flutter_test/flutter_test.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/entities/workspace_match_result.dart';
import 'package:aura/features/capture/domain/usecases/workspace_router_usecase.dart';
import 'package:aura/features/workspaces/domain/workspace_taxonomy.dart';

Workspace _ws(String id, String name) => Workspace(
      id: id,
      name: name,
      colorHex: '#C8FF00',
      iconKey: 'folder',
      sortOrder: 0,
      createdBy: 'USER_EXPLICIT',
      isArchived: false,
      createdAt: 0,
      updatedAt: 0,
    );

void main() {
  late WorkspaceRouterUseCase router;

  setUp(() {
    router = WorkspaceRouterUseCase();
  });

  group('WorkspaceRouterUseCase (name-match + generic taxonomy)', () {
    final workspaces = [
      _ws('ws-1', 'College'),
      _ws('ws-2', 'Work Stuff'),
      _ws('ws-3', 'Health'),
      _ws('ws-4', 'Personal'),
    ];

    test('exact name match wins', () {
      final match = router.routeWorkspace(
        workspaceHint: 'college',
        existingWorkspaces: workspaces,
      );
      expect(match.type, WorkspaceMatchType.exact);
      expect(match.matchedWorkspace!.id, 'ws-1');
    });

    test('partial containment matches real workspace names', () {
      final match = router.routeWorkspace(
        workspaceHint: 'work stuff planning',
        existingWorkspaces: workspaces,
      );
      expect(match.matchedWorkspace, isNotNull);
      expect(match.matchedWorkspace!.id, 'ws-2');
    });

    test('taxonomy fallback routes health hints to a Health workspace', () {
      final match = router.routeWorkspace(
        workspaceHint: 'fitness',
        existingWorkspaces: workspaces,
      );
      expect(match.matchedWorkspace!.id, 'ws-3');
    });

    test('unknown hint suggests a new workspace named after the hint', () {
      final match = router.routeWorkspace(
        workspaceHint: 'Rocket Club',
        existingWorkspaces: workspaces,
      );
      expect(match.type, WorkspaceMatchType.newWorkspace);
      expect(match.suggestedWorkspaceName, 'Rocket Club');
    });

    test('null hint yields no match', () {
      final match = router.routeWorkspace(
        workspaceHint: null,
        existingWorkspaces: workspaces,
      );
      expect(match.type, WorkspaceMatchType.none);
    });

    test('empty workspace list suggests creation instead of crashing', () {
      final match = router.routeWorkspace(
        workspaceHint: 'Side Project',
        existingWorkspaces: const [],
      );
      expect(match.type, WorkspaceMatchType.newWorkspace);
    });
  });

  group('WorkspaceTaxonomy purity (market-ready guard)', () {
    const bannedTokens = ['vit', 'vtop', 'gate', 'iit', 'pyq', 'ishan'];

    test('contains no developer/institution-specific keywords', () {
      WorkspaceTaxonomy.categories.forEach((category, keywords) {
        for (final keyword in keywords) {
          for (final banned in bannedTokens) {
            expect(keyword.toLowerCase().contains(banned), isFalse,
                reason:
                    '"$keyword" (in "$category") contains banned token "$banned"');
          }
        }
      });
    });
  });
}
