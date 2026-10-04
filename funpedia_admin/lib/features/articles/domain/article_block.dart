/// Typed content blocks for an article revision. Canonical form is this
/// object graph (and its JSON), not Markdown — Markdown is export/import only.
sealed class ArticleBlock {
  const ArticleBlock(this.id);

  final String id;

  Map<String, dynamic> toJson();

  factory ArticleBlock.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return switch (json['type']) {
      'paragraph' => ParagraphBlock(
        id: id,
        text: json['text'] as String? ?? '',
      ),
      'heading' => HeadingBlock(
        id: id,
        text: json['text'] as String? ?? '',
        level: json['level'] as int? ?? 2,
      ),
      'image' => ImageBlock(
        id: id,
        assetId: json['assetId'] as String? ?? '',
        caption: json['caption'] as String?,
      ),
      'video' => VideoBlock(
        id: id,
        assetId: json['assetId'] as String? ?? '',
        posterAssetId: json['posterAssetId'] as String?,
      ),
      'audio' => AudioBlock(id: id, assetId: json['assetId'] as String? ?? ''),
      'interactive' => InteractiveBlock(
        id: id,
        widgetId: json['widgetId'] as String? ?? '',
        config: Map<String, dynamic>.from(
          json['config'] as Map<String, dynamic>? ?? const {},
        ),
      ),
      'divider' => DividerBlock(id: id),
      _ => throw FormatException('Unknown article block type: ${json['type']}'),
    };
  }
}

class ParagraphBlock extends ArticleBlock {
  const ParagraphBlock({required String id, required this.text}) : super(id);

  final String text;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'paragraph',
    'text': text,
  };
}

class HeadingBlock extends ArticleBlock {
  const HeadingBlock({required String id, required this.text, this.level = 2})
    : super(id);

  final String text;
  final int level;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'heading',
    'level': level,
    'text': text,
  };
}

class ImageBlock extends ArticleBlock {
  const ImageBlock({required String id, required this.assetId, this.caption})
    : super(id);

  final String assetId;
  final String? caption;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'image',
    'assetId': assetId,
    'caption': caption,
  };
}

class VideoBlock extends ArticleBlock {
  const VideoBlock({
    required String id,
    required this.assetId,
    this.posterAssetId,
  }) : super(id);

  final String assetId;
  final String? posterAssetId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'video',
    'assetId': assetId,
    'posterAssetId': posterAssetId,
  };
}

class AudioBlock extends ArticleBlock {
  const AudioBlock({required String id, required this.assetId}) : super(id);

  final String assetId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'audio',
    'assetId': assetId,
  };
}

/// References a trusted Flutter widget by [widgetId]; never carries code.
class InteractiveBlock extends ArticleBlock {
  const InteractiveBlock({
    required String id,
    required this.widgetId,
    this.config = const {},
  }) : super(id);

  final String widgetId;
  final Map<String, dynamic> config;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'interactive',
    'widgetId': widgetId,
    'config': config,
  };
}

class DividerBlock extends ArticleBlock {
  const DividerBlock({required String id}) : super(id);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'type': 'divider'};
}
