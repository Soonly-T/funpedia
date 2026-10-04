import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funpedia_admin/features/articles/data/article_draft_store.dart';
import 'package:funpedia_admin/features/articles/data/article_markdown_serializer.dart';
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
  late final TextEditingController _subjectController;
  late final TextEditingController _topicController;
  late final TextEditingController _slugController;
  late List<ArticleBlock> _blocks;
  final _draftStore = ArticleDraftStore();
  Timer? _saveDebounce;
  int _nextBlockNumber = 0;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _saveError;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialArticle.title);
    _subjectController = TextEditingController(
      text: widget.initialArticle.subjectSlug,
    );
    _topicController = TextEditingController(
      text: widget.initialArticle.topicSlug,
    );
    _slugController = TextEditingController(text: widget.initialArticle.slug);
    _blocks = List.of(widget.initialArticle.blocks);
    _loadSavedDraft();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _slugController.dispose();
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedDraft() async {
    try {
      final saved = await _draftStore.load();
      if (!mounted || saved == null) return;
      setState(() {
        _titleController.text = saved.title;
        _subjectController.text = saved.subjectSlug;
        _topicController.text = saved.topicSlug;
        _slugController.text = saved.slug;
        _blocks = List.of(saved.blocks);
        _lastSaved = DateTime.now();
      });
    } on FormatException catch (error) {
      if (mounted) setState(() => _saveError = error.message);
    }
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    if (mounted) setState(() => _hasUnsavedChanges = true);
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (!mounted) return;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await _draftStore.save(_currentArticle);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
        _lastSaved = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = error.toString();
      });
    }
  }

  String _newBlockId() => 'block-${_nextBlockNumber++}';

  Article get _currentArticle => Article(
    subjectSlug: _subjectController.text.trim(),
    topicSlug: _topicController.text.trim(),
    slug: _slugController.text.trim(),
    title: _titleController.text,
    blocks: _blocks,
    revisionNumber: widget.initialArticle.revisionNumber,
  );

  void _updateBlockAt(int index, ArticleBlock block) {
    setState(() => _blocks[index] = block);
    _scheduleSave();
  }

  void _deleteBlockAt(int index) {
    setState(() => _blocks.removeAt(index));
    _scheduleSave();
  }

  Future<void> _insertBlockAt(int index) async {
    final kind = await pickBlockKind(context);
    if (kind == null) return;
    setState(() => _blocks.insert(index, kind.createBlock(_newBlockId())));
    _scheduleSave();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final block = _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, block);
    });
    _scheduleSave();
  }

  void _openMarkdownPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleMarkdownPreviewPage(article: _currentArticle),
      ),
    );
  }

  Future<void> _copyJson() async {
    await Clipboard.setData(
      ClipboardData(
        text: const JsonEncoder.withIndent(
          '  ',
        ).convert(_currentArticle.toJson()),
      ),
    );
    if (mounted) _showMessage('Article JSON copied');
  }

  Future<void> _copyMarkdown() async {
    await Clipboard.setData(
      ClipboardData(
        text: ArticleMarkdownSerializer.toMarkdown(_currentArticle),
      ),
    );
    if (mounted) _showMessage('Markdown copied');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _saveStatus {
    if (_saveError != null) return 'Save failed';
    if (_isSaving) return 'Saving locally…';
    if (_hasUnsavedChanges) return 'Unsaved changes';
    if (_lastSaved != null) return 'Saved locally';
    return 'Local draft';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titleController.text.trim().isEmpty
              ? 'New article'
              : _titleController.text.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: Text(
                _saveStatus,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _saveError != null
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            ),
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            tooltip: 'Save draft on this device',
            onPressed: _isSaving ? null : _saveDraft,
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview article',
            onPressed: _openMarkdownPreview,
          ),
          PopupMenuButton<String>(
            tooltip: 'Export',
            onSelected: (value) {
              if (value == 'markdown') unawaited(_copyMarkdown());
              if (value == 'json') unawaited(_copyJson());
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'markdown', child: Text('Copy Markdown')),
              PopupMenuItem(value: 'json', child: Text('Copy article JSON')),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(40, 28, 40, 100),
                  children: [
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Untitled article',
                      ),
                      onChanged: (_) {
                        setState(() {});
                        _scheduleSave();
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Draft · ${_blocks.length} blocks · local device storage',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetadataField(
                          icon: Icons.category_outlined,
                          label: 'Subject',
                          controller: _subjectController,
                          onChanged: _scheduleSave,
                        ),
                        _MetadataField(
                          icon: Icons.topic_outlined,
                          label: 'Topic',
                          controller: _topicController,
                          onChanged: _scheduleSave,
                        ),
                        _MetadataField(
                          icon: Icons.link,
                          label: 'Article slug',
                          controller: _slugController,
                          onChanged: _scheduleSave,
                        ),
                      ],
                    ),
                    if (_saveError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Draft save failed: $_saveError',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    if (_blocks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.edit_note,
                                size: 36,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 8),
                              const Text('Start writing with a block'),
                              TextButton.icon(
                                onPressed: () => _insertBlockAt(0),
                                icon: const Icon(Icons.add),
                                label: const Text('Add your first block'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: _blocks.length,
                        onReorder: _reorder,
                        itemBuilder: (context, index) {
                          final block = _blocks[index];
                          return BlockEditorTile(
                            key: ValueKey(block.id),
                            index: index,
                            block: block,
                            onChanged: (updated) =>
                                _updateBlockAt(index, updated),
                            onDelete: () => _deleteBlockAt(index),
                            onAddBelow: () => _insertBlockAt(index + 1),
                          );
                        },
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _insertBlockAt(_blocks.length),
                        icon: const Icon(Icons.add),
                        label: const Text('Add a block'),
                      ),
                    ),
                  ],
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

class _MetadataField extends StatelessWidget {
  const _MetadataField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18),
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => onChanged(),
    ),
  );
}
