import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/onboarding/domain/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Catat Transaksi dengan Mudah',
      description:
          'Input pemasukan dan pengeluaran harian kamu dalam hitungan detik, kapan saja dan di mana saja.',
      imageUrl: 'assets/images/onboarding/ekspresi menang.svg',
      buttonText: 'Lanjut',
    ),
    OnboardingData(
      title: 'Keamanan Tingkat Tinggi',
      description:
          'Data keuangan kamu terlindungi dengan enkripsi terbaik. Pantau akses akun secara realtime.',
      imageUrl: 'assets/images/onboarding/Juara.svg',
      buttonText: 'Lanjut',
    ),
    OnboardingData(
      title: 'Kemudahan Bayar Pakai QR',
      description:
          'Transaksi lebih cepat dengan fitur Scan QR. Dompet digital serbaguna dalam genggaman kamu.',
      imageUrl: 'assets/images/onboarding/scan QR berikut.svg',
      buttonText: 'Mulai Sekarang',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ve-Wallet',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Lewati',
                style: TextStyle(
                  color: AppColors.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                final isSvg = page.imageUrl.endsWith('.svg');

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(42),
                          ),
                          child: isSvg
                              ? SvgPicture.asset(
                                  page.imageUrl,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  page.imageUrl,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Title
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Pagination Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryContainer
                            : AppColors.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == _pages.length - 1 
                          ? AppColors.primaryContainer 
                          : AppColors.secondaryContainer,
                      foregroundColor: _currentPage == _pages.length - 1
                          ? Colors.white
                          : AppColors.onSecondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _pages[_currentPage].buttonText,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _currentPage == _pages.length - 1 ? Colors.white : AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
