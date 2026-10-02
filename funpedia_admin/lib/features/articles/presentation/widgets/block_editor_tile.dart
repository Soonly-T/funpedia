import 'package:flutter/material.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';

/// A single editable row in the block editor: drag handle, inline fields
/// for that block's content, and a trailing delete/insert menu.
class BlockEditorTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(top: 10, right: 4),
              child: Icon(Icons.drag_indicator, size: 18, color: Colors.grey),
            ),
          ),
          Expanded(child: _fieldsFor(context, block)),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: 'Insert block below',
            onPressed: onAddBelow,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete block',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _fieldsFor(BuildContext context, ArticleBlock block) {
    return switch (block) {
      ParagraphBlock(:final text) => _TextField(
        value: text,
        hint: 'Write a paragraph…',
        maxLines: null,
        onChanged: (value) =>
            onChanged(ParagraphBlock(id: block.id, text: value)),
      ),
      HeadingBlock(:final text, :final level) => Row(
        children: [
          Expanded(
            child: _TextField(
              value: text,
              hint: 'Heading',
              style: Theme.of(context).textTheme.titleLarge,
              onChanged: (value) => onChanged(
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
            onChanged: (value) => onChanged(
              HeadingBlock(id: block.id, text: text, level: value ?? level),
            ),
          ),
        ],
      ),
      ImageBlock(:final assetId, :final caption) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TextField(
            value: assetId,
            hint: 'Image asset id',
            onChanged: (value) => onChanged(
              ImageBlock(id: block.id, assetId: value, caption: caption),
            ),
          ),
          const SizedBox(height: 4),
          _TextField(
            value: caption ?? '',
            hint: 'Caption (optional)',
            onChanged: (value) => onChanged(
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
            value: assetId,
            hint: 'Video asset id',
            onChanged: (value) => onChanged(
              VideoBlock(
                id: block.id,
                assetId: value,
                posterAssetId: posterAssetId,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _TextField(
            value: posterAssetId ?? '',
            hint: 'Poster asset id (optional)',
            onChanged: (value) => onChanged(
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
        value: assetId,
        hint: 'Audio asset id',
        onChanged: (value) =>
            onChanged(AudioBlock(id: block.id, assetId: value)),
      ),
      InteractiveBlock(:final widgetId) => _TextField(
        value: widgetId,
        hint: 'Interactive widget id (e.g. solar-system)',
        onChanged: (value) =>
            onChanged(InteractiveBlock(id: block.id, widgetId: value)),
      ),
      DividerBlock() => const Divider(height: 24),
    };
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.style,
    this.maxLines = 1,
  });

  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
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
