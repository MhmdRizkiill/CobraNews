import 'package:flutter/material.dart';

class NewsImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NewsImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  String _getLocalImagePath(String imageUrl) {
    // Map external URLs or IDs to local assets
    final imageMap = {
      '/placeholder.svg?height=200&width=300': 'assets/images/news/tech_breakthrough.png',
      'tech_breakthrough': 'assets/images/news/tech_breakthrough.png',
      'us_election': 'assets/images/news/us_election.png',
      'umkm_digital': 'assets/images/news/umkm_digital.png',
      'middle_east': 'assets/images/news/middle_east.png',
    };

    // Check if it's already a local path
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }

    // Try to find mapping
    for (final entry in imageMap.entries) {
      if (imageUrl.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default fallback
    return 'assets/images/news/tech_breakthrough.png';
  }

  @override
  Widget build(BuildContext context) {
    final localImagePath = _getLocalImagePath(imageUrl);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        localImagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gambar tidak tersedia',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
