import 'package:flutter/material.dart';

class ArticlePlaceholderPage extends StatelessWidget {
  const ArticlePlaceholderPage({
    super.key,
    required this.subject,
    required this.topic,
    required this.color,
    required this.icon,
  });

  final String subject;
  final String topic;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 24,
              vertical: 40,
            ),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Icon(icon, size: 28, color: color),
                  const SizedBox(width: 12),
                  Text(
                    subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(topic, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 20),
              const SelectionArea(
                child: Text(
                  'This article is being prepared. Check back soon for the full explanation, media, and related interactive content.',
                  style: TextStyle(fontSize: 18, height: 1.6),
                ),
              ),
              const SizedBox(height: 36),
              Icon(Icons.auto_stories_outlined, size: 56, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
