import 'dart:convert';

import 'package:funpedia_admin/features/articles/domain/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleDraftStore {
  static const _draftKey = 'article-draft-v1';

  Future<void> save(Article article) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_draftKey, jsonEncode(article.toJson()));
  }

  Future<Article?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_draftKey);
    if (saved == null) return null;

    final decoded = jsonDecode(saved);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved article draft is not a JSON object.');
    }
    return Article.fromJson(decoded);
  }
}
