import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../services/share_service.dart';
import '../../widgets/news_image_widget.dart';
import '../../widgets/share_bottom_sheet.dart';
import 'image_gallery_screen.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsModel news;

  const NewsDetailScreen({
    super.key,
    required this.news,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  bool _isAppBarExpanded = true;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isExpanded = _scrollController.hasClients && _scrollController.offset < 200;
    if (isExpanded != _isAppBarExpanded) {
      setState(() {
        _isAppBarExpanded = isExpanded;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      await _newsService.toggleFavorite(widget.news.id);

      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  widget.news.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(widget.news.isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: widget.news.isFavorite ? Colors.red : Colors.grey.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  void _shareNews() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ShareBottomSheet(news: widget.news),
      ),
    );
  }

  void _showImageGallery(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          images: images,
          initialIndex: initialIndex,
          newsTitle: widget.news.title,
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Galeri Gambar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${images.length} foto',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageGallery(images, index),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildGalleryImageWidget(images[index], index == 0),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImageWidget(String imagePath, bool isPrimary) {
    Widget imageWidget;

    if (imagePath.startsWith('http') || imagePath.contains('yasa.png')) {
      imageWidget = NewsImageWidget(
        imageUrl: imagePath,
        fit: BoxFit.cover,
      );
    } else {
      final file = File(imagePath);
      imageWidget = Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.broken_image,
              color: Colors.grey.shade400,
            ),
          );
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        if (isPrimary)
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Utama',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _newsService,
        builder: (context, child) {
          // Get updated news data
          final updatedNews = _newsService.allNews.firstWhere((n) => n.id == widget.news.id, orElse: () => widget.news);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF1E3A8A),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: _shareNews,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              updatedNews.isFavorite ? Icons.favorite : Icons.favorite_outline,
                              key: ValueKey(updatedNews.isFavorite),
                              color: updatedNews.isFavorite ? Colors.red : Colors.white,
                            ),
                          ),
                          onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                        ),
                        if (_isTogglingFavorite)
                          const Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image
                      NewsImageWidget(
                        imageUrl: updatedNews.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Category and Live Badge
                      Positioned(
                        top: 100,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: updatedNews.category == 'Lokal' ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                updatedNews.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Article Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Article Header
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  updatedNews.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Summary
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    updatedNews.summary,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Author and Date Info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFF1E3A8A),
                                      child: Text(
                                        updatedNews.author.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            updatedNews.author,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDate(updatedNews.publishedAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.sync_alt,
                                            size: 12,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Real-time',
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.grey.shade200,
                          ),

                          // Article Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Artikel Lengkap',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  updatedNews.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.6,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Add this after the article content and before the tags section
                                if (updatedNews.allImages.length > 1) _buildImageGallery(updatedNews.allImages),

                                // Tags Section
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildTag('#${updatedNews.category.toLowerCase()}'),
                                    _buildTag('#berita'),
                                    _buildTag('#cobranews'),
                                    if (updatedNews.category == 'Internasional') _buildTag('#dunia'),
                                    if (updatedNews.category == 'Lokal') _buildTag('#indonesia'),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _shareNews,
                                        icon: const Icon(Icons.share),
                                        label: const Text('Bagikan'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF1E3A8A),
                                          side: const BorderSide(
                                            color: Color(0xFF1E3A8A),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                                        icon: _isTogglingFavorite
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                updatedNews.isFavorite ? Icons.favorite : Icons.favorite_outline,
                                              ),
                                        label: Text(
                                          updatedNews.isFavorite ? 'Tersimpan' : 'Simpan',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: updatedNews.isFavorite ? Colors.red : const Color(0xFF1E3A8A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withOpacity(0.3),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
