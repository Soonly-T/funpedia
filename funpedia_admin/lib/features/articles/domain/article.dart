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
    'subjectSlug': subjectSlug,
    'topicSlug': topicSlug,
    'slug': slug,
    'title': title,
    'revisionNumber': revisionNumber,
    'blocks': blocks.map((block) => block.toJson()).toList(),
  };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    subjectSlug: json['subjectSlug'] as String? ?? '',
    topicSlug: json['topicSlug'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    title: json['title'] as String? ?? '',
    revisionNumber: json['revisionNumber'] as int? ?? 1,
    blocks: (json['blocks'] as List<dynamic>? ?? const [])
        .map(
          (block) =>
              ArticleBlock.fromJson(Map<String, dynamic>.from(block as Map)),
        )
        .toList(),
  );
}
