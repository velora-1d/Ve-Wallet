import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../onboarding/domain/onboarding_model.dart';

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
      description: 'Input pemasukan dan pengeluaran harian kamu dalam hitungan detik, kapan saja dan di mana saja.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBN8Hvxsw9rPJWdo8TdJ1_wNBE_VLsMVfWpyXfHppUVOxRobNBBmvSgXjqrZl_yZo9PT8Bmyx_qiPLEnfFl7FcggNH9Ukllh_eAj7ux3PzAdCaXHP5L31qAtm9N5LK6cR2PSltzd69mbKlLRiLrlA5-FrZCV-VEMOTVc6ZFIuMRCPzw3sAUZAqJkBuKbTHlEHI06CBvOGxyCNTuFnHCqtz2x6aWZvyShmdbqrX98KMQ7njvOXRAlEvGSzhjfDf5XQSrAoOOngRd0bwB',
      buttonText: 'Lanjut',
    ),
    OnboardingData(
      title: 'Kelola Keuangan Berdua',
      description: 'Hubungkan akun dengan pasangan atau keluarga. Semua transaksi tersinkronisasi secara realtime.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDPQaGqC_7WGcut3kPS8j6tGV-5_iTZMitXYN5KEI-Y3_WBIgqqd0mN0nc0tL3y9kL7JY7wVl4Uyym1QIoDgLTdJ9UBFk1BVqK5treny6VuC4d4ZCheXwxzozi3hS2CPukPyiq8RPFSuEF_6o9D3h-3B12hSDcERmRcpxJT0Mw_iuLBYBW0ZDuE732F5yhKUF57YDbZ8K-61TxbQRjwsSQM8ZpTza7qtyVstEI7HON39XiEzWZ3leZHg8WVXAgtRSm_iGCnaoC48PNr',
      buttonText: 'Lanjut',
    ),
    OnboardingData(
      title: 'Capai Target Tabungan',
      description: 'Tetapkan tujuan keuanganmu dan pantau progresnya setiap hari. Simulasi otomatis bantu kamu nabung lebih cerdas.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBN8Hvxsw9rPJWdo8TdJ1_wNBE_VLsMVfWpyXfHppUVOxRobNBBmvSgXjqrZl_yZo9PT8Bmyx_qiPLEnfFl7FcggNH9Ukllh_eAj7ux3PzAdCaXHP5L31qAtm9N5LK6cR2PSltzd69mbKlLRiLrlA5-FrZCV-VEMOTVc6ZFIuMRCPzw3sAUZAqJkBuKbTHlEHI06CBvOGxyCNTuFnHCqtz2x6aWZvyShmdbqrX98KMQ7njvOXRAlEvGSzhjfDf5XQSrAoOOngRd0bwB', // Placeholder for slide 3 if needed, but the HTML design has a custom illustration. I'll use a network image for consistency.
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration
                      Container(
                        width: double.infinity,
                        aspectRatio: 1,
                        decoration: BoxDecoration(
                          color: index == 1 ? const Color(0xFFFFEDD5) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          page.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Title
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
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
                            : AppColors.outline.withOpacity(0.3),
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
