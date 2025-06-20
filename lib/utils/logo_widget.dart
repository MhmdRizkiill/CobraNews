import 'package:flutter/material.dart';

class CobraNewsLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showShadow;
  final EdgeInsets? padding;

  const CobraNewsLogo({
    super.key,
    this.size = 120,
    this.backgroundColor,
    this.borderRadius = 20,
    this.showShadow = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor ?? Colors.white,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.all(size * 0.12),
          child: Image.asset(
            'assets/images/logoi.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(borderRadius * 0.7),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'COBRA NEWS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.08,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Widget untuk logo dengan animasi
class AnimatedCobraLogo extends StatefulWidget {
  final double size;
  final Duration animationDuration;
  final Color? backgroundColor;

  const AnimatedCobraLogo({
    super.key,
    this.size = 120,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.backgroundColor,
  });

  @override
  State<AnimatedCobraLogo> createState() => _AnimatedCobraLogoState();
}

class _AnimatedCobraLogoState extends State<AnimatedCobraLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: CobraNewsLogo(
              size: widget.size,
              backgroundColor: widget.backgroundColor,
            ),
          ),
        );
      },
    );
  }
}
