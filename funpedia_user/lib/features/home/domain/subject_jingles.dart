import 'package:funpedia_user/features/home/domain/musical_note.dart';

abstract final class SubjectJingles {
  static const all = <List<MusicalNote>>[
    [Note.c4, Note.e4, Note.g4, Note.d5],
    [Note.d3, Note.fs3, Note.a3, Note.d5],
    [Note.e3, Note.b3, Note.g4, Note.d5],
    [Note.f4, Note.a4, Note.c5, Note.d5],
    [Note.g3, Note.d4, Note.b4, Note.d5],
    [Note.c3, Note.g3, Note.e4, Note.c5],
    [Note.a3, Note.f4, Note.d4, Note.d5],
    [Note.d4, Note.a4, Note.fs4, Note.cs5],
    [Note.g3, Note.e4, Note.d4, Note.c5],
    [Note.as3, Note.f4, Note.ds4, Note.c5],
    [Note.fs3, Note.cs4, Note.b4, Note.cs5],
    [Note.g3, Note.d4, Note.c4, Note.b4],
    [Note.d3, Note.a3, Note.g3, Note.d4],
    [Note.a3, Note.cs4, Note.e4, Note.cs5],
    [Note.f3, Note.c4, Note.a4, Note.c5],
    [Note.e3, Note.g3, Note.b3, Note.b4],
    [Note.c3, Note.e3, Note.g3, Note.c4],
  ];

  static final _bySubject = <String, List<MusicalNote>>{
    'History': all[12],
    'Geography': all[5],
    'Philosophy': all[9],
    'Society': all[11],
    'Arts': all[3],
    'Physics': all[4],
    'Chemistry': all[10],
    'Biology': all[2],
    'Mathematics': all[7],
    'Technology': all[0],
    'Earth Science': all[6],
    'Interactives': [Note.a3, Note.cs4, Note.e4, Note.cs5],
  };

  static List<MusicalNote> forSubject(String subject) =>
      _bySubject[subject] ?? all[0];
}
