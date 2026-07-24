import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        appBar: AppBar(title: const Text('Task')),
        body: Center(child: Text('Task $taskId — Sprint 7', style: AuraTypography.body)),
      );
}
