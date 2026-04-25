import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/tips/domain/models/tip_article_model.dart';

class TipsRepositoryImpl {
  final SupabaseClient _client;

  TipsRepositoryImpl(this._client);

  Future<List<TipArticleModel>> getPublishedTips() async {
    final rows = await _client
        .from('tips_articles')
        .select()
        .eq('is_published', true)
        .order('published_at', ascending: false)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(TipArticleModel.fromJson)
        .toList();
  }
}
