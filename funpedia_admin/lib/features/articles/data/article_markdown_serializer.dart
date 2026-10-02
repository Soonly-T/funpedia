import 'dart:convert';

import 'package:funpedia_admin/features/articles/domain/article.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';

/// Converts an [Article]'s block document to its Markdown export form.
/// This is export/import only — the block JSON stays canonical.
abstract final class ArticleMarkdownSerializer {
  static String toMarkdown(Article article) {
    final buffer = StringBuffer('# ${article.title}\n\n');

    for (final block in article.blocks) {
      buffer.writeln(_blockToMarkdown(block));
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }

  static String _blockToMarkdown(ArticleBlock block) {
    return switch (block) {
      ParagraphBlock(:final text) => text,
      HeadingBlock(:final text, :final level) => '${'#' * level} $text',
      ImageBlock(:final assetId, :final caption) =>
        '![${caption ?? ''}](asset://$assetId)',
      VideoBlock(:final assetId, :final posterAssetId) => [
        ':::video',
        'asset: $assetId',
        if (posterAssetId != null) 'poster: $posterAssetId',
        ':::',
      ].join('\n'),
      AudioBlock(:final assetId) => [
        ':::audio',
        'asset: $assetId',
        ':::',
      ].join('\n'),
      InteractiveBlock(:final widgetId, :final config) => [
        ':::interactive{widget="$widgetId"}',
        const JsonEncoder.withIndent('  ').convert(config),
        ':::',
      ].join('\n'),
      DividerBlock() => '---',
    };
  }
}
