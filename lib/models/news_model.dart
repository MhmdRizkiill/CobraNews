class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl; // Main image URL (for backward compatibility)
  final List<String> additionalImages; // Additional local images
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
    this.additionalImages = const [],
    required this.category,
    required this.publishedAt,
    required this.author,
    required this.isFavorite,
  });

  // Get all images (main + additional)
  List<String> get allImages {
    final images = <String>[imageUrl];
    images.addAll(additionalImages);
    return images.where((img) => img.isNotEmpty).toList();
  }

  // Check if has local images
  bool get hasLocalImages {
    return additionalImages.isNotEmpty;
  }

  // Get primary display image
  String get primaryImage {
    if (additionalImages.isNotEmpty) {
      return additionalImages.first;
    }
    return imageUrl;
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? imageUrl,
    List<String>? additionalImages,
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
      additionalImages: additionalImages ?? this.additionalImages,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'category': category,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'isFavorite': isFavorite,
    };
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      additionalImages: List<String>.from(json['additionalImages'] ?? []),
      category: json['category'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      author: json['author'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
