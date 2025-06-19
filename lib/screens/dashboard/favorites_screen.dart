import 'package:flutter/material.dart';
import 'package:tugasbesar/widgets/news_card.dart';
import '../../../models/news_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Sample favorite news data
  final List<NewsModel> _favoriteNews = [
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
      id: '4',
      title: 'Festival Budaya Nusantara Digelar di Jakarta',
      summary: 'Acara ini menampilkan keberagaman budaya dari 34 provinsi di Indonesia...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Lokal',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      author: 'Maya Sari',
      isFavorite: true,
    ),
  ];

  void _toggleFavorite(String newsId) {
    setState(() {
      _favoriteNews.removeWhere((news) => news.id == newsId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berita dihapus dari favorit'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Berita Favorit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search in favorites
            },
          ),
        ],
      ),
      body: _favoriteNews.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Berita Favorit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan berita ke favorit untuk\nmembacanya nanti',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home tab
              DefaultTabController.of(context)?.animateTo(0);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Jelajahi Berita'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red.shade400,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_favoriteNews.length} Berita Disimpan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final news = _favoriteNews[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: NewsCard(
                  news: news,
                  onFavoriteToggle: _toggleFavorite,
                ),
              );
            },
            childCount: _favoriteNews.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}
