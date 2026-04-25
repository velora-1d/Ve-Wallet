import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

/// Tipe snackbar
enum SnackType { success, error, warning, info }

/// Helper terpusat untuk semua UI feedback (dialog + snackbar)
class AppUI {
  // ─────────────────────────────────────────────────────────────────────
  // SNACKBAR
  // ─────────────────────────────────────────────────────────────────────

  static void showSnack(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _snackConfig(type);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: duration,
          content: _SnackContent(
            message: message,
            icon: config.icon,
            color: config.color,
            iconBg: config.iconBg,
          ),
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) =>
      showSnack(context, message, type: SnackType.success);

  static void showError(BuildContext context, String message) =>
      showSnack(context, message, type: SnackType.error);

  static void showWarning(BuildContext context, String message) =>
      showSnack(context, message, type: SnackType.warning);

  static void showInfo(BuildContext context, String message) =>
      showSnack(context, message, type: SnackType.info);

  // ─────────────────────────────────────────────────────────────────────
  // CONFIRM DIALOG  (hapus / aksi destruktif)
  // ─────────────────────────────────────────────────────────────────────

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Hapus',
    String cancelLabel = 'Batal',
    bool isDangerous = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogCtx) => _AppDialog(
        icon: isDangerous
            ? Icons.delete_outline_rounded
            : Icons.check_circle_outline_rounded,
        iconColor: isDangerous ? AppColors.error : AppColors.primary,
        iconBgColor: isDangerous
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        title: title,
        message: message,
        actions: [
          _DialogButton(
            label: cancelLabel,
            onTap: () => Navigator.pop(dialogCtx, false),
            outlined: true,
          ),
          _DialogButton(
            label: confirmLabel,
            onTap: () => Navigator.pop(dialogCtx, true),
            danger: isDangerous,
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────
  // ALERT DIALOG  (informasi / sukses / error satu tombol)
  // ─────────────────────────────────────────────────────────────────────

  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    SnackType type = SnackType.info,
    String buttonLabel = 'Oke',
  }) async {
    final config = _snackConfig(type);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogCtx) => _AppDialog(
        icon: config.icon,
        iconColor: config.color,
        iconBgColor: config.iconBg,
        title: title,
        message: message,
        actions: [
          _DialogButton(
            label: buttonLabel,
            onTap: () => Navigator.pop(dialogCtx),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // INPUT DIALOG  (pencarian / input text sederhana)
  // ─────────────────────────────────────────────────────────────────────

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    String? initialText,
    String confirmLabel = 'Terapkan',
    String cancelLabel = 'Batal',
  }) async {
    final controller = TextEditingController(text: initialText);
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogCtx) => _AppDialog(
        icon: Icons.search_rounded,
        iconColor: AppColors.primary,
        iconBgColor: AppColors.primary.withValues(alpha: 0.1),
        title: title,
        message: '',
        customContent: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        actions: [
          _DialogButton(
            label: cancelLabel,
            onTap: () => Navigator.pop(dialogCtx, null),
            outlined: true,
          ),
          _DialogButton(
            label: confirmLabel,
            onTap: () => Navigator.pop(dialogCtx, controller.text.trim()),
          ),
        ],
      ),
    );
    return result;
  }

  // ─────────────────────────────────────────────────────────────────────
  // INTERNAL
  // ─────────────────────────────────────────────────────────────────────

  static _SnackCfg _snackConfig(SnackType type) => switch (type) {
        SnackType.success => _SnackCfg(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF22C55E),
            iconBg: const Color(0xFF166534),
          ),
        SnackType.error => _SnackCfg(
            icon: Icons.cancel_rounded,
            color: const Color(0xFFEF4444),
            iconBg: const Color(0xFF7F1D1D),
          ),
        SnackType.warning => _SnackCfg(
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFF59E0B),
            iconBg: const Color(0xFF78350F),
          ),
        SnackType.info => _SnackCfg(
            icon: Icons.info_rounded,
            color: AppColors.primaryContainer,
            iconBg: AppColors.primary.withValues(alpha: 0.25),
          ),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL WIDGETS (private)
// ─────────────────────────────────────────────────────────────────────────────

class _SnackCfg {
  final IconData icon;
  final Color color;
  final Color iconBg;
  const _SnackCfg({
    required this.icon,
    required this.color,
    required this.iconBg,
  });
}

class _SnackContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color iconBg;

  const _SnackContent({
    required this.message,
    required this.icon,
    required this.color,
    required this.iconBg,
  });

  @override
  State<_SnackContent> createState() => _SnackContentState();
}

class _SnackContentState extends State<_SnackContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F2E).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AppDialog extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String message;
  final Widget? customContent;
  final List<_DialogButton> actions;

  const _AppDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.message,
    this.customContent,
    required this.actions,
  });

  @override
  State<_AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<_AppDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 40,
                      spreadRadius: -4,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon bubble
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: widget.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Message
                    if (widget.message.isNotEmpty)
                      Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (widget.customContent != null) widget.customContent!,
                    if (widget.message.isNotEmpty || widget.customContent != null)
                      const SizedBox(height: 28),
                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(
                      children: widget.actions
                          .map(
                            (btn) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: btn != widget.actions.last ? 8 : 0,
                                ),
                                child: btn,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final bool danger;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          side: BorderSide(
            color: AppColors.outlineVariant,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: danger ? AppColors.error : AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(label),
    );
  }
}
