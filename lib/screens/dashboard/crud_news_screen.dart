import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../services/image_service.dart';
import '../../widgets/image_picker_widget.dart';

class CrudNewsScreen extends StatefulWidget {
  const CrudNewsScreen({super.key});

  @override
  State<CrudNewsScreen> createState() => _CrudNewsScreenState();
}

class _CrudNewsScreenState extends State<CrudNewsScreen> {
  final NewsService _newsService = NewsService();

  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'Lokal';
    List<String> selectedImages = [];

    showDialog(
      context: context, 
      useRootNavigator: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Tambah Berita Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      ImagePickerWidget(
                        onImagesChanged: (images) {
                          selectedImages = images;
                        },
                        maxImages: 5,
                        allowMultiple: true,
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Berita',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: summaryController,
                        decoration: const InputDecoration(
                          labelText: 'Ringkasan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.summarize),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Konten Berita',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.article),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: ['Lokal', 'Internasional'].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategory = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isNotEmpty &&
                              summaryController.text.isNotEmpty &&
                              contentController.text.isNotEmpty) {

                            final newsId = DateTime.now().millisecondsSinceEpoch.toString();

                            // Save images to app directory
                            List<String> savedImagePaths = [];
                            if (selectedImages.isNotEmpty) {
                              try {
                                final imageService = ImageService();
                                final tempFiles = selectedImages.map((path) => File(path)).toList();
                                savedImagePaths = await imageService.saveMultipleImagesToAppDirectory(tempFiles, newsId);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error menyimpan gambar: ${e.toString()}'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }

                            final news = NewsModel(
                              id: newsId,
                              title: titleController.text,
                              summary: summaryController.text,
                              content: contentController.text,
                              imageUrl: savedImagePaths.isNotEmpty ? savedImagePaths.first : '/placeholder.svg?height=200&width=300',
                              additionalImages: savedImagePaths,
                              category: selectedCategory,
                              publishedAt: DateTime.now(),
                              author: 'Saya',
                              isFavorite: false,
                            );

                            try {
                              await _newsService.createNews(news);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Berita berhasil ditambahkan${savedImagePaths.isNotEmpty ? ' dengan ${savedImagePaths.length} gambar' : ''}!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mohon lengkapi semua field yang diperlukan'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editNews(NewsModel news) {
    final titleController = TextEditingController(text: news.title);
    final summaryController = TextEditingController(text: news.summary);
    final contentController = TextEditingController(text: news.content);
    String selectedCategory = news.category;
    List<String> selectedImages = List.from(news.additionalImages);

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Berita',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      ImagePickerWidget(
                        initialImages: selectedImages,
                        onImagesChanged: (images) {
                          selectedImages = images;
                        },
                        maxImages: 5,
                        allowMultiple: true,
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Berita',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: summaryController,
                        decoration: const InputDecoration(
                          labelText: 'Ringkasan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.summarize),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Konten Berita',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.article),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: ['Lokal', 'Internasional'].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategory = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isNotEmpty &&
                              summaryController.text.isNotEmpty &&
                              contentController.text.isNotEmpty) {

                            // Handle image updates
                            List<String> finalImagePaths = [];

                            // Process new images (those that are not saved yet)
                            final newImages = selectedImages.where((path) => !path.contains('news_images')).toList();
                            if (newImages.isNotEmpty) {
                              try {
                                final imageService = ImageService();
                                final tempFiles = newImages.map((path) => File(path)).toList();
                                final savedPaths = await imageService.saveMultipleImagesToAppDirectory(tempFiles, news.id);
                                finalImagePaths.addAll(savedPaths);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error menyimpan gambar baru: ${e.toString()}'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }

                            // Keep existing images that are still selected
                            final existingImages = selectedImages.where((path) => path.contains('news_images')).toList();
                            finalImagePaths.addAll(existingImages);

                            // Delete removed images
                            final removedImages = news.additionalImages.where((path) => !selectedImages.contains(path)).toList();
                            if (removedImages.isNotEmpty) {
                              final imageService = ImageService();
                              await imageService.deleteMultipleImages(removedImages);
                            }

                            final updatedNews = news.copyWith(
                              title: titleController.text,
                              summary: summaryController.text,
                              content: contentController.text,
                              category: selectedCategory,
                              imageUrl: finalImagePaths.isNotEmpty ? finalImagePaths.first : news.imageUrl,
                              additionalImages: finalImagePaths,
                            );

                            try {
                              await _newsService.updateNews(updatedNews);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.update, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Berita berhasil diupdate${finalImagePaths.isNotEmpty ? ' dengan ${finalImagePaths.length} gambar' : ''}!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mohon lengkapi semua field yang diperlukan'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNews(String newsId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Berita'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus berita ini? Semua gambar yang terkait juga akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Find the news to get its images
                final newsToDelete = _newsService.allNews.firstWhere((news) => news.id == newsId);

                // Delete associated images
                if (newsToDelete.additionalImages.isNotEmpty) {
                  final imageService = ImageService();
                  await imageService.deleteMultipleImages(newsToDelete.additionalImages);
                }

                await _newsService.deleteNews(newsId);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Berita dan gambar berhasil dihapus!'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Kelola Berita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Real-time CRUD',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _newsService,
        builder: (context, child) {
          final userNews = _newsService.userCreatedNews;

          if (userNews.isEmpty) {
            return _buildEmptyState();
          }

          return _buildNewsList(userNews);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNewsDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Berita'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Berita',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai tulis berita pertama Anda\nPerubahan akan tersinkronisasi secara real-time',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List userNews) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.article,
                  color: Color(0xFF1E3A8A),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${userNews.length} Berita Saya',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sync,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Auto-sync',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final news = userNews[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                color: news.category == 'Lokal'
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                news.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: news.category == 'Lokal'
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    size: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editNews(news);
                                } else if (value == 'delete') {
                                  _deleteNews(news.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news.summary,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(news.publishedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
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
                                  const SizedBox(width: 2),
                                  Text(
                                    'Synced',
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
                ),
              );
            },
            childCount: userNews.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
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
