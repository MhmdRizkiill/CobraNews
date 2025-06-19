import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tugasbesar/models/news_model.dart';
import 'websocket_service.dart';

class NewsService extends ChangeNotifier {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal() {
    _initializeService();
  }

  final WebSocketService _webSocketService = WebSocketService();
  late StreamSubscription _webSocketSubscription;

  final List<NewsModel> _allNews = [
    NewsModel(
      id: '1',
      title: 'Pemilu Presiden Amerika Serikat 2024 Memasuki Tahap Akhir',
      summary: 'Kandidat dari kedua partai besar melakukan kampanye intensif menjelang hari pemungutan suara...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Internasional',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      author: 'John Smith',
      isFavorite: false,
    ),
    NewsModel(
      id: '2',
      title: 'Pemerintah Indonesia Luncurkan Program Digitalisasi UMKM',
      summary: 'Program ini bertujuan untuk meningkatkan daya saing UMKM di era digital...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Lokal',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      author: 'Siti Nurhaliza',
      isFavorite: true,
    ),
    NewsModel(
      id: '3',
      title: 'Konflik di Timur Tengah Memasuki Fase Baru',
      summary: 'Upaya diplomatik internasional terus dilakukan untuk mencari solusi damai...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Internasional',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      author: 'Ahmad Rahman',
      isFavorite: false,
    ),
  ];

  final Set<String> _favoriteNewsIds = {'2'};
  final List<NewsModel> _userCreatedNews = [];

  List<NewsModel> get allNews => List.unmodifiable(_allNews);
  List<NewsModel> get favoriteNews => _allNews.where((news) => _favoriteNewsIds.contains(news.id)).toList();
  List<NewsModel> get userCreatedNews => List.unmodifiable(_userCreatedNews);

  void _initializeService() {
    _webSocketService.connect();
    _webSocketSubscription = _webSocketService.messageStream.listen(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'news_created':
        _handleNewsCreated(message['data']);
        break;
      case 'news_updated':
        _handleNewsUpdated(message['data']);
        break;
      case 'news_deleted':
        _handleNewsDeleted(message['data']);
        break;
      case 'favorite_updated':
        _handleFavoriteUpdated(message['data']);
        break;
    }
  }

  void _handleNewsCreated(Map<String, dynamic> data) {
    final news = NewsModel.fromJson(data);
    _allNews.insert(0, news);
    notifyListeners();
    
    if (kDebugMode) {
      print('Real-time: News created - ${news.title}');
    }
  }

  void _handleNewsUpdated(Map<String, dynamic> data) {
    final newsId = data['id'] as String;
    final index = _allNews.indexWhere((news) => news.id == newsId);
    
    if (index != -1) {
      final existingNews = _allNews[index];
      final updatedNews = existingNews.copyWith(
        title: data['title'] ?? existingNews.title,
        summary: data['summary'] ?? existingNews.summary,
        content: data['content'] ?? existingNews.content,
        category: data['category'] ?? existingNews.category,
      );
      
      _allNews[index] = updatedNews;
      
      // Update user created news if applicable
      final userNewsIndex = _userCreatedNews.indexWhere((news) => news.id == newsId);
      if (userNewsIndex != -1) {
        _userCreatedNews[userNewsIndex] = updatedNews;
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('Real-time: News updated - ${updatedNews.title}');
      }
    }
  }

  void _handleNewsDeleted(Map<String, dynamic> data) {
    final newsId = data['id'] as String;
    _allNews.removeWhere((news) => news.id == newsId);
    _userCreatedNews.removeWhere((news) => news.id == newsId);
    _favoriteNewsIds.remove(newsId);
    
    notifyListeners();
    
    if (kDebugMode) {
      print('Real-time: News deleted - $newsId');
    }
  }

