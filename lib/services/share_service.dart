import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/news_model.dart';

class ShareService {
  static const String appName = 'Cobra News';
  static const String appUrl = 'https://cobranews.app'; // Replace with actual app URL
  
  // Share to WhatsApp specifically
  static Future<void> shareToWhatsApp(NewsModel news, {String? phoneNumber}) async {
    try {
      final shareText = _formatNewsForWhatsApp(news);
      final encodedText = Uri.encodeComponent(shareText);
      
      String whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Share to specific contact
        whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedText';
      } else {
        // Open WhatsApp with pre-filled message
        whatsappUrl = 'https://wa.me/?text=$encodedText';
      }
      
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'WhatsApp tidak terinstall atau tidak dapat dibuka';
      }
    } catch (e) {
      throw 'Gagal membagikan ke WhatsApp: ${e.toString()}';
    }
  }
  
  // Share to WhatsApp Business
  static Future<void> shareToWhatsAppBusiness(NewsModel news, {String? phoneNumber}) async {
    try {
      final shareText = _formatNewsForWhatsApp(news);
      final encodedText = Uri.encodeComponent(shareText);
      
      String whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        whatsappUrl = 'https://api.whatsapp.com/send?phone=$phoneNumber&text=$encodedText';
      } else {
        whatsappUrl = 'https://api.whatsapp.com/send?text=$encodedText';
      }
      
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'WhatsApp Business tidak terinstall atau tidak dapat dibuka';
      }
    } catch (e) {
      throw 'Gagal membagikan ke WhatsApp Business: ${e.toString()}';
    }
  }
  
  // General share (system share sheet)
  static Future<void> shareNews(NewsModel news, {Rect? sharePositionOrigin}) async {
    try {
      final shareText = _formatNewsForGeneral(news);
      
      await Share.share(
        shareText,
        subject: news.title,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      throw 'Gagal membagikan berita: ${e.toString()}';
    }
  }
  
  // Share with custom message
  static Future<void> shareWithCustomMessage(
    NewsModel news, 
    String customMessage, 
    {Rect? sharePositionOrigin}
  ) async {
    try {
      final shareText = '$customMessage\n\n${_formatNewsForGeneral(news)}';
      
      await Share.share(
        shareText,
        subject: news.title,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      throw 'Gagal membagikan berita: ${e.toString()}';
    }
  }
  
  // Format news content for WhatsApp
  static String _formatNewsForWhatsApp(NewsModel news) {
    final buffer = StringBuffer();
    
    // Add emoji and title
    buffer.writeln('📰 *${news.title}*');
    buffer.writeln();
    
    // Add category with emoji
    String categoryEmoji = news.category == 'Lokal' ? '🇮🇩' : '🌍';
    buffer.writeln('$categoryEmoji *Kategori:* ${news.category}');
    buffer.writeln();
    
    // Add summary
    buffer.writeln('📝 *Ringkasan:*');
    buffer.writeln(news.summary);
    buffer.writeln();
    
    // Add author and date
    buffer.writeln('✍️ *Penulis:* ${news.author}');
    buffer.writeln('📅 *Dipublikasi:* ${_formatDateForShare(news.publishedAt)}');
    buffer.writeln();
    
    // Add app promotion
    buffer.writeln('📱 *Baca selengkapnya di $appName*');
    buffer.writeln('Download: $appUrl');
    buffer.writeln();
    
    // Add hashtags
    buffer.writeln('#${news.category.toLowerCase()} #berita #cobranews #news');
    
    return buffer.toString();
  }
  
  // Format news content for general sharing
  static String _formatNewsForGeneral(NewsModel news) {
    final buffer = StringBuffer();
    
    buffer.writeln(news.title);
    buffer.writeln();
    buffer.writeln(news.summary);
    buffer.writeln();
    buffer.writeln('Kategori: ${news.category}');
    buffer.writeln('Penulis: ${news.author}');
    buffer.writeln('Dipublikasi: ${_formatDateForShare(news.publishedAt)}');
    buffer.writeln();
    buffer.writeln('Baca selengkapnya di $appName');
    buffer.writeln(appUrl);
    
    return buffer.toString();
  }
  
  // Format date for sharing
  static String _formatDateForShare(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  // Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('https://wa.me/');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
  
  // Check if WhatsApp Business is installed
  static Future<bool> isWhatsAppBusinessInstalled() async {
    try {
      final uri = Uri.parse('https://api.whatsapp.com/send');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}
