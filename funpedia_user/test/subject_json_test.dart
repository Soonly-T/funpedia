import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';
import 'package:funpedia_user/features/home/domain/subject_definition.dart';
import 'package:funpedia_user/features/home/domain/subject_icons.dart';

// Rows exactly as the Supabase `subjects` table returns them.
const _rows = <Map<String, dynamic>>[
  {
    'index': 0,
    'name': 'History',
    'color': '#8D6E63',
    'press_jingle': ['D3', 'A3', 'F#3', 'D4'],
    'hover_tone': 'D3',
    'slug': 'history',
    'icon_key': 'account_balance',
  },
  {
    'index': 1,
    'name': 'Geography',
    'color': '#4FC3F7',
    'press_jingle': ['C3', 'G3', 'E4', 'C5'],
    'hover_tone': 'C3',
    'slug': 'geography',
    'icon_key': 'public',
  },
  {
    'index': 2,
    'name': 'Philosophy',
    'color': '#7E57C2',
    'press_jingle': ['A3', 'C4', 'B3', 'D4'],
    'hover_tone': 'A#3',
    'slug': 'philosophy',
    'icon_key': 'psychology',
  },
  {
    'index': 3,
    'name': 'Society',
    'color': '#26A69A',
    'press_jingle': ['G3', 'D4', 'C4', 'B4'],
    'hover_tone': 'G3',
    'slug': 'society',
    'icon_key': 'groups',
  },
  {
    'index': 4,
    'name': 'Arts',
    'color': '#EC407A',
    'press_jingle': ['F4', 'A4', 'C5', 'D5'],
    'hover_tone': 'F4',
    'slug': 'arts',
    'icon_key': 'palette',
  },
  {
    'index': 5,
    'name': 'Physics',
    'color': '#3949AB',
    'press_jingle': ['G3', 'D4', 'B4', 'D5'],
    'hover_tone': 'G3',
    'slug': 'physics',
    'icon_key': 'science',
  },
  {
    'index': 6,
    'name': 'Chemistry',
    'color': '#43A047',
    'press_jingle': ['F#3', 'C#4', 'B4', 'C#5'],
    'hover_tone': 'F#3',
    'slug': 'chemistry',
    'icon_key': 'biotech',
  },
  {
    'index': 7,
    'name': 'Biology',
    'color': '#66BB6A',
    'press_jingle': ['E3', 'B3', 'G4', 'D5'],
    'hover_tone': 'E3',
    'slug': 'biology',
    'icon_key': 'eco',
  },
  {
    'index': 8,
    'name': 'Mathematics',
    'color': '#5C6BC0',
    'press_jingle': ['D4', 'A4', 'F#4', 'C#5'],
    'hover_tone': 'D4',
    'slug': 'mathematics',
    'icon_key': 'calculate',
  },
  {
    'index': 9,
    'name': 'Technology',
    'color': '#FFA726',
    'press_jingle': ['C4', 'E4', 'G4', 'D5'],
    'hover_tone': 'C4',
    'slug': 'technology',
    'icon_key': 'memory',
  },
  {
    'index': 10,
    'name': 'Earth Science',
    'color': '#78909C',
    'press_jingle': ['A3', 'F4', 'D4', 'D5'],
    'hover_tone': 'A3',
    'slug': 'earth-science',
    'icon_key': 'terrain',
  },
  {
    'index': 11,
    'name': 'Interactives',
    'color': '#00897B',
    'press_jingle': ['A3', 'C#4', 'E4', 'C#5'],
    'hover_tone': 'A3',
    'slug': 'interactives',
    'icon_key': 'extension',
  },
];

void main() {
  group('SubjectDefinition.fromJson', () {
    test('accepts every current table row without a translation step', () {
      final subjects = _rows.map(SubjectDefinition.fromJson).toList();

      expect(subjects, hasLength(12));
      for (final subject in subjects) {
        expect(subject.pressJingle, hasLength(4));
        expect(subject.icon, isNot(fallbackSubjectIcon), reason: subject.name);
      }
    });

    test('maps a full row to the matching app values', () {
      final philosophy = SubjectDefinition.fromJson(_rows[2]);

      expect(philosophy.index, 2);
      expect(philosophy.slug, 'philosophy');
      expect(philosophy.color, const Color(0xFF7E57C2));
      expect(philosophy.icon, Icons.psychology);
      expect(philosophy.pressJingle.map((n) => n.name), [
        'A3',
        'C4',
        'B3',
        'D4',
      ]);
      expect(philosophy.hoverTone.name, 'A#3');
    });

    test('falls back to a default icon for an unknown or missing key', () {
      expect(iconForKey('not_a_real_icon'), fallbackSubjectIcon);
      expect(iconForKey(null), fallbackSubjectIcon);
    });

    test('rejects a malformed color', () {
      expect(
        () => SubjectDefinition.fromJson({..._rows[0], 'color': 'brown'}),
        throwsFormatException,
      );
    });
  });

  group('MusicalNote.parse', () {
    test('uses A4 = 440 Hz equal temperament', () {
      expect(MusicalNote.parse('A4').frequency, closeTo(440.0, 0.001));
      expect(MusicalNote.parse('C4').frequency, closeTo(261.63, 0.01));
      expect(MusicalNote.parse('F#3').frequency, closeTo(185.0, 0.01));
    });

    test('normalizes case and treats Bb and A# as the same pitch', () {
      final flat = MusicalNote.parse('bb4');

      expect(flat.name, 'Bb4');
      expect(flat.frequency, closeTo(MusicalNote.parse('A#4').frequency, 1e-9));
    });

    test('matches the hand-entered catalog within rounding', () {
      for (final note in [Note.d3, Note.as3, Note.cs5, Note.d5, Note.b2]) {
        expect(
          MusicalNote.parse(note.name).frequency,
          closeTo(note.frequency, 0.01),
          reason: note.name,
        );
      }
    });

    test('rejects an invalid note name', () {
      expect(() => MusicalNote.parse('H4'), throwsFormatException);
      expect(() => MusicalNote.parse('C'), throwsFormatException);
    });
  });
}
