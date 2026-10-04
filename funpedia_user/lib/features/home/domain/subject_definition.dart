import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';
import 'package:funpedia_user/features/home/domain/subject_icons.dart';

class SubjectDefinition {
  const SubjectDefinition({
    required this.index,
    required this.name,
    required this.color,
    required this.icon,
    required this.slug,
    required this.pressJingle,
    required this.hoverTone,
  });

  /// Reads a `subjects` table row using the column names as-is.
  factory SubjectDefinition.fromJson(Map<String, dynamic> json) {
    return SubjectDefinition(
      index: json['index'] as int,
      name: json['name'] as String,
      color: _parseHexColor(json['color'] as String),
      icon: iconForKey(json['icon_key'] as String?),
      slug: json['slug'] as String,
      pressJingle: (json['press_jingle'] as List<dynamic>)
          .map((note) => MusicalNote.parse(note as String))
          .toList(),
      hoverTone: MusicalNote.parse(json['hover_tone'] as String),
    );
  }

  final int index;
  final String name;
  final IconData icon;
  final Color color;
  final List<MusicalNote> pressJingle;
  final MusicalNote hoverTone;
  final String slug;
}

Color _parseHexColor(String hex) {
  final digits = hex.startsWith('#') ? hex.substring(1) : hex;
  final value = int.tryParse(digits, radix: 16);
  if (digits.length != 6 || value == null) {
    throw FormatException('Invalid hex color: "$hex"');
  }
  return Color(0xFF000000 | value);
}
