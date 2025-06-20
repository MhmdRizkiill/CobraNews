import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../widgets/enhanced_news_card.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;
  final Function(String) onFavoriteToggle;
  final VoidCallback? onTap;
  final bool isLarge;

  const NewsCard({
    super.key,
    required this.news,
    required this.onFavoriteToggle,
    this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedNewsCard(
      news: news,
      onFavoriteToggle: onFavoriteToggle,
      onTap: onTap,
      isLarge: isLarge,
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
