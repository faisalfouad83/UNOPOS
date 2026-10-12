import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'full_screen.dart';

/// Top-bar button that switches full screen on and off.
class FullScreenButton extends StatelessWidget {
  const FullScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppFullScreen.supported) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: AppFullScreen.isOn,
      builder: (context, on, _) => IconButton(
        icon: Icon(on ? Icons.fullscreen_exit : Icons.fullscreen),
        tooltip: on ? l10n.actionExitFullScreen : l10n.actionFullScreen,
        onPressed: AppFullScreen.toggle,
      ),
    );
  }
}
