import 'package:flutter/material.dart';

const _subjectIcons = <String, IconData>{
  'account_balance': Icons.account_balance,
  'public': Icons.public,
  'psychology': Icons.psychology,
  'groups': Icons.groups,
  'palette': Icons.palette,
  'science': Icons.science,
  'biotech': Icons.biotech,
  'eco': Icons.eco,
  'calculate': Icons.calculate,
  'memory': Icons.memory,
  'terrain': Icons.terrain,
  'extension': Icons.extension,
};

const fallbackSubjectIcon = Icons.menu_book;

IconData iconForKey(String? key) => _subjectIcons[key] ?? fallbackSubjectIcon;
