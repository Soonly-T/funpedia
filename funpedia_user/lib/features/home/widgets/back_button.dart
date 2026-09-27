import 'dart:async';

import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/audio/subject_audio.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';

class CustomBackButton extends StatefulWidget {
  const CustomBackButton({
    super.key,
    required this.isWideScreen,
    required this.color,
    required this.pressJingle,
  });
  final bool isWideScreen;
  final Color color;
  final List<MusicalNote> pressJingle;

  @override
  State<CustomBackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<CustomBackButton> {
  bool isHover = false;
  bool isPressed = false;
  bool _isNavigating = false;
  final _audioPlayer = SubjectAudioPlayer();

  void _playReverseJingle() {
    _audioPlayer.playMelody(widget.pressJingle, reverse: true);
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            isHover = true;
          });
        },

        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              isPressed = true;
            });
          },
          onTap: () {
            if (_isNavigating) return;
            _isNavigating = true;
            _playReverseJingle();
            Navigator.pop(context);
          },
          onTapUp: (_) {
            setState(() {
              isPressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              isPressed = false;
            });
          },
          child: AnimatedScale(
            scale: isHover || isPressed ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: widget.isWideScreen ? 128 : 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: widget.color,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: widget.isWideScreen ? 24 : 18,
                    color: Colors.white,
                  ),

                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: widget.isWideScreen ? 18 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      decoration: isPressed || isHover
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: Colors.white,
                      decorationThickness: 2.0,
                    ),
                  ),
                  SizedBox(width: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
