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
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a block',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
          ),
          for (final kind in BlockKind.values)
            ListTile(
              leading: Icon(kind.icon),
              title: Text(kind.label),
              onTap: () => Navigator.of(sheetContext).pop(kind),
            ),
        ],
      ),
    ),
  );
}
