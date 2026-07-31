import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _passwordScore {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;

    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\\/+=~`]').hasMatch(password)) {
      score++;
    }

    return score.clamp(0, 4);
  }

  _PasswordStrengthState get _passwordStrengthState {
    final score = _passwordScore;
    if (score <= 1) {
      return const _PasswordStrengthState(
        label: 'Lemah',
        color: Color(0xFFDC2626),
        activeBars: 1,
        helper: 'Tambahkan huruf besar, angka, dan simbol.',
      );
    }
    if (score == 2) {
      return const _PasswordStrengthState(
        label: 'Cukup',
        color: Color(0xFFEA580C),
        activeBars: 2,
        helper: 'Sudah lumayan, tapi masih bisa diperkuat.',
      );
    }
    if (score == 3) {
      return const _PasswordStrengthState(
        label: 'Bagus',
        color: Color(0xFF2563EB),
        activeBars: 3,
        helper: 'Password sudah baik untuk dipakai.',
      );
    }
    return const _PasswordStrengthState(
      label: 'Kuat',
      color: Color(0xFF16A34A),
      activeBars: 4,
      helper: 'Password kuat dan lebih aman.',
    );
  }

  bool get _canSubmit {
    return !_isLoading &&
        _agreedToTerms &&
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      AppUI.showSnack(
        context,
        'Semua field harus diisi',
        type: SnackType.warning,
      );
      return;
    }

    if (!_agreedToTerms) {
      AppUI.showSnack(
        context,
        'Setujui syarat dan kebijakan terlebih dahulu',
        type: SnackType.warning,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppUI.showSnack(
        context,
        'Password tidak cocok',
        type: SnackType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (user != null && mounted) {
        AppUI.showSnack(
          context,
          'Registrasi berhasil. Silakan masuk dengan akun Anda.',
          type: SnackType.success,
        );
        context.go('/login');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      AppUI.showSnack(
        context,
        _mapAuthError(e),
        type: SnackType.error,
      );
    } catch (e) {
      if (!mounted) return;
      AppUI.showSnack(
        context,
        'Gagal daftar: $e',
        type: SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrengthState;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header / Branding
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0A3C95), Color(0xFF2563EB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/logos/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Daftar Akun Ve-Wallet',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Satu akun untuk atur keuangan pribadi & keluarga.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Nama lengkap'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _nameController,
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildInputLabel('Email'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _emailController,
                                hintText: 'nama@email.com',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildInputLabel('Password'),
                              const SizedBox(height: 6),
                              _buildPasswordField(
                                controller: _passwordController,
                                hintText: 'Minimal 8 karakter',
                                isVisible: _isPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                              if (_passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _buildPasswordStrength(strength),
                              ],
                              const SizedBox(height: 16),
                              _buildInputLabel('Konfirmasi password'),
                              const SizedBox(height: 6),
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                hintText: 'Ulangi password',
                                isVisible: _isConfirmPasswordVisible,
                                onToggleVisibility: () {
                                  setState(
                                    () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              _buildTermsSection(),
                              const SizedBox(height: 20),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _canSubmit ? _register : null,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                                    disabledForegroundColor: Colors.white70,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.2,
                                          ),
                                        )
                                      : Text(
                                          'Daftar Sekarang',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged ?? (_) => setState(() {}),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: const Color(0xFF64748B),
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength(_PasswordStrengthState strength) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: strength.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(4, (index) {
                    final isActive = index < strength.activeBars;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive
                              ? strength.color
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                strength.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: strength.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            strength.helper,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _agreedToTerms
              ? AppColors.primary.withValues(alpha: 0.06)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _agreedToTerms
                ? AppColors.primary.withValues(alpha: 0.28)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() => _agreedToTerms = value ?? false);
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Saya setuju dengan ',
                  children: [
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          AppUI.showSnack(
                            context,
                            'Halaman syarat & ketentuan belum tersedia.',
                            type: SnackType.info,
                          );
                        },
                    ),
                    const TextSpan(text: ' dan '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          AppUI.showSnack(
                            context,
                            'Halaman kebijakan privasi belum tersedia.',
                            type: SnackType.info,
                          );
                        },
                    ),
                    const TextSpan(text: ' Ve-Wallet.'),
                  ],
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('user already registered')) {
      return 'Email sudah terdaftar. Coba masuk saja.';
    }
    if (message.contains('password should be')) {
      return 'Password tidak memenuhi syarat minimum.';
    }
    if (message.contains('email address')) {
      return 'Format email tidak valid.';
    }
    return 'Gagal daftar: ${error.message}';
  }
}

class _PasswordStrengthState {
  final String label;
  final Color color;
  final int activeBars;
  final String helper;

  const _PasswordStrengthState({
    required this.label,
    required this.color,
    required this.activeBars,
    required this.helper,
  });
}
