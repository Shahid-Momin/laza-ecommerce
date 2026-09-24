import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BackgroundEllipses extends StatelessWidget {
  final bool isDarkMode;

  const BackgroundEllipses({super.key, required this.isDarkMode});

  static const double _figmaCanvasWidth = 375.0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenWidth / _figmaCanvasWidth;

    return IgnorePointer(
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: -81 * scale,
              left: -42 * scale,
              child: _gradientEllipse(
                width: 250 * scale,
                height: 250 * scale,
                intensity: 1.0,
              ),
            ),
            Positioned(
              top: 503 * scale,
              left: 194 * scale,
              child: _gradientEllipse(
                width: 250 * scale,
                height: 250 * scale,
                intensity: 1.0,
              ),
            ),
            Positioned(
              top: 381 * scale,
              left: -74 * scale,
              child: _gradientEllipse(
                width: 148 * scale,
                height: 148 * scale,
                intensity: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientEllipse({
    required double width,
    required double height,
    double intensity = 1.0,
  }) {
    final Color glowColor =
    isDarkMode ? AppColors.purple : Colors.white;

    final double centerOpacity = isDarkMode
        ? (0.22 * intensity).clamp(0.0, 1.0)
        : (0.28 * intensity).clamp(0.0, 1.0);

    final double edgeOpacity = isDarkMode
        ? (0.16 * intensity).clamp(0.0, 1.0)
        : (0.22 * intensity).clamp(0.0, 1.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [
            glowColor.withOpacity(centerOpacity),
            glowColor.withOpacity(edgeOpacity),
            glowColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}