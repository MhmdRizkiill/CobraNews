import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/news_model.dart';
import '../services/share_service.dart';

class WhatsAppQuickShareButton extends StatefulWidget {
  final NewsModel news;
  final bool isFloating;
  final VoidCallback? onShareSuccess;

  const WhatsAppQuickShareButton({
    super.key,
    required this.news,
    this.isFloating = false,
    this.onShareSuccess,
  });

  @override
  State<WhatsAppQuickShareButton> createState() => _WhatsAppQuickShareButtonState();
}

class _WhatsAppQuickShareButtonState extends State<WhatsAppQuickShareButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isWhatsAppAvailable = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _checkWhatsAppAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkWhatsAppAvailability() async {
    final isAvailable = await ShareService.isWhatsAppInstalled();
    if (mounted) {
      setState(() {
        _isWhatsAppAvailable = isAvailable;
      });
    }
  }

  Future<void> _quickShareToWhatsApp() async {
    if (!_isWhatsAppAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp tidak terinstall di perangkat ini'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      await ShareService.shareToWhatsApp(widget.news);
      
      HapticFeedback.lightImpact();
      
      if (mounted) {
        widget.onShareSuccess?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Berhasil dibagikan ke WhatsApp!'),
              ],
            ),
            backgroundColor: const Color(0xFF25D366),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWhatsAppAvailable) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.isFloating
              ? FloatingActionButton(
                  onPressed: _isLoading ? null : _quickShareToWhatsApp,
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.chat),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _quickShareToWhatsApp,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            const SizedBox(width: 8),
                            const Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
