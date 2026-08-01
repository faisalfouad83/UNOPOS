import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Debt Ledger', icon: Icons.receipt_long_outlined);
  }
}
