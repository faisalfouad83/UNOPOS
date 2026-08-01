import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Accounting', icon: Icons.account_balance_outlined);
  }
}
