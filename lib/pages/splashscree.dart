import 'package:flutter/material.dart';
import 'dart:async';

// This is your splash screen that will show for 2-3 seconds
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({Key? key, required this.nextScreen}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _displayText = "";
  final String _fullText = "G e a r  C a r e";
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Start the animated typing effect
    _startTypingAnimation();

    // Navigate to next screen after splash duration
    Timer(const Duration(milliseconds: 3000), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    });
  }

  void _startTypingAnimation() {
    const typingSpeed = Duration(milliseconds: 120);
    _timer = Timer.periodic(typingSpeed, (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Your animated text
              Text(
                _displayText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),

              // Blinking cursor at the end of text
              if (_currentIndex < _fullText.length)
                Positioned(
                  left: _getTextWidth(context) + 8,
                  child: _buildBlinkingCursor(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlinkingCursor() {
    return AnimatedOpacity(
      opacity: DateTime.now().millisecondsSinceEpoch % 1000 > 500 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(height: 30, width: 3, color: Colors.black87),
    );
  }

  // Helper method to calculate the current text width for cursor positioning
  double _getTextWidth(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _displayText,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }
}
