import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class TransactionListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String wallet;
  final String amount;
  final bool isExpense;
  final Color? amountColor;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.wallet,
    required this.amount,
    required this.isExpense,
    this.amountColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    amountColor ??
                    (isExpense ? AppColors.error : AppColors.success),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
