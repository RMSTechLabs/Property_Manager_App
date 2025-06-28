import 'package:flutter/material.dart';
import 'package:property_manager_app/src/presentation/widgets/animated_typing_text%20.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign textAlign;
  final bool isAnimated;
  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
    this.textAlign = TextAlign.start,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: !isAnimated
          ? Text(text, style: style, textAlign: textAlign)
          : AnimatedTypingText(text: text, style: style),
    );
  }
}
