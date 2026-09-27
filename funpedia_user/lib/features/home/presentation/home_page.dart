import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';
import 'package:funpedia_user/features/home/domain/subject_definition.dart';
import 'package:funpedia_user/features/home/widgets/subject_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const subjects = <SubjectDefinition>[
    SubjectDefinition(
      index: 0,
      name: 'History',
      color: Color(0xFF8D6E63),
      icon: Icons.account_balance,
      routeName: '',
      pressJingle: [Note.d3, Note.a3, Note.fs3, Note.d4],
      hoverTone: Note.d3,
    ),
    SubjectDefinition(
      index: 1,
      name: 'Geography',
      color: Color(0xFF4FC3F7),
      icon: Icons.public,
      routeName: 'geography',
      pressJingle: [Note.c3, Note.g3, Note.e4, Note.c5],
      hoverTone: Note.c3,
    ),
    SubjectDefinition(
      index: 2,
      name: 'Philosophy',
      color: Color(0xFF7E57C2),
      icon: Icons.psychology,
      routeName: 'philosophy',
      pressJingle: [Note.a3, Note.c4, Note.b3, Note.d4],
      hoverTone: Note.as3,
    ),
    SubjectDefinition(
      index: 3,
      name: 'Society',
      color: Color(0xFF26A69A),
      icon: Icons.groups,
      routeName: 'society',
      pressJingle: [Note.g3, Note.d4, Note.c4, Note.b4],
      hoverTone: Note.g3,
    ),
    SubjectDefinition(
      index: 4,
      name: 'Arts',
      color: Color(0xFFEC407A),
      icon: Icons.palette,
      routeName: 'arts',
      pressJingle: [Note.f4, Note.a4, Note.c5, Note.d5],
      hoverTone: Note.f4,
    ),
    SubjectDefinition(
      index: 5,
      name: 'Physics',
      color: Color(0xFF3949AB),
      icon: Icons.science,
      routeName: 'physics',
      pressJingle: [Note.g3, Note.d4, Note.b4, Note.d5],
      hoverTone: Note.g3,
    ),
    SubjectDefinition(
      index: 6,
      name: 'Chemistry',
      color: Color(0xFF43A047),
      icon: Icons.biotech,
      routeName: 'chemistry',
      pressJingle: [Note.fs3, Note.cs4, Note.b4, Note.cs5],
      hoverTone: Note.fs3,
    ),
    SubjectDefinition(
      index: 7,
      name: 'Biology',
      color: Color(0xFF66BB6A),
      icon: Icons.eco,
      routeName: 'biology',
      pressJingle: [Note.e3, Note.b3, Note.g4, Note.d5],
      hoverTone: Note.e3,
    ),
    SubjectDefinition(
      index: 8,
      name: 'Mathematics',
      color: Color(0xFF5C6BC0),
      icon: Icons.calculate,
      routeName: 'mathematics',
      pressJingle: [Note.d4, Note.a4, Note.fs4, Note.cs5],
      hoverTone: Note.d4,
    ),
    SubjectDefinition(
      index: 9,
      name: 'Technology',
      color: Color(0xFFFFA726),
      icon: Icons.memory,
      routeName: 'technology',
      pressJingle: [Note.c4, Note.e4, Note.g4, Note.d5],
      hoverTone: Note.c4,
    ),
    SubjectDefinition(
      index: 10,
      name: 'Earth Science',
      color: Color(0xFF78909C),
      icon: Icons.terrain,
      routeName: 'earth-science',
      pressJingle: [Note.a3, Note.f4, Note.d4, Note.d5],
      hoverTone: Note.a3,
    ),
    SubjectDefinition(
      index: 11,
      name: 'Interactives',
      color: Color(0xFF00897B),
      icon: Icons.extension,
      routeName: 'interactives',
      pressJingle: [Note.a3, Note.cs4, Note.e4, Note.cs5],
      hoverTone: Note.a3,
    ),
  ];

  int currentPage = subjects.length * 10000;

  late final PageController _pageController = PageController(
    initialPage: subjects.length * 10000,
    viewportFraction: 1,
  );

  bool get isWideScreen =>
      MediaQuery.sizeOf(context).height < MediaQuery.sizeOf(context).width;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final isWideScreen =
        MediaQuery.sizeOf(context).height < MediaQuery.sizeOf(context).width;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: SafeArea(
        bottom: false,
        child: isWideScreen
            ? ListView(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                children: [
                  SelectionArea(child: _buildHeader()),
                  SizedBox(height: isWideScreen ? 32 : 64),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SelectionArea(
                          child: _buildSubjectColumn(context, 0),
                        ),
                      ),
                      SizedBox(
                        width:
                            math
                                .pow(
                                  MediaQuery.sizeOf(context).width /
                                      MediaQuery.sizeOf(context).height,
                                  1.95,
                                )
                                .toDouble() *
                            0.5 *
                            400,
                      ),
                      Expanded(
                        child: SelectionArea(
                          child: _buildSubjectColumn(context, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
                children: [
                  SelectionArea(child: _buildHeader()),
                  const SizedBox(height: 64),
                  for (final subject in subjects) ...[
                    SelectionArea(child: _buildSubjectCard(context, subject)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'F',
                style: TextStyle(color: Color(0xFFFF5252)),
              ),
              TextSpan(
                text: 'U',
                style: TextStyle(color: Color(0xFFFFC107)),
              ),
              TextSpan(
                text: 'N',
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
              TextSpan(
                text: 'P',
                style: TextStyle(color: Color(0xFF29B6F6)),
              ),
              TextSpan(
                text: 'E',
                style: TextStyle(color: Color(0xFF7E57C2)),
              ),
              TextSpan(
                text: 'D',
                style: TextStyle(color: Color(0xFFFF7043)),
              ),
              TextSpan(
                text: 'I',
                style: TextStyle(color: Color(0xFFEC407A)),
              ),
              TextSpan(
                text: 'A',
                style: TextStyle(color: Color(0xFF26A69A)),
              ),
            ],
          ),
          style: GoogleFonts.schoolbell(
            fontSize: isWideScreen ? 64 : 48,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(2, 3),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Text(
          "What would you like to learn about today?",
          style: TextStyle(
            fontSize: isWideScreen ? 20 : 16,
            fontWeight: FontWeight.w500,
            fontFamily: GoogleFonts.schoolbell().fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, SubjectDefinition subject) {
    return SubjectCard(
      context: context,
      subject: subject,
      isWideScreen: isWideScreen,
    );
  }

  Widget _buildSubjectColumn(BuildContext context, int columnIndex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isWideScreen ? 16 : 32),
        for (final subject in subjects)
          if (subject.index % 2 == columnIndex)
            _buildSubjectCard(context, subject),
      ],
    );
  }
}
