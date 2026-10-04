import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';
import 'package:funpedia_user/features/home/presentation/article_placeholder_page.dart';
import 'package:funpedia_user/features/home/widgets/back_button.dart';

class SubMenu extends StatefulWidget {
  const SubMenu({
    super.key,
    required this.subject,
    required this.slug,
    required this.color,
    required this.icon,
    required this.pressJingle,
  });

  final String subject;
  final String slug;
  final Color color;
  final IconData icon;
  final List<MusicalNote> pressJingle;

  static const topicsBySubject = <String, List<String>>{
    'History': [
      'Ancient civilizations',
      'Medieval history',
      'Modern history',
      'Historical figures',
    ],
    'Geography': [
      'Continents and oceans',
      'Countries and capitals',
      'Landforms',
      'Climate and weather',
    ],
    'Philosophy': [
      'Logic and reasoning',
      'Ethics',
      'Knowledge',
      'Philosophers',
    ],
    'Society': ['Communities', 'Culture', 'Government', 'Social change'],
    'Arts': ['Painting', 'Sculpture', 'Music', 'Theater and film'],
    'Physics': ['Motion and forces', 'Energy', 'Light and sound', 'Space'],
    'Chemistry': [
      'Atoms and elements',
      'Chemical reactions',
      'Materials',
      'Chemistry in daily life',
    ],
    'Biology': ['Cells', 'Plants', 'Animals', 'The human body'],
    'Mathematics': ['Numbers', 'Geometry', 'Algebra', 'Probability'],
    'Technology': ['Computers', 'The internet', 'Robotics', 'Inventions'],
    'Earth Science': [
      'Geology',
      'Rocks and minerals',
      'Earthquakes and volcanoes',
      'Oceans and atmosphere',
      'Weather and climate',
      'Natural disasters',
      'Environmental issues',
      'Space and astronomy',
    ],
    'Interactives': [
      'Virtual experiments',
      'Interactive timelines',
      'Explore a concept',
      'Build and discover',
    ],
  };

  @override
  State<SubMenu> createState() => _SubMenuState();
}

class _SubMenuState extends State<SubMenu> {
  static const _drawerMaxWidth = 384.0;
  static const _expandedPanelWidth = 320.0;
  static const _collapsedPanelWidth = 80.0;

  bool _isPanelExpanded = true;

  void _openTopic(String topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticlePlaceholderPage(
          subject: widget.subject,
          topic: topic,
          color: widget.color,
          icon: widget.icon,
        ),
      ),
    );
  }

  Widget _buildSubjectHeader(
    BuildContext context, {
    required bool compact,
    bool showTitle = true,
    Widget? action,
  }) {
    return Container(
      height: compact ? 160 : MediaQuery.sizeOf(context).height * 0.26,
      width: double.infinity,
      color: widget.color,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: compact ? 56 : 64),
                if (showTitle)
                  SelectionArea(
                    child: Text(
                      widget.subject,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) Positioned(top: 8, left: 8, child: action),
        ],
      ),
    );
  }

  Widget _buildTopicNavigation(
    BuildContext context,
    List<String> topics, {
    required bool expanded,
    required bool inDrawer,
    VoidCallback? onTogglePanel,
  }) {
    return SafeArea(
      child: Column(
        children: [
          if (!inDrawer)
            _buildSubjectHeader(
              context,
              compact: true,
              showTitle: expanded,
              action: IconButton(
                tooltip: expanded
                    ? 'Collapse topics panel'
                    : 'Expand topics panel',
                icon: Icon(
                  expanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white,
                ),
                onPressed: onTogglePanel,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SelectionContainer.disabled(
              child: expanded
                  ? CustomBackButton(
                      isWideScreen: true,
                      color: widget.color,
                      pressJingle: widget.pressJingle,
                      onBack: () {
                        if (inDrawer) Scaffold.of(context).closeDrawer();
                        Navigator.of(context).pop();
                      },
                    )
                  : IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                expanded ? 12 : 8,
                8,
                expanded ? 12 : 8,
                20,
              ),
              itemCount: topics.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final topic = topics[index];
                final content = expanded
                    ? Row(
                        children: [
                          Icon(widget.icon, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              topic,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Tooltip(
                          message: topic,
                          child: Icon(widget.icon, color: Colors.white),
                        ),
                      );
                return Card(
                  color: widget.color,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (inDrawer) Navigator.of(context).pop();
                      _openTopic(topic);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: expanded ? 12 : 8,
                        vertical: 14,
                      ),
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid(List<String> topics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const tileSize = 128.0;
        const gap = 12.0;
        const padding = 20.0;
        const labelHeight = 48.0;
        const labelGap = 8.0;
        const rowExtent = tileSize + labelGap + labelHeight;
        final usableWidth = math.max(0.0, constraints.maxWidth - 2 * padding);
        final columns = math
            .max(1, ((usableWidth + gap) / (tileSize + gap)).floor())
            .toInt();
        final rowCount = (topics.length / columns).ceil();

        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: rowExtent,
          ),
          itemCount: rowCount * columns,
          itemBuilder: (context, index) {
            if (index >= topics.length) return const SizedBox.shrink();

            return Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openTopic(topics[index]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: tileSize,
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 2,
                        color: widget.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: labelGap),
                    SizedBox(
                      height: labelHeight,
                      child: Center(
                        child: SelectionArea(
                          child: Text(
                            topics[index],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = SubMenu.topicsBySubject[widget.subject] ?? const <String>[];
    final screenSize = MediaQuery.sizeOf(context);
    final isWideScreen = screenSize.width > screenSize.height;

    return Scaffold(
      drawer: isWideScreen
          ? null
          : Drawer(
              width: math.min(screenSize.width, _drawerMaxWidth),
              child: Builder(
                builder: (drawerContext) => _buildTopicNavigation(
                  drawerContext,
                  topics,
                  expanded: true,
                  inDrawer: true,
                ),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (isWideScreen)
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      width: _isPanelExpanded
                          ? _expandedPanelWidth
                          : _collapsedPanelWidth,
                      child: _buildTopicNavigation(
                        context,
                        topics,
                        expanded: _isPanelExpanded,
                        inDrawer: false,
                        onTogglePanel: () => setState(
                          () => _isPanelExpanded = !_isPanelExpanded,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildTopicGrid(topics)),
                  ],
                ),
              )
            else ...[
              _buildSubjectHeader(
                context,
                compact: false,
                action: Builder(
                  builder: (buttonContext) => IconButton(
                    tooltip: 'Open topics',
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(buttonContext).openDrawer(),
                  ),
                ),
              ),
              Expanded(child: _buildTopicGrid(topics)),
            ],
          ],
        ),
      ),
    );
  }
}
