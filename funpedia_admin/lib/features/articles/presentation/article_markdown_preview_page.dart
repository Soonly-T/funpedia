import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funpedia_admin/features/articles/data/article_markdown_serializer.dart';
import 'package:funpedia_admin/features/articles/domain/article.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';

/// Shows an [Article]'s rendered blocks next to its generated Markdown —
/// the starting point for the article-writing portal's editor/preview.
class ArticleMarkdownPreviewPage extends StatelessWidget {
  const ArticleMarkdownPreviewPage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final markdown = ArticleMarkdownSerializer.toMarkdown(article);
    final isWideScreen = MediaQuery.sizeOf(context).width > 900;

    final rendered = _RenderedArticle(article: article);
    final markdownPane = _MarkdownPane(markdown: markdown);

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SafeArea(
        child: isWideScreen
            ? Row(
                children: [
                  Expanded(child: rendered),
                  const VerticalDivider(width: 1),
                  Expanded(child: markdownPane),
                ],
              )
            : Column(
                children: [
                  Expanded(child: rendered),
                  const Divider(height: 1),
                  Expanded(child: markdownPane),
                ],
              ),
      ),
    );
  }
}

class _RenderedArticle extends StatelessWidget {
  const _RenderedArticle({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SelectionArea(
          child: Text(article.title, style: textTheme.headlineSmall),
        ),
        const SizedBox(height: 16),
        for (final block in article.blocks) ...[
          _blockPreview(context, block),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _blockPreview(BuildContext context, ArticleBlock block) {
    final textTheme = Theme.of(context).textTheme;

    return switch (block) {
      ParagraphBlock(:final text) => SelectionArea(
        child: Text(text, style: textTheme.bodyMedium),
      ),
      HeadingBlock(:final text) => SelectionArea(
        child: Text(text, style: textTheme.titleLarge),
      ),
      ImageBlock(:final assetId, :final caption) => _PlaceholderCard(
        icon: Icons.image_outlined,
        label: caption ?? assetId,
      ),
      VideoBlock(:final assetId) => _PlaceholderCard(
        icon: Icons.play_circle_outline,
        label: assetId,
      ),
      AudioBlock(:final assetId) => _PlaceholderCard(
        icon: Icons.audiotrack_outlined,
        label: assetId,
      ),
      InteractiveBlock(:final widgetId) => _PlaceholderCard(
        icon: Icons.extension_outlined,
        label: 'Interactive: $widgetId',
      ),
      DividerBlock() => const Divider(),
    };
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(label)),
    );
  }
}

class _MarkdownPane extends StatelessWidget {
  const _MarkdownPane({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text('Markdown', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: 'Copy Markdown',
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: markdown)),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              markdown,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
