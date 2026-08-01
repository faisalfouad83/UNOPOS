import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Suppliers', icon: Icons.local_shipping_outlined);
  }
}
