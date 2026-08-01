import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_screen.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Point of Sale', icon: Icons.point_of_sale_outlined);
  }
}
