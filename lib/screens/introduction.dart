import 'package:flutter/material.dart';
import '../main.dart';
import 'auth/login_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();
  int currentIndex = 0;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;

  final List<IntroData> introData = [
    IntroData(
      title: 'Berita Terkini',
      description:
          'Dapatkan berita terbaru dari seluruh dunia dengan update real-time setiap saat',
      icon: Icons.newspaper,
      headerText: 'Introduction 1',
      color: const Color(0xFF1E3A8A),
    ),
    IntroData(
      title: 'Update Real Time',
      description:
          'Notifikasi instan untuk berita breaking news dan trending topics yang sedang viral',
      icon: Icons.notifications_active,
      headerText: 'Introduction 2',
      color: const Color(0xFF1E3A8A),
    ),
    IntroData(
      title: 'Simpan & Bagikan',
      description:
          'Bookmark artikel favorit dan bagikan dengan mudah ke media sosial kesayangan Anda',
      icon: Icons.share,
      headerText: 'Introduction 3',
      color: const Color(0xFF1E3A8A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (currentIndex < introData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildCustomLogo({double size = 140}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: introData[currentIndex].color.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.15),
        child: Container(
          padding: EdgeInsets.all(size * 0.12),
          color: Colors.white,
          child: Image.asset(
            'assets/images/logoi.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: introData[currentIndex].color,
                  borderRadius: BorderRadius.circular(size * 0.1),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              introData[currentIndex].color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Text(
                introData[currentIndex].headerText,
                style: TextStyle(
                  fontSize: 16,
                  color: introData[currentIndex].color.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildPageIndicator(),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  _logoAnimationController.reset();
                  _logoAnimationController.forward();
                },
                itemCount: introData.length,
                itemBuilder: (context, index) {
                  return _buildIntroPage(introData[index]);
                },
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          introData.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: currentIndex == index ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? introData[currentIndex].color
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroPage(IntroData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Spacer(flex: 1),
          AnimatedBuilder(
            animation: _logoScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoScaleAnimation.value,
                child: _buildCustomLogo(),
              );
            },
          ),
          const SizedBox(height: 40),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(45),
              border: Border.all(
                color: data.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              data.icon,
              size: 45,
              color: data.color,
            ),
          ),
          const SizedBox(height: 40),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: currentIndex == 0 ? _buildSingleButton() : _buildDoubleButtons(),
    );
  }

  Widget _buildSingleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: introData[currentIndex].color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: introData[currentIndex].color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lanjutkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _previousPage,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: introData[currentIndex].color,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: introData[currentIndex].color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kembali',
                    style: TextStyle(
                      color: introData[currentIndex].color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: introData[currentIndex].color,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: introData[currentIndex].color.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentIndex == introData.length - 1
                        ? 'Mulai'
                        : 'Lanjutkan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    currentIndex == introData.length - 1
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IntroData {
  final String title;
  final String description;
  final IconData icon;
  final String headerText;
  final Color color;

  IntroData({
    required this.title,
    required this.description,
    required this.icon,
    required this.headerText,
    required this.color,
  });
}
