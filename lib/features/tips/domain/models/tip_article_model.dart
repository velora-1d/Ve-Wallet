class TipArticleModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String accentColor;
  final int readingMinutes;
  final String? coverUrl;
  final DateTime? publishedAt;
  final DateTime createdAt;

  const TipArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.accentColor,
    required this.readingMinutes,
    required this.coverUrl,
    required this.publishedAt,
    required this.createdAt,
  });

  factory TipArticleModel.fromJson(Map<String, dynamic> json) {
    return TipArticleModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '-',
      summary: json['summary'] as String? ?? '-',
      content: json['content'] as String? ?? '-',
      category: json['category'] as String? ?? 'Tips',
      accentColor: json['accent_color'] as String? ?? '#2563EB',
      readingMinutes: (json['reading_minutes'] as num?)?.toInt() ?? 3,
      coverUrl: json['cover_url'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
