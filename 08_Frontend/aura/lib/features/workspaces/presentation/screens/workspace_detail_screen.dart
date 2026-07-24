import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

class WorkspaceDetailScreen extends StatelessWidget {
  const WorkspaceDetailScreen({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        appBar: AppBar(title: const Text('Workspace')),
        body: Center(child: Text('Workspace $workspaceId — Sprint 5', style: AuraTypography.body)),
      );
}
