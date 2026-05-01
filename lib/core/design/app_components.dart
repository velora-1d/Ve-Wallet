import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

/// Haptic feedback utilities for micro-interactions
class AppHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
}

/// Animated button with scale effect on tap
class AnimatedTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDownTo;
  final Duration duration;

  const AnimatedTapButton({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDownTo = 0.97,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedTapButton> createState() => _AnimatedTapButtonState();
}

class _AnimatedTapButtonState extends State<AnimatedTapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDownTo)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    AppHaptics.light();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// Standardized AppBar for consistent navigation across all screens
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool transparent;
  final bool centerTitle;
  final VoidCallback? onLeadingTap;
  final Color? backgroundColor;

  const StandardAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.transparent = true,
    this.centerTitle = true,
    this.onLeadingTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: transparent
          ? (backgroundColor ?? Colors.transparent)
          : (backgroundColor ?? theme.scaffoldBackgroundColor),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading ?? _buildDefaultLeading(context),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
      ),
      actions: actions,
    );
  }

  Widget _buildDefaultLeading(BuildContext context) {
    return GestureDetector(
      onTap: onLeadingTap ?? () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Standardized TextField for consistent input across all screens
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool filled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.filled = true,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
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
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.primary)
            : null,
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor: filled ? const Color(0xFFF8FAFF) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD9E3FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Standardized Empty State Card for consistent empty states
class EmptyStateCard extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final Color? iconColor;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFF94A3B8);

    return Semantics(
      label: '$title. $description',
      button: buttonLabel != null && onAction != null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: effectiveIconColor,
                semanticLabel: 'Ikon status kosong',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: const Color(0xFF64748B),
              ),
            ),
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonLabel!,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized Loading State for consistent loading indicators
class AppLoadingState extends StatelessWidget {
  final String? message;

  const AppLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message ?? 'Sedang memuat',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized Error State for consistent error display with accessibility
class AppErrorState extends StatelessWidget {
  final String message;
  final String? suggestion;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.suggestion,
    this.onRetry,
  });

  /// Factory constructor for network errors with actionable suggestion
  factory AppErrorState.network({VoidCallback? onRetry}) {
    return AppErrorState(
      message: 'Tidak dapat terhubung ke server',
      suggestion: 'Periksa koneksi internet Anda dan coba lagi.',
      onRetry: onRetry,
    );
  }

  /// Factory constructor for timeout errors
  factory AppErrorState.timeout({VoidCallback? onRetry}) {
    return AppErrorState(
      message: 'Waktu tunggu habis',
      suggestion: 'Server sedang sibuk. Silakan coba lagi dalam beberapa saat.',
      onRetry: onRetry,
    );
  }

  /// Factory constructor for permission errors
  factory AppErrorState.permission() {
    return AppErrorState(
      message: 'Akses ditolak',
      suggestion:
          'Anda tidak memiliki izin untuk mengakses fitur ini. Hubungi admin jika memerlukan akses.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Terjadi kesalahan: $message',
      hint: suggestion ?? 'Tekan tombol coba lagi untuk memuat ulang',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: AppColors.error,
                  semanticLabel: 'Ikon error',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                  height: 1.5,
                ),
              ),
              if (suggestion != null) ...[
                const SizedBox(height: 8),
                Text(
                  suggestion!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
