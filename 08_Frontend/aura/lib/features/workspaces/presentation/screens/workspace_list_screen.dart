import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

class WorkspaceListScreen extends StatelessWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(child: Text('Workspaces — Sprint 5', style: AuraTypography.sectionHeader)),
      );
}
