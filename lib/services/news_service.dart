import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import 'websocket_service.dart';
import 'image_service.dart';

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
      summary: 'Kandidat dari kedua partai besar melakukan kampanye intensif menjelang hari pemungutan suara dengan berbagai strategi untuk menarik perhatian pemilih...',
      content: '''Pemilihan Presiden Amerika Serikat 2024 telah memasuki fase yang paling menentukan dengan hanya beberapa minggu tersisa sebelum hari pemungutan suara. Kedua kandidat utama dari Partai Demokrat dan Republik telah mengintensifkan kampanye mereka di negara-negara bagian kunci yang dianggap akan menentukan hasil akhir pemilihan.

Dalam beberapa minggu terakhir, kedua kubu telah menggelar berbagai acara kampanye besar-besaran di negara bagian swing states seperti Pennsylvania, Michigan, Wisconsin, Arizona, dan Georgia. Polling terbaru menunjukkan persaingan yang sangat ketat dengan margin yang sangat tipis antara kedua kandidat.

Isu-isu utama yang menjadi fokus kampanye meliputi ekonomi, kesehatan, imigrasi, dan kebijakan luar negeri. Kedua kandidat berusaha meyakinkan pemilih bahwa mereka memiliki visi dan rencana yang tepat untuk memimpin Amerika Serikat dalam empat tahun ke depan.

Para ahli politik memprediksi bahwa pemilihan kali ini akan menjadi salah satu yang paling kompetitif dalam sejarah Amerika Serikat. Tingkat partisipasi pemilih diperkirakan akan mencapai rekor tertinggi, dengan lebih dari 160 juta orang diproyeksikan akan memberikan suara mereka.

Sistem Electoral College yang unik di Amerika Serikat membuat setiap suara di negara bagian kunci menjadi sangat berharga. Kampanye kedua kubu telah mengalokasikan sumber daya yang besar untuk memobilisasi basis pendukung mereka dan meyakinkan pemilih yang masih ragu-ragu.

Hasil pemilihan ini tidak hanya akan mempengaruhi Amerika Serikat, tetapi juga akan berdampak signifikan terhadap politik global, hubungan internasional, dan ekonomi dunia. Dunia internasional sedang menunggu dengan penuh perhatian untuk melihat siapa yang akan memimpin negara adidaya ini dalam empat tahun ke depan.''',
      imageUrl: 'us_election',
      category: 'Internasional',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      author: 'John Smith',
      isFavorite: false,
      featuredImageUrl: '',
    ),
    NewsModel(
      id: '2',
      title: 'Pemerintah Indonesia Luncurkan Program Digitalisasi UMKM',
      summary: 'Program ini bertujuan untuk meningkatkan daya saing UMKM di era digital dengan memberikan pelatihan teknologi dan akses ke platform e-commerce...',
      content: '''Pemerintah Indonesia melalui Kementerian Koperasi dan UKM telah resmi meluncurkan program digitalisasi UMKM (Usaha Mikro, Kecil, dan Menengah) yang ambisius. Program ini dirancang untuk membantu jutaan pelaku UMKM di seluruh Indonesia agar dapat beradaptasi dengan era digital dan meningkatkan daya saing mereka di pasar global.

Program digitalisasi UMKM ini mencakup berbagai komponen penting, mulai dari pelatihan literasi digital, bantuan akses ke platform e-commerce, hingga dukungan teknologi finansial. Pemerintah telah mengalokasikan anggaran sebesar Rp 5 triliun untuk program ini dalam periode tiga tahun ke depan.

Menteri Koperasi dan UKM menyatakan bahwa program ini merupakan respons terhadap perubahan perilaku konsumen yang semakin digital, terutama setelah pandemi COVID-19. "UMKM harus mampu beradaptasi dengan teknologi digital agar tidak tertinggal dan dapat memanfaatkan peluang pasar yang lebih luas," ujar Menteri.

Salah satu fokus utama program ini adalah memberikan pelatihan kepada para pelaku UMKM tentang cara menggunakan platform digital untuk memasarkan produk mereka. Pelatihan ini akan mencakup penggunaan media sosial untuk marketing, pengelolaan toko online, dan strategi digital marketing yang efektif.

Selain itu, pemerintah juga akan memfasilitasi akses UMKM ke berbagai platform e-commerce besar seperti Tokopedia, Shopee, dan Bukalapak. Kerjasama dengan platform-platform ini diharapkan dapat membantu UMKM menjangkau konsumen yang lebih luas, tidak hanya di tingkat lokal tetapi juga nasional dan internasional.

Program ini juga akan memberikan dukungan dalam hal akses permodalan melalui teknologi finansial. Pemerintah bekerja sama dengan berbagai fintech lending untuk memberikan akses kredit yang lebih mudah dan cepat bagi UMKM yang membutuhkan modal untuk mengembangkan usaha mereka.

Target dari program ini adalah untuk mendigitalisasi setidaknya 10 juta UMKM dalam tiga tahun ke depan. Dengan digitalisasi ini, diharapkan kontribusi UMKM terhadap PDB Indonesia dapat meningkat dari 60% menjadi 65% pada tahun 2027.''',
      imageUrl: 'umkm_digital',
      category: 'Lokal',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      author: 'Siti Nurhaliza',
      isFavorite: true, featuredImageUrl: '',
    ),
    NewsModel(
      id: '3',
      title: 'Konflik di Timur Tengah Memasuki Fase Baru',
      summary: 'Upaya diplomatik internasional terus dilakukan untuk mencari solusi damai, sementara situasi kemanusiaan di wilayah tersebut semakin memburuk...',
      content: '''Konflik yang berkepanjangan di Timur Tengah telah memasuki fase baru yang lebih kompleks dengan melibatkan berbagai aktor regional dan internasional. Situasi ini menimbulkan keprihatinan mendalam dari komunitas internasional karena dampaknya terhadap stabilitas regional dan krisis kemanusiaan yang semakin memburuk.

Dalam perkembangan terbaru, berbagai upaya diplomatik telah diintensifkan oleh negara-negara besar dunia untuk mencari solusi damai. Perserikatan Bangsa-Bangsa (PBB) telah menggelar serangkaian pertemuan darurat untuk membahas eskalasi konflik dan mencari jalan keluar yang dapat diterima oleh semua pihak.

Sekretaris Jenderal PBB dalam pernyataannya menekankan pentingnya dialog dan negosiasi sebagai satu-satunya cara untuk menyelesaikan konflik yang telah berlangsung selama bertahun-tahun ini. "Kekerasan hanya akan melahirkan kekerasan baru. Kita harus kembali ke meja perundingan dan mencari solusi yang adil dan berkelanjutan," ujarnya.

Sementara itu, organisasi-organisasi kemanusiaan internasional melaporkan bahwa situasi kemanusiaan di wilayah konflik semakin memburuk. Jutaan warga sipil terpaksa mengungsi dari rumah mereka, dan akses terhadap kebutuhan dasar seperti makanan, air bersih, dan layanan kesehatan menjadi sangat terbatas.

Uni Eropa telah mengumumkan paket bantuan kemanusiaan tambahan senilai 500 juta euro untuk membantu para pengungsi dan korban konflik. Bantuan ini akan disalurkan melalui berbagai organisasi kemanusiaan internasional yang beroperasi di wilayah tersebut.

Amerika Serikat, Rusia, dan China sebagai anggota tetap Dewan Keamanan PBB juga telah mengadakan pertemuan trilateral untuk membahas langkah-langkah konkret yang dapat diambil untuk meredakan ketegangan. Meskipun memiliki perbedaan pendekatan, ketiga negara sepakat bahwa stabilitas di Timur Tengah sangat penting untuk perdamaian dunia.

Para ahli hubungan internasional menekankan bahwa penyelesaian konflik ini memerlukan pendekatan komprehensif yang tidak hanya mengatasi aspek keamanan, tetapi juga akar permasalahan ekonomi, sosial, dan politik yang mendasari konflik tersebut.''',
      imageUrl: 'middle_east',
      category: 'Internasional',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      author: 'Ahmad Rahman',
      isFavorite: false, featuredImageUrl: '',
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
        category: data['category'] ?? existingNews.category, imageUrl: '',
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
    
    // Find the news to get its images before deletion
    final newsToDelete = _allNews.firstWhere(
      (news) => news.id == newsId,
      orElse: () => NewsModel(
        id: newsId,
        title: '',
        summary: '',
        content: '',
        imageUrl: '',
        additionalImages: [],
        category: '',
        publishedAt: DateTime.now(),
        author: '',
        isFavorite: false, featuredImageUrl: '',
      ),
    );
    
    // Delete associated images
    if (newsToDelete.additionalImages.isNotEmpty) {
      ImageService().deleteMultipleImages(newsToDelete.additionalImages);
    }
    
    _allNews.removeWhere((news) => news.id == newsId);
    _userCreatedNews.removeWhere((news) => news.id == newsId);
    _favoriteNewsIds.remove(newsId);
    
    notifyListeners();
    
    if (kDebugMode) {
      print('Real-time: News and images deleted - $newsId');
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
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(isFavorite: isFavorite, imageUrl: '');
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
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(isFavorite: newFavoriteStatus, imageUrl: '');
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
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(isFavorite: !isFavorite, imageUrl: '');
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

  Future<void> cleanupNewsImages() async {
    try {
      final imageService = ImageService();
      final activeNewsIds = _allNews.map((news) => news.id).toList();
      await imageService.cleanupOrphanedImages(activeNewsIds);
      
      if (kDebugMode) {
        print('News images cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during image cleanup: $e');
      }
    }
  }

  @override
  void dispose() {
    _webSocketSubscription.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
