import 'package:funpedia_admin/features/articles/domain/article_block.dart';

/// A single article revision: title plus an ordered list of blocks.
class Article {
  const Article({
    required this.subjectSlug,
    required this.topicSlug,
    required this.slug,
    required this.title,
    required this.blocks,
    this.revisionNumber = 1,
  });

  final String subjectSlug;
  final String topicSlug;
  final String slug;
  final String title;
  final List<ArticleBlock> blocks;
  final int revisionNumber;

  Map<String, dynamic> toJson() => {
    'title': title,
    'blocks': blocks.map((block) => block.toJson()).toList(),
  };
}
