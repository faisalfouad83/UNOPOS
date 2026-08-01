import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Settings', icon: Icons.settings_outlined);
  }
}
