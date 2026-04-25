import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:intl/intl.dart';

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends ConsumerState<AddTransactionBottomSheet> {
  String _amount = '0';
  int _activeTab = 0; // 0: Keluar (Expense), 1: Masuk (Income), 2: Transfer
  String _selectedCategory = 'Makanan';
  WalletModel? _selectedWallet;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Makanan',
      'icon': Icons.restaurant,
      'bgColor': AppColors.secondaryFixed,
      'iconColor': AppColors.secondary,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'bgColor': AppColors.tertiaryFixed,
      'iconColor': AppColors.tertiary,
    },
    {
      'name': 'Belanja',
      'icon': Icons.shopping_bag,
      'bgColor': AppColors.surfaceVariant,
      'iconColor': AppColors.primary,
    },
    {
      'name': 'Rumah',
      'icon': Icons.home,
      'bgColor': const Color(0xFFE0E7FF),
      'iconColor': const Color(0xFF4338CA),
    },
    {
      'name': 'Listrik',
      'icon': Icons.bolt,
      'bgColor': const Color(0xFFFEF08A),
      'iconColor': const Color(0xFF854D0E),
    },
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String value) {
    setState(() {
      if (_amount == '0') {
        if (value != '0') {
          _amount = value;
        }
      } else {
        // limit length
        if (_amount.length < 12) {
          _amount += value;
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _onPresetPressed(String value) {
    setState(() {
      _amount = value;
    });
  }

  Future<void> _saveTransaction() async {
    final amountParsed = double.tryParse(_amount) ?? 0.0;
    if (amountParsed <= 0) {
      AppUI.showWarning(context, 'Nominal harus lebih dari 0');
      return;
    }

    if (_selectedWallet == null) {
      AppUI.showWarning(context, 'Pilih dompet terlebih dahulu');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppUI.showError(context, 'Anda belum login');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final walletRepo = ref.read(walletRepositoryProvider);

      final isExpense = _activeTab == 0;

      final transaction = TransactionModel(
        userId: user.id,
        walletId: _selectedWallet!.id,
        categoryId: _selectedCategory.toLowerCase(),
        categoryName: _selectedCategory,
        type: isExpense ? TransactionType.expense : TransactionType.income,
        amount: amountParsed,
        note: _noteController.text,
        date: DateTime.now(),
      );

      await repo.addTransaction(transaction);

      // Update wallet balance
      final newBalance = isExpense
          ? _selectedWallet!.balance - amountParsed
          : _selectedWallet!.balance + amountParsed;

      final updatedWallet = _selectedWallet!.copyWith(balance: newBalance);
      await walletRepo.updateWallet(updatedWallet);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppUI.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectWallet(List<WalletModel> wallets) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Pilih Dompet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...wallets.map(
                (w) => ListTile(
                  leading: Icon(
                    WalletIconUtils.getIcon(w.icon),
                    color: Color(w.color),
                  ),
                  title: Text(w.name),
                  trailing: Text('Rp ${currencyFormat.format(w.balance)}'),
                  onTap: () {
                    setState(() => _selectedWallet = w);
                    Navigator.pop(context);
                  },
                ),
              ),
              if (wallets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada dompet'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsStreamProvider);

    // Auto select first wallet if none selected and wallets are available
    walletsAsync.whenData((wallets) {
      if (_selectedWallet == null && wallets.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedWallet == null) {
            setState(() => _selectedWallet = wallets.first);
          }
        });
      }
    });

    final formattedAmount = currencyFormat.format(int.tryParse(_amount) ?? 0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  Row(
                    children: [
                      _buildTab(
                        0,
                        'Keluar',
                        AppColors.errorContainer,
                        AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        1,
                        'Masuk',
                        AppColors.surfaceContainer,
                        AppColors.success,
                      ),
                      // Transfer tab can be handled later or disabled for now
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Amount Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryFixed),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Nominal Transaksi',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Rp',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedAmount,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Presets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPreset('10000'),
                      _buildPreset('20000'),
                      _buildPreset('50000'),
                      _buildPreset('100000'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Numpad
                  Center(
                    child: SizedBox(
                      width: 280,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          ...List.generate(
                            9,
                            (index) => _buildNumBtn((index + 1).toString()),
                          ),
                          _buildNumBtn('000'),
                          _buildNumBtn('0'),
                          _buildActionBtn(
                            Icons.backspace_outlined,
                            _onBackspace,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Categories
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categories
                          .map(
                            (c) => _buildCategoryItem(
                              c['name'],
                              c['icon'],
                              c['bgColor'],
                              c['iconColor'],
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            walletsAsync.whenData(
                              (wallets) => _selectWallet(wallets),
                            );
                          },
                          child: _buildDetailTile(
                            Icons.account_balance_wallet_outlined,
                            'Dompet',
                            _selectedWallet?.name ?? 'Pilih Dompet',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDetailTile(
                          Icons.calendar_today_outlined,
                          'Tanggal',
                          'Hari ini',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              icon: Icon(
                                Icons.edit_note,
                                color: AppColors.outline,
                              ),
                              hintText: 'Tambah catatan...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: AppColors.outlineVariant,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ),

          // Fixed Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveTransaction,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle, color: Colors.white),
              label: Text(
                _isLoading ? 'Menyimpan...' : 'Simpan Transaksi',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, Color bgColor, Color textColor) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? bgColor : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? textColor : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreset(String value) {
    return GestureDetector(
      onTap: () => _onPresetPressed(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryContainer),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value.replaceFirst('000', 'rb'),
          style: const TextStyle(
            color: AppColors.secondaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNumBtn(String value) {
    return GestureDetector(
      onTap: () => _onNumberPressed(value),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Icon(icon, size: 28, color: const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
