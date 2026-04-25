import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import 'package:ve_wallet/features/tips/data/repositories/tips_repository_impl.dart';
import 'package:ve_wallet/features/tips/domain/models/tip_article_model.dart';

final tipsRepositoryProvider = Provider<TipsRepositoryImpl>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return TipsRepositoryImpl(supabase);
});

final tipsProvider = FutureProvider<List<TipArticleModel>>((ref) {
  return ref.watch(tipsRepositoryProvider).getPublishedTips();
});
