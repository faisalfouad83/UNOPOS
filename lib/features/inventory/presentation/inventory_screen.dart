import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Inventory', icon: Icons.inventory_2_outlined);
  }
}
