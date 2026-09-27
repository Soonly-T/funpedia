import 'package:flutter/material.dart';
import 'package:funpedia_user/features/home/widgets/back_button.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';

class SubMenu extends StatefulWidget {
  final String subject;
  final String routeName;
  final Color color;
  final IconData icon;
  final List<MusicalNote> pressJingle;
  const SubMenu({
    super.key,
    required this.subject,
    required this.routeName,
    required this.color,
    required this.icon,
    required this.pressJingle,
  });

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
  @override
  Widget build(BuildContext context) {
    final topics = SubMenu.topicsBySubject[widget.subject] ?? const <String>[];
    bool isWideScreen =
        MediaQuery.sizeOf(context).height < MediaQuery.sizeOf(context).width;

    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: Text(
      //     subject,
      //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
      //       color: Colors.white,
      //       fontWeight: FontWeight.w700,
      //       fontSize: 24,
      //     ),
      //   ),
      //   backgroundColor: color,
      // ),
      body: Column(
        children: [
          Container(
            height: isWideScreen
                ? MediaQuery.sizeOf(context).height * 0.2
                : MediaQuery.sizeOf(context).height * 0.3,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(color: widget.color),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: isWideScreen ? 64 : 32,
                ),
                SelectionArea(
                  child: Text(
                    widget.subject,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width < 600
                    ? 2
                    : width < 900
                    ? 3
                    : width < 1200
                    ? 4
                    : width < 1600
                    ? 5
                    : 6;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectionContainer.disabled(
                      child: CustomBackButton(
                        isWideScreen: isWideScreen,
                        color: widget.color,
                        pressJingle: widget.pressJingle,
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: widget.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.icon,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                    const SizedBox(height: 12),
                                    SelectionArea(
                                      child: Text(
                                        topics[index],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
