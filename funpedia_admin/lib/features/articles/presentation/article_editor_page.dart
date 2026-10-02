import 'package:flutter/material.dart';
import 'package:funpedia_admin/features/articles/domain/article.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';
import 'package:funpedia_admin/features/articles/presentation/article_markdown_preview_page.dart';
import 'package:funpedia_admin/features/articles/presentation/block_kind.dart';
import 'package:funpedia_admin/features/articles/presentation/widgets/block_editor_tile.dart';

/// Notion-style block editor: editable title plus a reorderable list of
/// inline-editable blocks. This is the primary "write an article" surface.
class ArticleEditorPage extends StatefulWidget {
  const ArticleEditorPage({super.key, required this.initialArticle});

  final Article initialArticle;

  @override
  State<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends State<ArticleEditorPage> {
  late final TextEditingController _titleController;
  late List<ArticleBlock> _blocks;
  int _nextBlockNumber = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialArticle.title);
    _blocks = List.of(widget.initialArticle.blocks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _newBlockId() => 'block-${_nextBlockNumber++}';

  Article get _currentArticle => Article(
    subjectSlug: widget.initialArticle.subjectSlug,
    topicSlug: widget.initialArticle.topicSlug,
    slug: widget.initialArticle.slug,
    title: _titleController.text,
    blocks: _blocks,
    revisionNumber: widget.initialArticle.revisionNumber,
  );

  void _updateBlockAt(int index, ArticleBlock block) {
    setState(() => _blocks[index] = block);
  }

  void _deleteBlockAt(int index) {
    setState(() => _blocks.removeAt(index));
  }

  Future<void> _insertBlockAt(int index) async {
    final kind = await pickBlockKind(context);
    if (kind == null) return;
    setState(() => _blocks.insert(index, kind.createBlock(_newBlockId())));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final block = _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, block);
    });
  }

  void _openMarkdownPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleMarkdownPreviewPage(article: _currentArticle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview Markdown',
            onPressed: _openMarkdownPreview,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.headlineMedium,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Untitled article',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _blocks.length,
                  onReorder: _reorder,
                  itemBuilder: (context, index) {
                    final block = _blocks[index];
                    return BlockEditorTile(
                      key: ValueKey(block.id),
                      index: index,
                      block: block,
                      onChanged: (updated) => _updateBlockAt(index, updated),
                      onDelete: () => _deleteBlockAt(index),
                      onAddBelow: () => _insertBlockAt(index + 1),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _insertBlockAt(_blocks.length),
        icon: const Icon(Icons.add),
        label: const Text('Add block'),
      ),
    );
  }
}
