import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import 'api_service.dart';
import 'websocket_service.dart';

class EnhancedNewsService extends ChangeNotifier {
  static final EnhancedNewsService _instance = EnhancedNewsService._internal();
  factory EnhancedNewsService() => _instance;
  EnhancedNewsService._internal() {
    _initializeService();
  }

  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();
  late StreamSubscription _webSocketSubscription;

  // Cache for better performance
  final List<NewsModel> _cachedNews = [];
  final List<NewsModel> _cachedFavorites = [];
  final Set<String> _favoriteNewsIds = {};
  
  // Loading states
  bool _isLoadingNews = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingSearch = false;
  
  // Error states
  String? _lastError;
  
  // Search debouncing
  Timer? _searchDebounceTimer;
  String _lastSearchQuery = '';
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreNews = true;
  
  // Getters
  List<NewsModel> get allNews => List.unmodifiable(_cachedNews);
  List<NewsModel> get favoriteNews => List.unmodifiable(_cachedFavorites);
  Set<String> get favoriteNewsIds => Set.unmodifiable(_favoriteNewsIds);
  bool get isLoadingNews => _isLoadingNews;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get lastError => _lastError;
  bool get hasMoreNews => _hasMoreNews;

  void _initializeService() {
    _webSocketService.connect();
    _webSocketSubscription = _webSocketService.messageStream.listen(_handleWebSocketMessage);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadNews(refresh: true),
      loadFavoriteNews(refresh: true),
    ]);
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
    try {
      final news = NewsModel.fromJson(data);
      _cachedNews.insert(0, news);
      notifyListeners();
      
      if (kDebugMode) {
        print('Real-time: News created - ${news.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling news created: $e');
      }
    }
  }

  void _handleNewsUpdated(Map<String, dynamic> data) {
    try {
      final newsId = data['id'] as String;
      final index = _cachedNews.indexWhere((news) => news.id == newsId);
      
      if (index != -1) {
        final updatedNews = NewsModel.fromJson(data);
        _cachedNews[index] = updatedNews;
        
        // Update favorites cache if needed
        final favIndex = _cachedFavorites.indexWhere((news) => news.id == newsId);
        if (favIndex != -1) {
          _cachedFavorites[favIndex] = updatedNews;
        }
        
        notifyListeners();
        
        if (kDebugMode) {
          print('Real-time: News updated - ${updatedNews.title}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling news updated: $e');
      }
    }
  }

  void _handleNewsDeleted(Map<String, dynamic> data) {
    try {
      final newsId = data['id'] as String;
      
      _cachedNews.removeWhere((news) => news.id == newsId);
      _cachedFavorites.removeWhere((news) => news.id == newsId);
      _favoriteNewsIds.remove(newsId);
      
      notifyListeners();
      
      if (kDebugMode) {
        print('Real-time: News deleted - $newsId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling news deleted: $e');
      }
    }
  }

  void _handleFavoriteUpdated(Map<String, dynamic> data) {
    try {
      final newsId = data['newsId'] as String;
      final isFavorite = data['isFavorite'] as bool;
      
      if (isFavorite) {
        _favoriteNewsIds.add(newsId);
        // Add to favorites cache if not already there
        final news = _cachedNews.firstWhere(
          (news) => news.id == newsId,
          orElse: () => NewsModel(
            id: newsId,
            title: '',
            summary: '',
            content: '',
            imageUrl: '',
            category: '',
            publishedAt: DateTime.now(),
            author: '',
            isFavorite: true, featuredImageUrl: '',
          ),
        );
        if (!_cachedFavorites.any((fav) => fav.id == newsId)) {
          _cachedFavorites.insert(0, news.copyWith(isFavorite: true, imageUrl: news.imageUrl));
        }
      } else {
        _favoriteNewsIds.remove(newsId);
        _cachedFavorites.removeWhere((news) => news.id == newsId);
      }
      
      // Update the news item's favorite status in main cache
      final newsIndex = _cachedNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _cachedNews[newsIndex] = _cachedNews[newsIndex].copyWith(
          isFavorite: isFavorite,
          imageUrl: _cachedNews[newsIndex].imageUrl,
        );
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('Real-time: Favorite ${isFavorite ? 'added' : 'removed'} - $newsId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling favorite updated: $e');
      }
    }
  }

  // Load news with pagination
  Future<void> loadNews({
    bool refresh = false,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (_isLoadingNews) return;

    try {
      _isLoadingNews = true;
      _lastError = null;
      
      if (refresh) {
        _currentPage = 1;
        _hasMoreNews = true;
        _cachedNews.clear();
      }

      notifyListeners();

      final news = await _apiService.getAllNews(
        page: _currentPage,
        limit: 20,
        category: category,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (refresh) {
        _cachedNews.clear();
      }

      _cachedNews.addAll(news);
      
      // Update favorite status
      for (int i = 0; i < _cachedNews.length; i++) {
        if (_favoriteNewsIds.contains(_cachedNews[i].id)) {
          _cachedNews[i] = _cachedNews[i].copyWith(isFavorite: true, imageUrl: _cachedNews[i].imageUrl);
        }
      }

      _hasMoreNews = news.length >= 20;
      if (_hasMoreNews) {
        _currentPage++;
      }

    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error loading news: $e');
      }
    } finally {
      _isLoadingNews = false;
      notifyListeners();
    }
  }

  // Load favorite news
  Future<void> loadFavoriteNews({bool refresh = false}) async {
    if (_isLoadingFavorites) return;

    try {
      _isLoadingFavorites = true;
      _lastError = null;
      notifyListeners();

      final favorites = await _apiService.getFavoriteNews();
      
      if (refresh) {
        _cachedFavorites.clear();
        _favoriteNewsIds.clear();
      }

      _cachedFavorites.addAll(favorites);
      _favoriteNewsIds.addAll(favorites.map((news) => news.id));

    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  // Search news with debouncing
  Future<List<NewsModel>> searchNews({
    required String query,
    String? category,
    String? author,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    // Cancel previous search timer
    _searchDebounceTimer?.cancel();
    
    // Return cached results if query hasn't changed
    if (query == _lastSearchQuery && query.isNotEmpty) {
      return _getLocalSearchResults(query, category: category);
    }

    final completer = Completer<List<NewsModel>>();
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        _isLoadingSearch = true;
        _lastError = null;
        _lastSearchQuery = query;
        notifyListeners();

        if (query.isEmpty) {
          _isLoadingSearch = false;
          notifyListeners();
          completer.complete([]);
          return;
        }

        final results = await _apiService.searchNews(
          query: query,
          category: category,
          author: author,
          startDate: startDate,
          endDate: endDate,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        // Update favorite status for search results
        for (int i = 0; i < results.length; i++) {
          if (_favoriteNewsIds.contains(results[i].id)) {
            results[i] = results[i].copyWith(isFavorite: true, imageUrl: results[i].imageUrl);
          }
        }

        _isLoadingSearch = false;
        notifyListeners();
        completer.complete(results);

      } catch (e) {
        _lastError = e.toString();
        _isLoadingSearch = false;
        notifyListeners();
        
        if (kDebugMode) {
          print('Error searching news: $e');
        }
        
        // Fallback to local search
        final localResults = _getLocalSearchResults(query, category: category);
        completer.complete(localResults);
      }
    });

    return completer.future;
  }

  // Local search fallback
  List<NewsModel> _getLocalSearchResults(String query, {String? category}) {
    if (query.isEmpty) return [];
    
    final searchLower = query.toLowerCase();
    var results = _cachedNews.where((news) {
      return news.title.toLowerCase().contains(searchLower) ||
             news.summary.toLowerCase().contains(searchLower) ||
             news.content.toLowerCase().contains(searchLower) ||
             news.author.toLowerCase().contains(searchLower);
    }).toList();

    if (category != null && category != 'Semua') {
      results = results.where((news) => news.category == category).toList();
    }

    return results;
  }

  // Search favorites
  Future<List<NewsModel>> searchFavorites(String query) async {
    if (query.isEmpty) return _cachedFavorites;

    try {
      _isLoadingSearch = true;
      notifyListeners();

      final results = await _apiService.getFavoriteNews(search: query);
      
      _isLoadingSearch = false;
      notifyListeners();
      
      return results;
    } catch (e) {
      _isLoadingSearch = false;
      notifyListeners();
      
      if (kDebugMode) {
        print('Error searching favorites: $e');
      }
      
      // Fallback to local search
      final searchLower = query.toLowerCase();
      return _cachedFavorites.where((news) {
        return news.title.toLowerCase().contains(searchLower) ||
               news.summary.toLowerCase().contains(searchLower) ||
               news.content.toLowerCase().contains(searchLower) ||
               news.author.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String newsId) async {
    try {
      final isFavorite = _favoriteNewsIds.contains(newsId);
      final newFavoriteStatus = !isFavorite;
      
      // Optimistic update
      if (newFavoriteStatus) {
        _favoriteNewsIds.add(newsId);
        final news = _cachedNews.firstWhere((news) => news.id == newsId);
        _cachedFavorites.insert(0, news.copyWith(isFavorite: true, imageUrl: news.imageUrl));
      } else {
        _favoriteNewsIds.remove(newsId);
        _cachedFavorites.removeWhere((news) => news.id == newsId);
      }
      
      // Update news item
      final newsIndex = _cachedNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _cachedNews[newsIndex] = _cachedNews[newsIndex].copyWith(
          isFavorite: newFavoriteStatus,
          imageUrl: _cachedNews[newsIndex].imageUrl,
        );
      }
      
      notifyListeners();

      // Send to API
      if (newFavoriteStatus) {
        await _apiService.addToFavorites(newsId);
      } else {
        await _apiService.removeFromFavorites(newsId);
      }

      if (kDebugMode) {
        print('Favorite toggled: $newsId -> $newFavoriteStatus');
      }
    } catch (e) {
      // Rollback on error
      final isFavorite = _favoriteNewsIds.contains(newsId);
      if (isFavorite) {
        _favoriteNewsIds.remove(newsId);
        _cachedFavorites.removeWhere((news) => news.id == newsId);
      } else {
        _favoriteNewsIds.add(newsId);
        final news = _cachedNews.firstWhere((news) => news.id == newsId);
        _cachedFavorites.insert(0, news.copyWith(isFavorite: true, imageUrl: ''));
      }
      
      final newsIndex = _cachedNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _cachedNews[newsIndex] = _cachedNews[newsIndex].copyWith(isFavorite: !isFavorite, imageUrl: '');
      }
      
      notifyListeners();
      
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error toggling favorite: $e');
      }
      rethrow;
    }
  }

  // Get news by category
  List<NewsModel> getNewsByCategory(String category, {bool publishedOnly = true}) {
    var filteredNews = _cachedNews;
    
    if (publishedOnly) {
      filteredNews = filteredNews.where((news) => news.isPublished).toList();
    }
    
    if (category == 'Semua') {
      return filteredNews;
    }
    
    return filteredNews.where((news) => news.category == category).toList();
  }

  // Create news
  Future<NewsModel> createNews(NewsModel news) async {
    try {
      final createdNews = await _apiService.createNews(news);
      _cachedNews.insert(0, createdNews);
      notifyListeners();
      
      if (kDebugMode) {
        print('News created successfully: ${createdNews.title}');
      }
      
      return createdNews;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error creating news: $e');
      }
      rethrow;
    }
  }

  // Update news
  Future<NewsModel> updateNews(NewsModel news) async {
    try {
      final updatedNews = await _apiService.updateNews(news.id, news);
      
      final index = _cachedNews.indexWhere((n) => n.id == news.id);
      if (index != -1) {
        _cachedNews[index] = updatedNews;
      }
      
      final favIndex = _cachedFavorites.indexWhere((n) => n.id == news.id);
      if (favIndex != -1) {
        _cachedFavorites[favIndex] = updatedNews;
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('News updated successfully: ${updatedNews.title}');
      }
      
      return updatedNews;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error updating news: $e');
      }
      rethrow;
    }
  }

  // Delete news
  Future<void> deleteNews(String id) async {
    try {
      await _apiService.deleteNews(id);
      
      _cachedNews.removeWhere((news) => news.id == id);
      _cachedFavorites.removeWhere((news) => news.id == id);
      _favoriteNewsIds.remove(id);
      
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error deleting news: $e');
      }
      rethrow;
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      return ['Semua', 'Internasional', 'Lokal', 'Teknologi', 'Olahraga', 'Ekonomi'];
    }
  }

  // Get authors
  Future<List<String>> getAuthors() async {
    try {
      return await _apiService.getAuthors();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching authors: $e');
      }
      return ['Semua'];
    }
  }

  // Check API health
  Future<bool> checkApiHealth() async {
    return await _apiService.checkApiHealth();
  }

  // Clear cache
  void clearCache() {
    _cachedNews.clear();
    _cachedFavorites.clear();
    _favoriteNewsIds.clear();
    _currentPage = 1;
    _hasMoreNews = true;
    _lastError = null;
    notifyListeners();
  }

  // Get user created news (filter by author)
  List<NewsModel> get userCreatedNews {
    return _cachedNews.where((news) => news.author == 'Saya').toList();
  }

  // Get published news only
  List<NewsModel> get publishedNews {
    return _cachedNews.where((news) => news.isPublished).toList();
  }

  // Get draft news only
  List<NewsModel> get draftNews {
    return _cachedNews.where((news) => !news.isPublished).toList();
  }

  // Search by tags
  List<NewsModel> searchByTags(List<String> tags) {
    if (tags.isEmpty) return _cachedNews;
    
    return _cachedNews.where((news) {
      return tags.any((tag) => news.tags.any((newsTag) => 
          newsTag.toLowerCase().contains(tag.toLowerCase())));
    }).toList();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _webSocketSubscription.cancel();
    _webSocketService.dispose();
    _apiService.dispose();
    super.dispose();
  }
}
