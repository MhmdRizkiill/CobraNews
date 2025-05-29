import 'package:flutter/material.dart';

class AssetHelper {
  // Path constants untuk aset
  static const String _imagesPath = 'assets/images/';
  static const String _iconsPath = 'assets/icons/';
  
  // Logo paths
  static const String cobraLogo = '${_imagesPath}logo.png';
  static const String cobraLogoWhite = '${_imagesPath}logo_white.png';
  
  // Icon paths
  static const String newsIcon = '${_iconsPath}news_icon.png';
  static const String notificationIcon = '${_iconsPath}notification_icon.png';
  static const String shareIcon = '${_iconsPath}share_icon.png';
  
  // Method untuk memvalidasi aset
  static Widget buildImageWithFallback({
    required String assetPath,
    required Widget fallbackWidget,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return fallbackWidget;
        },
      ),
    );
  }
}
