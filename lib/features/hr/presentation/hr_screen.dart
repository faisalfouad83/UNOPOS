import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class HrScreen extends StatelessWidget {
  const HrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Staff Directory', icon: Icons.badge_outlined);
  }
}
