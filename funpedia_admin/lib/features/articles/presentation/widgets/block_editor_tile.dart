import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';
import 'package:funpedia_admin/features/articles/presentation/block_kind.dart';

/// A single editable row in the block editor: drag handle, inline fields
/// for that block's content, and a trailing delete/insert menu.
class BlockEditorTile extends StatefulWidget {
  const BlockEditorTile({
    super.key,
    required this.index,
    required this.block,
    required this.onChanged,
    required this.onDelete,
    required this.onAddBelow,
  });

  final int index;
  final ArticleBlock block;
  final ValueChanged<ArticleBlock> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onAddBelow;

  @override
  State<BlockEditorTile> createState() => _BlockEditorTileState();
}

class _BlockEditorTileState extends State<BlockEditorTile> {
  late final Map<String, TextEditingController> _controllers;
  bool _invalidInteractiveConfig = false;

  TextEditingController _controller(String field, String value) {
    final controller = _controllers.putIfAbsent(
      field,
      () => TextEditingController(text: value),
    );
    if (controller.text != value && !FocusScope.of(context).hasFocus) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    return controller;
  }

  @override
  void initState() {
    super.initState();
    _controllers = {};
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: const Padding(
              padding: EdgeInsets.only(top: 10, right: 4),
              child: Icon(Icons.drag_indicator, size: 18, color: Colors.grey),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(BlockKind.of(widget.block).icon, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          BlockKind.of(widget.block).label,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    _fieldsFor(context, widget.block),
                    if (_invalidInteractiveConfig)
                      Text(
                        'Config must be a JSON object',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: 'Insert block below',
            onPressed: widget.onAddBelow,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete block',
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _fieldsFor(BuildContext context, ArticleBlock block) {
    return switch (block) {
      ParagraphBlock(:final text) => _TextField(
        controller: _controller('text', text),
        hint: 'Write a paragraph…',
        maxLines: null,
        onChanged: (value) =>
            widget.onChanged(ParagraphBlock(id: block.id, text: value)),
      ),
      HeadingBlock(:final text, :final level) => Row(
        children: [
          Expanded(
            child: _TextField(
              controller: _controller('text', text),
              hint: 'Heading',
              style: Theme.of(context).textTheme.titleLarge,
              onChanged: (value) => widget.onChanged(
                HeadingBlock(id: block.id, text: value, level: level),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: level,
            items: const [1, 2, 3]
                .map((l) => DropdownMenuItem(value: l, child: Text('H$l')))
                .toList(),
            onChanged: (value) => widget.onChanged(
              HeadingBlock(id: block.id, text: text, level: value ?? level),
            ),
          ),
        ],
      ),
      ImageBlock(:final assetId, :final caption) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TextField(
            controller: _controller('assetId', assetId),
            hint: 'Image asset id',
            onChanged: (value) => widget.onChanged(
              ImageBlock(id: block.id, assetId: value, caption: caption),
            ),
          ),
          const SizedBox(height: 4),
          _TextField(
            controller: _controller('caption', caption ?? ''),
            hint: 'Caption (optional)',
            onChanged: (value) => widget.onChanged(
              ImageBlock(
                id: block.id,
                assetId: assetId,
                caption: value.isEmpty ? null : value,
              ),
            ),
          ),
        ],
      ),
      VideoBlock(:final assetId, :final posterAssetId) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TextField(
            controller: _controller('assetId', assetId),
            hint: 'Video asset id',
            onChanged: (value) => widget.onChanged(
              VideoBlock(
                id: block.id,
                assetId: value,
                posterAssetId: posterAssetId,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _TextField(
            controller: _controller('posterAssetId', posterAssetId ?? ''),
            hint: 'Poster asset id (optional)',
            onChanged: (value) => widget.onChanged(
              VideoBlock(
                id: block.id,
                assetId: assetId,
                posterAssetId: value.isEmpty ? null : value,
              ),
            ),
          ),
        ],
      ),
      AudioBlock(:final assetId) => _TextField(
        controller: _controller('assetId', assetId),
        hint: 'Audio asset id',
        onChanged: (value) =>
            widget.onChanged(AudioBlock(id: block.id, assetId: value)),
      ),
      InteractiveBlock(:final widgetId, :final config) => Column(
        children: [
          _TextField(
            controller: _controller('widgetId', widgetId),
            hint: 'Interactive widget id (e.g. solar-system)',
            onChanged: (value) => widget.onChanged(
              InteractiveBlock(id: block.id, widgetId: value, config: config),
            ),
          ),
          const SizedBox(height: 4),
          _TextField(
            controller: _controller(
              'config',
              const JsonEncoder.withIndent('  ').convert(config),
            ),
            hint: 'Configuration JSON',
            maxLines: 4,
            onChanged: (value) {
              try {
                final decoded = jsonDecode(value) as Map<String, dynamic>;
                setState(() => _invalidInteractiveConfig = false);
                widget.onChanged(
                  InteractiveBlock(
                    id: block.id,
                    widgetId: widgetId,
                    config: decoded,
                  ),
                );
              } on FormatException {
                setState(() => _invalidInteractiveConfig = true);
              } on TypeError {
                setState(() => _invalidInteractiveConfig = true);
              }
            },
          ),
        ],
      ),
      DividerBlock() => const Divider(height: 24),
    };
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.style,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}
