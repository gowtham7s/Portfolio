import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Floating scroll progress bar at the top of the screen.
class ScrollProgressIndicatorWidget extends StatelessWidget {
  final ScrollController controller;

  const ScrollProgressIndicatorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double progress = 0;
        if (controller.hasClients &&
            controller.position.maxScrollExtent > 0) {
          progress = controller.offset / controller.position.maxScrollExtent;
        }
        return Container(
          height: 3,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        );
      },
    );
  }
}
