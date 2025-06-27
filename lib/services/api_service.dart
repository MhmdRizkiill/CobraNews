import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';

class ApiService {
  static const String baseUrl = 'http://45.149.187.204:3000';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client with timeout
  final http.Client _client = http.Client();

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Generic GET request
  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      
      if (kDebugMode) {
        print('API GET: $uri');
      }

      final response = await _client.get(uri, headers: _headers).timeout(timeoutDuration);
      
      if (kDebugMode) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('API GET Error: $e');
      }
      throw ApiException('Failed to fetch data: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      if (kDebugMode) {
        print('API POST: $uri');
        print('API POST Data: ${jsonEncode(data)}');
      }

      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(timeoutDuration);

      if (kDebugMode) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('API POST Error: $e');
      }
      throw ApiException('Failed to post data: $e');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      if (kDebugMode) {
        print('API PUT: $uri');
        print('API PUT Data: ${jsonEncode(data)}');
      }

      final response = await _client.put(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('API PUT Error: $e');
      }
      throw ApiException('Failed to update data: $e');
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> _delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      if (kDebugMode) {
        print('API DELETE: $uri');
      }

      final response = await _client.delete(uri, headers: _headers).timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('API DELETE Error: $e');
      }
      throw ApiException('Failed to delete data: $e');
    }
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        'API Error ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // News API endpoints using the provided API structure
  Future<List<NewsModel>> getAllNews({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await _get('/api/author/news');
      
      // Handle different response structures
      List<dynamic> newsData;
      if (response['data'] != null) {
        newsData = response['data'] as List<dynamic>;
      } else if (response['news'] != null) {
        newsData = response['news'] as List<dynamic>;
      } else if (response is List) {
        newsData = response as List;
      } else {
        newsData = [];
      }

      var newsList = newsData.map((json) => NewsModel.fromJson(json)).toList();

      // Apply client-side filtering if needed
      if (category != null && category != 'Semua') {
        newsList = newsList.where((news) => news.category.toLowerCase() == category.toLowerCase()).toList();
      }

      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        newsList = newsList.where((news) {
          return news.title.toLowerCase().contains(searchLower) ||
                 news.summary.toLowerCase().contains(searchLower) ||
                 news.content.toLowerCase().contains(searchLower) ||
                 news.tags.any((tag) => tag.toLowerCase().contains(searchLower));
        }).toList();
      }

      // Apply sorting
      if (sortBy != null) {
        switch (sortBy) {
          case 'date':
            newsList.sort((a, b) => sortOrder == 'asc' 
                ? a.publishedAt.compareTo(b.publishedAt)
                : b.publishedAt.compareTo(a.publishedAt));
            break;
          case 'title':
            newsList.sort((a, b) => sortOrder == 'asc'
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title));
            break;
          case 'category':
            newsList.sort((a, b) => sortOrder == 'asc'
                ? a.category.compareTo(b.category)
                : b.category.compareTo(a.category));
            break;
        }
      } else {
        // Default sort by date (newest first)
        newsList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      }

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      if (startIndex >= newsList.length) {
        return [];
      }
      
      return newsList.sublist(
        startIndex, 
        endIndex > newsList.length ? newsList.length : endIndex
      );

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching news: $e');
      }
      return [];
    }
  }

  Future<List<NewsModel>> searchNews({
    required String query,
    String? category,
    String? author,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Use the same endpoint but apply search filtering
      final response = await _get('/api/author/news');
      
      List<dynamic> newsData;
      if (response['data'] != null) {
        newsData = response['data'] as List<dynamic>;
      } else if (response['news'] != null) {
        newsData = response['news'] as List<dynamic>;
      } else if (response is List) {
        newsData = response as List;
      } else {
        newsData = [];
      }

      var newsList = newsData.map((json) => NewsModel.fromJson(json)).toList();

      // Apply search filter
      if (query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        newsList = newsList.where((news) {
          return news.title.toLowerCase().contains(searchLower) ||
                 news.summary.toLowerCase().contains(searchLower) ||
                 news.content.toLowerCase().contains(searchLower) ||
                 news.author.toLowerCase().contains(searchLower) ||
                 news.tags.any((tag) => tag.toLowerCase().contains(searchLower));
        }).toList();
      }

      // Apply additional filters
      if (category != null && category != 'Semua') {
        newsList = newsList.where((news) => news.category.toLowerCase() == category.toLowerCase()).toList();
      }

      if (author != null && author != 'Semua') {
        newsList = newsList.where((news) => news.author.toLowerCase() == author.toLowerCase()).toList();
      }

      if (startDate != null) {
        newsList = newsList.where((news) => news.publishedAt.isAfter(startDate)).toList();
      }

      if (endDate != null) {
        newsList = newsList.where((news) => news.publishedAt.isBefore(endDate.add(const Duration(days: 1)))).toList();
      }

      // Apply sorting
      if (sortBy != null) {
        switch (sortBy) {
          case 'date':
            newsList.sort((a, b) => sortOrder == 'asc' 
                ? a.publishedAt.compareTo(b.publishedAt)
                : b.publishedAt.compareTo(a.publishedAt));
            break;
          case 'title':
            newsList.sort((a, b) => sortOrder == 'asc'
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title));
            break;
          case 'relevance':
            // Sort by relevance (how many times the search term appears)
            newsList.sort((a, b) {
              final aRelevance = _calculateRelevance(a, query);
              final bRelevance = _calculateRelevance(b, query);
              return sortOrder == 'asc' 
                  ? aRelevance.compareTo(bRelevance)
                  : bRelevance.compareTo(aRelevance);
            });
            break;
        }
      } else {
        // Default sort by relevance for search
        newsList.sort((a, b) {
          final aRelevance = _calculateRelevance(a, query);
          final bRelevance = _calculateRelevance(b, query);
          return bRelevance.compareTo(aRelevance);
        });
      }

      return newsList;

    } catch (e) {
      if (kDebugMode) {
        print('Error searching news: $e');
      }
      return [];
    }
  }

  int _calculateRelevance(NewsModel news, String query) {
    final searchLower = query.toLowerCase();
    int relevance = 0;
    
    // Title matches are more important
    relevance += news.title.toLowerCase().split(' ').where((word) => word.contains(searchLower)).length * 3;
    
    // Summary matches
    relevance += news.summary.toLowerCase().split(' ').where((word) => word.contains(searchLower)).length * 2;
    
    // Content matches
    relevance += news.content.toLowerCase().split(' ').where((word) => word.contains(searchLower)).length;
    
    // Tag matches
    relevance += news.tags.where((tag) => tag.toLowerCase().contains(searchLower)).length * 2;
    
    return relevance;
  }

  Future<NewsModel> getNewsById(String id) async {
    final response = await _get('/api/author/news/$id');
    
    Map<String, dynamic> newsData;
    if (response['data'] != null) {
      newsData = response['data'];
    } else {
      newsData = response;
    }
    
    return NewsModel.fromJson(newsData);
  }

  Future<NewsModel> createNews(NewsModel news) async {
    final response = await _post('/api/author/news', news.toApiJson());
    
    Map<String, dynamic> newsData;
    if (response['data'] != null) {
      newsData = response['data'];
    } else {
      newsData = response;
    }
    
    return NewsModel.fromJson(newsData);
  }

  Future<NewsModel> updateNews(String id, NewsModel news) async {
    final response = await _put('/api/author/news/$id', news.toApiJson());
    
    Map<String, dynamic> newsData;
    if (response['data'] != null) {
      newsData = response['data'];
    } else {
      newsData = response;
    }
    
    return NewsModel.fromJson(newsData);
  }

  Future<void> deleteNews(String id) async {
    await _delete('/api/author/news/$id');
  }

  // Favorites API endpoints
  Future<List<NewsModel>> getFavoriteNews({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    try {
      final response = await _get('/api/favorites', queryParams: queryParams);
      
      List<dynamic> newsData;
      if (response['data'] != null) {
        newsData = response['data'] as List<dynamic>;
      } else if (response['favorites'] != null) {
        newsData = response['favorites'] as List<dynamic>;
      } else if (response is List) {
        newsData = response as List;
      } else {
        newsData = [];
      }

      return newsData.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching favorites: $e');
      }
      return [];
    }
  }

  Future<void> addToFavorites(String newsId) async {
    await _post('/api/favorites', {'newsId': newsId});
  }

  Future<void> removeFromFavorites(String newsId) async {
    await _delete('/api/favorites/$newsId');
  }

  // Categories API - extract from news data
  Future<List<String>> getCategories() async {
    try {
      final response = await _get('/api/author/news');
      
      List<dynamic> newsData;
      if (response['data'] != null) {
        newsData = response['data'] as List<dynamic>;
      } else if (response['news'] != null) {
        newsData = response['news'] as List<dynamic>;
      } else if (response is List) {
        newsData = response as List;
      } else {
        newsData = [];
      }

      final categories = <String>{'Semua'};
      for (final item in newsData) {
        if (item['category'] != null && item['category'].toString().isNotEmpty) {
          categories.add(item['category'].toString());
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      return ['Semua', 'Internasional', 'Lokal', 'Teknologi', 'Olahraga', 'Ekonomi'];
    }
  }

  // Authors API - extract from news data
  Future<List<String>> getAuthors() async {
    try {
      final response = await _get('/api/author/news');
      
      List<dynamic> newsData;
      if (response['data'] != null) {
        newsData = response['data'] as List<dynamic>;
      } else if (response['news'] != null) {
        newsData = response['news'] as List<dynamic>;
      } else if (response is List) {
        newsData = response as List;
      } else {
        newsData = [];
      }

      final authors = <String>{'Semua'};
      for (final item in newsData) {
        if (item['author'] != null && item['author'].toString().isNotEmpty) {
          authors.add(item['author'].toString());
        } else if (item['authorName'] != null && item['authorName'].toString().isNotEmpty) {
          authors.add(item['authorName'].toString());
        }
      }

      return authors.toList()..sort();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching authors: $e');
      }
      return ['Semua'];
    }
  }

  // Dashboard activities API
  Future<List<Map<String, dynamic>>> getDashboardActivities({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    try {
      final response = await _get('/api/dashboard/activities', queryParams: queryParams);
      
      List<dynamic> activitiesData;
      if (response['data'] != null) {
        activitiesData = response['data'] as List<dynamic>;
      } else if (response['activities'] != null) {
        activitiesData = response['activities'] as List<dynamic>;
      } else if (response is List) {
        activitiesData = response as List;
      } else {
        activitiesData = [];
      }

      return activitiesData.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dashboard activities: $e');
      }
      return [];
    }
  }

  // Notifications API
  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isRead,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (isRead != null) {
      queryParams['isRead'] = isRead.toString();
    }

    try {
      final response = await _get('/api/notifications', queryParams: queryParams);
      
      List<dynamic> notificationsData;
      if (response['data'] != null) {
        notificationsData = response['data'] as List<dynamic>;
      } else if (response['notifications'] != null) {
        notificationsData = response['notifications'] as List<dynamic>;
      } else if (response is List) {
        notificationsData = response as List;
      } else {
        notificationsData = [];
      }

      return notificationsData.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notifications: $e');
      }
      return [];
    }
  }

  // Health check
  Future<bool> checkApiHealth() async {
    try {
      final response = await _get('/api/health');
      return response['status'] == 'ok' || response['healthy'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('API health check failed: $e');
      }
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
