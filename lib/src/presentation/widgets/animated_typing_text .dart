import 'package:flutter/material.dart';

class AnimatedTypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;

  const AnimatedTypingText({
    super.key,
    required this.text,
    required this.style,
    this.speed = const Duration(milliseconds: 80),
  });

  @override
  State<AnimatedTypingText> createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<AnimatedTypingText> {
  String _displayedText = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _typeText();
  }

  void _typeText() async {
    while (_index < widget.text.length) {
      await Future.delayed(widget.speed);
      setState(() {
        _index++;
        _displayedText = widget.text.substring(0, _index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
