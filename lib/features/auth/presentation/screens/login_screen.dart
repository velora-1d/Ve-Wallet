import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              // Headings
              Text(
                'Selamat Datang Kembali 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun kamu',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 40),
              // Form
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 12),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Lupa Password?',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement login logic
                    context.go('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'atau',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),
              // Google Login
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBC22IDoAR5xttqve0kqSRNUHTnE7uxBBWx1J88Sr_eJbAOWzwBZ9dOt-8jDMjQ9HpRWgsGLE_W4XHMSS3oFItd_tCKro1ZhiGqStuGZxI04eYye6EwWVtERX3Kqgjr7npRncVZaLhWQGEpc3s1JZzfaLOBPtSQ7Trt7hsrMfY1I6izZhVh6s8AU1SXAEMT5oXKQUiGjcbsgNWAasIIwUz-2tvrxi92brfEjZpYPnT2dk4KqQYWrcHGaFYz2RdlNUpkvsvL-wFMbnQV',
                    width: 20,
                    height: 20,
                  ),
                  label: const Text('Masuk dengan Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onBackground,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Daftar Sekarang',
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
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryContainer),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryContainer),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryContainer),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.outline,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryContainer),
        ),
      ),
    );
  }
}
