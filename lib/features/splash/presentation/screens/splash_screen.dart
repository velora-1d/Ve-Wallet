import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initial loading or navigation logic
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to onboarding or login
      // For now, we'll just leave it here or navigate if router is ready
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Central Brand Canvas
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Mark Container
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                Text(
                  'Ve-Wallet',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Tagline
                Text(
                  'Kelola Keuangan Bersama',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            // Bottom Indicator
            Positioned(
              bottom: 32,
              child: Row(
                children: [
                  _buildIndicator(1.0),
                  const SizedBox(width: 8),
                  _buildIndicator(0.6),
                  const SizedBox(width: 8),
                  _buildIndicator(0.3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(double opacity) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
