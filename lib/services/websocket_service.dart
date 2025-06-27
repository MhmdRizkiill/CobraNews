import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocket? _socket;
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);

  // Simulate WebSocket server URL (in real app, this would be your actual server)
  static const String _serverUrl = 'http://45.149.187.204:3000/api/news';

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // In a real implementation, you would connect to an actual WebSocket server
      // For demo purposes, we'll simulate the connection
      await _simulateConnection();

      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();

      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection failed: $e');
      }
      _scheduleReconnect();
    }
  }

  Future<void> _simulateConnection() async {
    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Start simulating real-time events
    _startSimulatedEvents();
  }

  void _startSimulatedEvents() {
    // Simulate periodic real-time updates
    Timer.periodic(const Duration(seconds: 60), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      // Simulate random news updates
      _simulateNewsUpdate();
    });

    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      // Simulate favorite updates from other users
      _simulateFavoriteUpdate();
    });
  }

  void _simulateNewsUpdate() {
    final updates = [
      {
        'type': 'news_created',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Lamine Yamal Nikmati Sukses Barcelona Hancurkan Madrid',
          'summary': 'Barcelona berhasil mengalahkan Real Madrid dengan skor telak...',
          'content': 'Barcelona - Barcelona mendominasi total Real Madrid di 2024/2025. Bintang muda Barca Lamine Yamal mengaku sangat menikmati momen-momen tersebut. Barca mengalahkan Madrid di masing-masing dari empat El Clasico domestik. Di Liga Spanyol, Blaugrana menang telak 4-0 di Santiago Bernabeu, lalu unggul 4-3 di laga kandang. Barcelona juga mempecundangi rival abadinya itu di final Piala Super Spanyol 5-2 dan final Copa del Rey 3-2.',
          'category': 'Internasional',
          'author': 'DedeYamal',
          'publishedAt': DateTime.now().toIso8601String(),
          'imageUrl': '/placeholder.svg?height=200&width=300',
          'isFavorite': false,
        }
      },
      {
        'type': 'news_created',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Lamine Yamal Nikmati Sukses Barcelona Hancurkan Madrid',
          'summary': 'Barcelona berhasil mengalahkan Real Madrid dengan skor telak...',
          'content': 'Barcelona - Barcelona mendominasi total Real Madrid di 2024/2025. Bintang muda Barca Lamine Yamal mengaku sangat menikmati momen-momen tersebut. Barca mengalahkan Madrid di masing-masing dari empat El Clasico domestik. Di Liga Spanyol, Blaugrana menang telak 4-0 di Santiago Bernabeu, lalu unggul 4-3 di laga kandang. Barcelona juga mempecundangi rival abadinya itu di final Piala Super Spanyol 5-2 dan final Copa del Rey 3-2.',
          'category': 'Internasional',
          'author': 'DedeYamal',
          'publishedAt': DateTime.now().toIso8601String(),
          'imageUrl': '/placeholder.svg?height=200&width=300',
          'isFavorite': false,
        }
      },
      {
        'type': 'news_created',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Lamine Yamal Nikmati Sukses Barcelona Hancurkan Madrid',
          'summary': 'Barcelona berhasil mengalahkan Real Madrid dengan skor telak...',
          'content': 'Barcelona - Barcelona mendominasi total Real Madrid di 2024/2025. Bintang muda Barca Lamine Yamal mengaku sangat menikmati momen-momen tersebut. Barca mengalahkan Madrid di masing-masing dari empat El Clasico domestik. Di Liga Spanyol, Blaugrana menang telak 4-0 di Santiago Bernabeu, lalu unggul 4-3 di laga kandang. Barcelona juga mempecundangi rival abadinya itu di final Piala Super Spanyol 5-2 dan final Copa del Rey 3-2.',
          'category': 'Internasional',
          'author': 'DedeYamal',
          'publishedAt': DateTime.now().toIso8601String(),
          'imageUrl': '/placeholder.svg?height=200&width=300',
          'isFa vorite': false,
        }
      },
      {
        'type': 'news_created',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Perjalanan Timothy Ronald Jadi Raja Kripto Indonesia',
          'summary': 'Timothy Ronald, seorang pengusaha muda Indonesia, telah menjadi sorotan dunia kripto...',
          'content': 'Memulai bisnis di usia 15 tahun dengan berdagang pomade impor. Hasilnya dijadikan modal investasi kripto dan kini telah meraup hasil berlipat-lipat sehingga dikenal sebagai triliuner termuda di Indonesia. Timothy Ronald merupakan investor muda asal Tangerang Selatan yang terkenal sebagai raja kripto dan mendirikan platform edukasi dan riset terkemuka, Akademi Crypto. Sebelum merambah dunia investasi, pria kelahiran 22 September 2000 tersebut memulai usaha sebagai pedagang pomade impor. Sejak kecil, Timothy mengaku telah terobsesi dengan figur konglomerat Amerika Serikat, Warren Buffett. Ia akhirnya membaca ratusan buku investasi dan mulai berdagang pomade sejak usia 15 tahun. Ambisinya saat itu untuk mendapatkan modal berinvestasi kripto dan saham. Pada usia 19 tahun, Timothy berhasil memiliki Rp1 miliar pertamanya dari investasi. Dana tersebut ia gunakan untuk mendirikan platform edukasi finansial, Ternak Uang.',
          'category': 'Lokal',
          'author': 'DedeYamal',
          'publishedAt': DateTime.now().toIso8601String(),
          'imageUrl': '/placeholder.svg?height=200&width=300',
          'isFavorite': false,
        }
      },
      {
        'type': 'news_created',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Analisis Pengamat Timur Tengah: Iran di Atas Angin, Israel Pengecut karena Keroyokan',
          'summary': 'Pengamat Timur Tengah Faisal Assegaf membeberkan pandangan tentang perang Iran versus Israel.',
          'content': 'Dalam Podcast merdeka Kamis (19/6), pengamat Timur Tengah Faisal Assegaf membeberkan konteks perang Iran versus Israel yang kini masih berlangsung. Pengamat yang pernah beberapa kali berkunjung ke Iran, Gaza, Lebanon, dan Libya itu mengatakan posisi Iran dalam perang melawan Israel saat ini sedang di atas angin. Berikut wawancara merdeka.com dengan Faisal Assegaf: Tanya (T): Soal Iran-Israel ini kalau kita lihat ini kan sekarang memanas. Padahal bukannya dulu dalam sejarahnya itu mereka sangat mesra ya? Jawab (J): Jadi waktu zaman kerajaan Iran, Shahreza Pahlavi, rajanya waktu itu, memang hubungan Iran dengan Israel, dengan Amerika itu baik. Makanya dulu ada kedutaan Amerika kan. Terus Iran juga menjadi negara berpenduduk mayoritas muslim kedua yang mengakui berdirinya Israel setelah Turki. Jadi Turki tahun 1949 (mengakui), karena Israel berdiri 14 Mei 1948.',
          'category': 'Lokal',
          'author': 'DedeYamal',
          'publishedAt': DateTime.now().toIso8601String(),
          'imageUrl': '/placeholder.svg?height=200&width=300',
          'isFavorite': false,
        }
      },
      {
        'type': 'news_updated',
        'data': {
          'id': '1',
          'title': 'Updated: Pemilu Presiden Amerika Serikat 2024 - Final Results',
          'summary': 'Final results have been announced for the 2024 US Presidential Election...',
        }
      }
    ];

    final randomUpdate = updates[DateTime.now().millisecond % updates.length];
    _messageController.add(randomUpdate);
  }

  void _simulateFavoriteUpdate() {
    final favoriteUpdate = {
      'type': 'favorite_updated',
      'data': {
        'newsId': '2',
        'userId': 'other_user',
        'isFavorite': true,
        'timestamp': DateTime.now().toIso8601String(),
      }
    };

    _messageController.add(favoriteUpdate);
  }

  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected) {
      if (kDebugMode) {
        print('Cannot send message: WebSocket not connected');
      }
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);

      // In real implementation: _socket?.add(jsonMessage);
      // For simulation, we'll echo back certain messages
      _handleSimulatedMessage(message);

      if (kDebugMode) {
        print('Message sent: $jsonMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

  void _handleSimulatedMessage(Map<String, dynamic> message) {
    // Simulate server response with delay
    Future.delayed(const Duration(milliseconds: 200), () {
      switch (message['type']) {
        case 'favorite_toggle':
          _messageController.add({
            'type': 'favorite_updated',
            'data': {
              'newsId': message['data']['newsId'],
              'userId': 'current_user',
              'isFavorite': message['data']['isFavorite'],
              'timestamp': DateTime.now().toIso8601String(),
            }
          });
          break;
        case 'news_create':
        case 'news_update':
        case 'news_delete':
          _messageController.add({
            'type': '${message['type']}d', // created, updated, deleted
            'data': message['data'],
            'timestamp': DateTime.now().toIso8601String(),
          });
          break;
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({
          'type': 'ping'
        });
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      if (kDebugMode) {
        print('Max reconnection attempts reached');
      }
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      _reconnectAttempts++;
      if (kDebugMode) {
        print('Attempting to reconnect... ($_reconnectAttempts/$maxReconnectAttempts)');
      }
      connect();
    });
  }

  void disconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _socket?.close();

    if (kDebugMode) {
      print('WebSocket disconnected');
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
