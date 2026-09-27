import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';

class SubjectDefinition {
  const SubjectDefinition({
    required this.index,
    required this.name,
    required this.color,
    required this.icon,
    required this.routeName,
    required this.pressJingle,
    required this.hoverTone,
  });

  final int index;
  final String name;
  final IconData icon;
  final Color color;
  final List<MusicalNote> pressJingle;
  final MusicalNote hoverTone;
  final String routeName;
}
