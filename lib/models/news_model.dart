class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String category;
  final DateTime publishedAt;
  final String author;
  final bool isFavorite;

  NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.publishedAt,
    required this.author,
    required this.isFavorite,
  });

  NewsModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? imageUrl,
    String? category,
    DateTime? publishedAt,
    String? author,
    bool? isFavorite,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
