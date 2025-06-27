class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String featuredImageUrl;
  final List<String> additionalImages; // Keep for local images
  final String category;
  final List<String> tags;
  final bool isPublished;
  final DateTime publishedAt;
  final String author;
  final bool isFavorite;

  NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.featuredImageUrl,
    this.additionalImages = const [],
    required this.category,
    this.tags = const [],
    this.isPublished = true,
    required this.publishedAt,
    required this.author,
    required this.isFavorite, required String imageUrl,
  });

  // Get all images (featured + additional)
  List<String> get allImages {
    final images = <String>[];
    if (featuredImageUrl.isNotEmpty) {
      images.add(featuredImageUrl);
    }
    images.addAll(additionalImages);
    return images.where((img) => img.isNotEmpty).toList();
  }

  // Check if has local images
  bool get hasLocalImages {
    return additionalImages.isNotEmpty;
  }

  // Get primary display image
  String get primaryImage {
    if (featuredImageUrl.isNotEmpty) {
      return featuredImageUrl;
    }
    if (additionalImages.isNotEmpty) {
      return additionalImages.first;
    }
    return '/placeholder.svg?height=200&width=300';
  }

  // Legacy imageUrl getter for backward compatibility
  String get imageUrl => featuredImageUrl;

  NewsModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? featuredImageUrl,
    List<String>? additionalImages,
    String? category,
    List<String>? tags,
    bool? isPublished,
    DateTime? publishedAt,
    String? author,
    bool? isFavorite, required String imageUrl,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      isFavorite: isFavorite ?? this.isFavorite, imageUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'featuredImageUrl': featuredImageUrl,
      'additionalImages': additionalImages,
      'category': category,
      'tags': tags,
      'isPublished': isPublished,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'isFavorite': isFavorite,
    };
  }

  // API format for creating/updating news
  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'featuredImageUrl': featuredImageUrl,
      'category': category,
      'tags': tags,
      'isPublished': isPublished,
    };
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      featuredImageUrl: json['featuredImageUrl'] as String? ?? '',
      additionalImages: List<String>.from(json['additionalImages'] ?? []),
      category: json['category'] as String? ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isPublished: json['isPublished'] as bool? ?? true,
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      author: json['author'] as String? ?? json['authorName'] as String? ?? 'Unknown',
      isFavorite: json['isFavorite'] as bool? ?? false, imageUrl: '',
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
