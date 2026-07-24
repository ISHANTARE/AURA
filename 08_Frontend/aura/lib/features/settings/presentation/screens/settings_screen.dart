import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        appBar: AppBar(title: const Text('Settings')),
        body: Center(child: Text('Settings — Sprint 10', style: AuraTypography.body)),
      );
}
