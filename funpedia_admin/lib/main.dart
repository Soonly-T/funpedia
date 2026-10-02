import 'package:flutter/material.dart';
import 'package:funpedia_admin/features/articles/domain/article.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';
import 'package:funpedia_admin/features/articles/presentation/article_editor_page.dart';

void main() {
  runApp(const FunpediaAdminApp());
}

class FunpediaAdminApp extends StatelessWidget {
  const FunpediaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funpedia Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: ArticleEditorPage(initialArticle: _sampleArticle),
    );
  }
}

const _sampleArticle = Article(
  subjectSlug: 'history',
  topicSlug: 'ancient-civilizations',
  slug: 'mesopotamia',
  title: 'Mesopotamia',
  blocks: [
    ParagraphBlock(
      id: 'intro',
      text: 'Mesopotamia developed between the Tigris and Euphrates rivers.',
    ),
    ImageBlock(
      id: 'map',
      assetId: 'mesopotamia-map',
      caption: 'The Fertile Crescent',
    ),
    InteractiveBlock(
      id: 'timeline',
      widgetId: 'timeline',
      config: {
        'events': [
          {'year': -3500, 'label': 'First cities'},
        ],
      },
    ),
  ],
);
