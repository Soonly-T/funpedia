import 'dart:async';

import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/audio/subject_audio.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';
import 'package:funpedia_user/features/home/domain/subject_definition.dart';
import 'package:funpedia_user/features/home/domain/subject_jingles.dart';
import 'package:funpedia_user/features/home/presentation/subject_menu_page.dart.dart';

class _TrapezoidClipper extends CustomClipper<Path> {
  const _TrapezoidClipper({required this.taperRight});

  final bool taperRight;

  static const inset = 12.0;
  static const cornerRadius = 16.0;

  @override
  Path getClip(Size size) {
    if (!taperRight) {
      return Path()
        ..moveTo(cornerRadius, inset)
        ..lineTo(size.width - cornerRadius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
        ..lineTo(size.width, size.height - cornerRadius)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width - cornerRadius,
          size.height,
        )
        ..lineTo(cornerRadius, size.height - inset)
        ..quadraticBezierTo(
          0,
          size.height - inset,
          0,
          size.height - inset - cornerRadius,
        )
        ..lineTo(0, inset + cornerRadius)
        ..quadraticBezierTo(0, inset, cornerRadius, inset)
        ..close();
    }

    return Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(size.width - cornerRadius, inset)
      ..quadraticBezierTo(size.width, inset, size.width, inset + cornerRadius)
      ..lineTo(size.width, size.height - inset - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height - inset,
        size.width - cornerRadius,
        size.height - inset,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..close();
  }

  @override
  bool shouldReclip(_TrapezoidClipper oldClipper) =>
      oldClipper.taperRight != taperRight;
}

class _WideParallelogramClipper extends CustomClipper<Path> {
  const _WideParallelogramClipper({required this.droopRight});

  final bool droopRight;

  static const lift = 16.0;
  static const cornerRadius = 16.0;

  @override
  Path getClip(Size size) {
    final topLeft = droopRight ? 0.0 : lift;
    final topRight = droopRight ? lift : 0.0;
    final bottomLeft = droopRight ? size.height - lift : size.height;
    final bottomRight = droopRight ? size.height : size.height - lift;

    return Path()
      ..moveTo(cornerRadius, topLeft)
      ..lineTo(size.width - cornerRadius, topRight)
      ..quadraticBezierTo(
        size.width,
        topRight,
        size.width,
        topRight + cornerRadius,
      )
      ..lineTo(size.width, bottomRight - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        bottomRight,
        size.width - cornerRadius,
        bottomRight,
      )
      ..lineTo(cornerRadius, bottomLeft)
      ..quadraticBezierTo(0, bottomLeft, 0, bottomLeft - cornerRadius)
      ..lineTo(0, topLeft + cornerRadius)
      ..quadraticBezierTo(0, topLeft, cornerRadius, topLeft)
      ..close();
  }

  @override
  bool shouldReclip(_WideParallelogramClipper oldClipper) =>
      oldClipper.droopRight != droopRight;
}

class SubjectCard extends StatefulWidget {
  final BuildContext context;
  final SubjectDefinition subject;
  final bool isWideScreen;

  const SubjectCard({
    super.key,
    required this.context,
    required this.subject,
    required this.isWideScreen,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _isPressed = false;
  bool _isHovered = false;
  List<MusicalNote>? _selectedJingle;
  final _audioPlayer = SubjectAudioPlayer();
  Timer? _hoverDebounce;

  void _playHoverTone() {
    _hoverDebounce?.cancel();
    _hoverDebounce = Timer(const Duration(milliseconds: 90), () {
      _audioPlayer.playHoverNote(widget.subject.hoverTone);
    });
  }

  void _playPressJingle() {
    _selectedJingle = SubjectJingles.forSubject(widget.subject.name);
    _audioPlayer.playMelody(_selectedJingle!);
  }

  @override
  void dispose() {
    _hoverDebounce?.cancel();
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _playHoverTone();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: Listener(
        onPointerDown: (_) {
          setState(() => _isPressed = true);
          _playPressJingle();
        },
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed || _isHovered ? 1.12 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: ClipPath(
            clipper: widget.isWideScreen
                ? _WideParallelogramClipper(droopRight: subject.index.isEven)
                : _TrapezoidClipper(taperRight: subject.index.isEven),
            child: ElevatedButton(
              onPressed: () {
                final jingle =
                    _selectedJingle ?? SubjectJingles.forSubject(subject.name);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 250,
                    ),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SubMenu(
                          subject: subject.name,
                          routeName: subject.routeName,
                          color: subject.color,
                          icon: subject.icon,
                          pressJingle: jingle,
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          final slideAnimation =
                              Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              );

                          return SlideTransition(
                            position: slideAnimation,
                            child: child,
                          );
                        },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                backgroundColor: subject.color,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(84),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(subject.icon, color: Colors.white, size: 48),
                      const SizedBox(height: 20),
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
