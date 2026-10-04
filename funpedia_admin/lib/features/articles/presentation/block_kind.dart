import 'package:flutter/material.dart';
import 'package:funpedia_admin/features/articles/domain/article_block.dart';

/// The addable block kinds shown in the Notion-style "add block" picker.
enum BlockKind {
  paragraph('Text', Icons.notes_outlined),
  heading('Heading', Icons.title),
  image('Image', Icons.image_outlined),
  video('Video', Icons.play_circle_outline),
  audio('Audio', Icons.audiotrack_outlined),
  interactive('Interactive', Icons.extension_outlined),
  divider('Divider', Icons.horizontal_rule);

  const BlockKind(this.label, this.icon);

  final String label;
  final IconData icon;

  ArticleBlock createBlock(String id) => switch (this) {
    BlockKind.paragraph => ParagraphBlock(id: id, text: ''),
    BlockKind.heading => HeadingBlock(id: id, text: ''),
    BlockKind.image => ImageBlock(id: id, assetId: ''),
    BlockKind.video => VideoBlock(id: id, assetId: ''),
    BlockKind.audio => AudioBlock(id: id, assetId: ''),
    BlockKind.interactive => InteractiveBlock(id: id, widgetId: ''),
    BlockKind.divider => DividerBlock(id: id),
  };

  static BlockKind of(ArticleBlock block) => switch (block) {
    ParagraphBlock() => BlockKind.paragraph,
    HeadingBlock() => BlockKind.heading,
    ImageBlock() => BlockKind.image,
    VideoBlock() => BlockKind.video,
    AudioBlock() => BlockKind.audio,
    InteractiveBlock() => BlockKind.interactive,
    DividerBlock() => BlockKind.divider,
  };
}

/// Opens a bottom sheet to pick a block type; returns null if dismissed.
Future<BlockKind?> pickBlockKind(BuildContext context) {
  return showModalBottomSheet<BlockKind>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const _BlockKindSheet(),
  );
}

class _BlockKindSheet extends StatefulWidget {
  const _BlockKindSheet();

  @override
  State<_BlockKindSheet> createState() => _BlockKindSheetState();
}

class _BlockKindSheetState extends State<_BlockKindSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = BlockKind.values
        .where(
          (kind) => kind.label.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add a block',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Find a block',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final kind = filtered[index];
                    return ListTile(
                      leading: Icon(kind.icon),
                      title: Text(kind.label),
                      onTap: () => Navigator.of(context).pop(kind),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
