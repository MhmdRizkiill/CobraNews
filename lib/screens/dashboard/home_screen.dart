import 'package:flutter/material.dart';
import 'package:tugasbesar/widgets/category_chip.dart';
import 'package:tugasbesar/widgets/news_card.dart';
import '../../../models/news_model.dart';
import '../../../utils/logo_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Internasional', 'Lokal'];

  // Sample news data
  final List<NewsModel> _allNews = [
    NewsModel(
      id: '1',
      title: 'Pemilu Presiden Amerika Serikat 2024 Memasuki Tahap Akhir',
      summary:
          'Kandidat dari kedua partai besar melakukan kampanye intensif menjelang hari pemungutan suara...',
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
      summary:
          'Program ini bertujuan untuk meningkatkan daya saing UMKM di era digital...',
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
      summary:
          'Upaya diplomatik internasional terus dilakukan untuk mencari solusi damai...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Internasional',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      author: 'Ahmad Rahman',
      isFavorite: false,
    ),
    NewsModel(
      id: '4',
      title: 'Festival Budaya Nusantara Digelar di Jakarta',
      summary:
          'Acara ini menampilkan keberagaman budaya dari 34 provinsi di Indonesia...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Lokal',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      author: 'Maya Sari',
      isFavorite: true,
    ),
    NewsModel(
      id: '5',
      title: 'Teknologi AI Terbaru Mengubah Industri Kesehatan Global',
      summary:
          'Inovasi dalam bidang artificial intelligence membawa revolusi dalam diagnosis medis...',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
      imageUrl: '/placeholder.svg?height=200&width=300',
      category: 'Internasional',
      publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
      author: 'Dr. Lisa Wang',
      isFavorite: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NewsModel> get _filteredNews {
    if (_selectedCategory == 'Semua') {
      return _allNews;
    }
    return _allNews
        .where((news) => news.category == _selectedCategory)
        .toList();
  }

  void _toggleFavorite(String newsId) {
    setState(() {
      final newsIndex = _allNews.indexWhere((news) => news.id == newsId);
      if (newsIndex != -1) {
        _allNews[newsIndex] = _allNews[newsIndex].copyWith(
          isFavorite: !_allNews[newsIndex].isFavorite,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/logoi.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.newspaper,
                              color: Color(0xFF1E3A8A),
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cobra News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
            ],
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori Berita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: category,
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Breaking News Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BREAKING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Berita Terkini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_filteredNews.isNotEmpty)
                    NewsCard(
                      news: _filteredNews.first,
                      onFavoriteToggle: _toggleFavorite,
                      isLarge: true,
                    ),
                ],
              ),
            ),
          ),

          // News List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Berita ${_selectedCategory == 'Semua' ? 'Terbaru' : _selectedCategory}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0)
                  return const SizedBox
                      .shrink(); // Skip first item (already shown as breaking news)

                final news = _filteredNews[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: NewsCard(
                    news: news,
                    onFavoriteToggle: _toggleFavorite,
                  ),
                );
              },
              childCount: _filteredNews.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
