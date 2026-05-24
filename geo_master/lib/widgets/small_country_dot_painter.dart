import 'package:flutter/material.dart';

class SmallCountryDotPainter extends CustomPainter {
  final Map<String, Offset> dotPositions;
  final Set<String> correctCodes;
  final double pulseValue;
  final Offset svgOffset;
  final double svgScale;

  const SmallCountryDotPainter({
    required this.dotPositions,
    required this.correctCodes,
    required this.pulseValue,
    required this.svgOffset,
    required this.svgScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in dotPositions.entries) {
      final code = entry.key;
      final svgPos = entry.value;
      final isCorrect = correctCodes.contains(code.toLowerCase());

      final screenPos = Offset(
        svgPos.dx * svgScale + svgOffset.dx,
        svgPos.dy * svgScale + svgOffset.dy,
      );

      if (!isCorrect) {
        canvas.drawCircle(
          screenPos,
          8 * pulseValue,
          Paint()
            ..color = const Color(0xFFf59e0b).withOpacity(pulseValue * 0.4)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawCircle(
        screenPos,
        5,
        Paint()
          ..color = isCorrect
              ? const Color(0xFF22c55e)
              : const Color(0xFFf59e0b)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        screenPos,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(SmallCountryDotPainter old) =>
      old.correctCodes != correctCodes ||
      old.pulseValue != pulseValue ||
      old.svgOffset != svgOffset ||
      old.svgScale != svgScale;
}
