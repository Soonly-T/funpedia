import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';
import 'package:funpedia_user/features/home/domain/subject_definition.dart';

void main() {
  test('each subject has a unique four-note press jingle and a hover tone', () {
    const history = SubjectDefinition(
      index: 0,
      name: 'History',
      color: Color(0xFF8D6E63),
      icon: Icons.account_balance,
      routeName: 'history',
      pressJingle: [Note.c4, Note.e4, Note.g4, Note.c5],
      hoverTone: Note.e5,
    );

    const geography = SubjectDefinition(
      index: 1,
      name: 'Geography',
      color: Color(0xFF4FC3F7),
      icon: Icons.public,
      routeName: 'geography',
      pressJingle: [Note.d4, Note.f4, Note.a4, Note.d5],
      hoverTone: Note.f5,
    );

    expect(history.pressJingle.length, 4);
    expect(history.hoverTone.frequency, greaterThan(0));
    expect(
      history.pressJingle.last.frequency,
      history.pressJingle
          .map((note) => note.frequency)
          .reduce((highest, note) => highest > note ? highest : note),
    );
    expect(history.pressJingle, isNot(equals(geography.pressJingle)));
    expect(history.hoverTone, isNot(equals(geography.hoverTone)));
  });
}