  void _handleFavoriteUpdated(Map<String, dynamic> data) {
    final newsId = data['newsId'] as String;
    final isFavorite = data['isFavorite'] as bool;
    final userId = data['userId'] as String;
    
    // Only update if it's from current user or we want to show global favorites
    if (userId == 'current_user') {
      if (isFavorite) {
        _favoriteNewsIds.add(newsId);
      } else {
        _favoriteNewsIds.remove(newsId);
      }
      
      // Update the news item's favorite status
      final newsIndex = _allNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(isFavorite: isFavorite);
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('Real-time: Favorite ${isFavorite ? 'added' : 'removed'} - $newsId');
      }
    }
  }

  // CRUD Operations with Real-time sync
  Future<void> createNews(NewsModel news) async {
    try {
      // Add to local list immediately for optimistic update
      _userCreatedNews.insert(0, news);
      _allNews.insert(0, news);
      notifyListeners();

      // Send to server via WebSocket
      _webSocketService.sendMessage({
        'type': 'news_create',
        'data': news.toJson(),
      });

      if (kDebugMode) {
        print('News created locally and sent to server: ${news.title}');
      }
    } catch (e) {
      // Rollback on error
      _userCreatedNews.removeWhere((n) => n.id == news.id);
      _allNews.removeWhere((n) => n.id == news.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateNews(NewsModel updatedNews) async {
    try {
      // Update local lists immediately
      final allNewsIndex = _allNews.indexWhere((news) => news.id == updatedNews.id);
      final userNewsIndex = _userCreatedNews.indexWhere((news) => news.id == updatedNews.id);
      
      NewsModel? originalAllNews;
      NewsModel? originalUserNews;
      
      if (allNewsIndex != -1) {
        originalAllNews = _allNews[allNewsIndex];
        _allNews[allNewsIndex] = updatedNews;
      }
      
      if (userNewsIndex != -1) {
        originalUserNews = _userCreatedNews[userNewsIndex];
        _userCreatedNews[userNewsIndex] = updatedNews;
      }
      
      notifyListeners();

      // Send to server via WebSocket
      _webSocketService.sendMessage({
        'type': 'news_update',
        'data': updatedNews.toJson(),
      });

      if (kDebugMode) {
        print('News updated locally and sent to server: ${updatedNews.title}');
      }
    } catch (e) {
      // Rollback on error would go here
      rethrow;
    }
  }

  Future<void> deleteNews(String newsId) async {
    try {
      // Remove from local lists immediately
      final removedAllNews = _allNews.where((news) => news.id == newsId).toList();
      final removedUserNews = _userCreatedNews.where((news) => news.id == newsId).toList();
      
      _allNews.removeWhere((news) => news.id == newsId);
      _userCreatedNews.removeWhere((news) => news.id == newsId);
      _favoriteNewsIds.remove(newsId);
      notifyListeners();

      // Send to server via WebSocket
      _webSocketService.sendMessage({
        'type': 'news_delete',
        'data': {'id': newsId},
      });

      if (kDebugMode) {
        print('News deleted locally and sent to server: $newsId');
      }
    } catch (e) {
      // Rollback on error would go here
      rethrow;
    }
  }

  Future<void> toggleFavorite(String newsId) async {
    try {
      final isFavorite = _favoriteNewsIds.contains(newsId);
      final newFavoriteStatus = !isFavorite;
      
      // Update locally immediately
      if (newFavoriteStatus) {
        _favoriteNewsIds.add(newsId);
      } else {
        _favoriteNewsIds.remove(newsId);
      }
      
      // Update the news item
      final newsIndex = _allNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(isFavorite: newFavoriteStatus);
      }
      
      notifyListeners();

      // Send to server via WebSocket
      _webSocketService.sendMessage({
        'type': 'favorite_toggle',
        'data': {
          'newsId': newsId,
          'isFavorite': newFavoriteStatus,
        },
      });

      if (kDebugMode) {
        print('Favorite toggled locally and sent to server: $newsId -> $newFavoriteStatus');
      }
    } catch (e) {
      // Rollback on error
      final isFavorite = _favoriteNewsIds.contains(newsId);
      if (isFavorite) {
        _favoriteNewsIds.remove(newsId);
      } else {
        _favoriteNewsIds.add(newsId);
      }
      
      final newsIndex = _allNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(isFavorite: !isFavorite);
      }
      
      notifyListeners();
      rethrow;
    }
  }

  List<NewsModel> getNewsByCategory(String category) {
    if (category == 'Semua') {
      return allNews;
    }
    return allNews.where((news) => news.category == category).toList();
  }

  @override
  void dispose() {
    _webSocketSubscription.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
