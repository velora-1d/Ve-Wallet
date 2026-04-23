import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/category_utils.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/presentation/providers/category_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? transactionId;
  final String? initialWalletId;

  const AddEditTransactionScreen({
    super.key,
    this.isEdit = false,
    this.transactionId,
    this.initialWalletId,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String _amountString = '0';
  String? _selectedWalletId;
  String? _selectedToWalletId;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isTransfer => _selectedType == TransactionType.transfer;

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.initialWalletId;
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransactionData();
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactionData() async {
    if (widget.transactionId == null) return;

    setState(() => _isLoading = true);
    try {
      final tx = await ref
          .read(transactionRepositoryProvider)
          .getTransactionById(widget.transactionId!);

      setState(() {
        _selectedType = tx.type;
        _amountString = tx.amount.toStringAsFixed(0);
        _noteController.text = tx.note;
        _selectedDate = tx.date;
        _selectedWalletId = tx.walletId;
        _selectedToWalletId = tx.toWalletId;
        _selectedCategoryId = tx.isTransfer ? null : tx.categoryId;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data transaksi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleNumpadPress(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
        return;
      }

      if (value == ',') {
        return;
      }

      if (_amountString == '0') {
        _amountString = value;
      } else if (_amountString.length < 12) {
        _amountString += value;
      }
    });
  }

  void _handlePresetPress(String value) {
    setState(() {
      final currentAmount = int.tryParse(_amountString) ?? 0;
      final presetValue = int.parse(value.replaceAll('rb', '000'));
      _amountString = (currentAmount + presetValue).toString();
    });
  }

  void _setTransactionType(TransactionType type) {
    setState(() {
      _selectedType = type;
      if (_isTransfer) {
        _selectedCategoryId = null;
      } else {
        _selectedToWalletId = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountString) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet asal')),
      );
      return;
    }

    if (_isTransfer) {
      if (_selectedToWalletId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih dompet tujuan')),
        );
        return;
      }
      if (_selectedWalletId == _selectedToWalletId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dompet asal dan tujuan tidak boleh sama'),
          ),
        );
        return;
      }
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      String categoryId = '';
      String categoryName = 'Transfer';

      if (!_isTransfer) {
        final categories = await ref
            .read(categoryRepositoryProvider)
            .getCategories(type: _selectedType);
        final selectedCategory = categories.firstWhere(
          (category) => category.id == _selectedCategoryId,
        );
        categoryId = selectedCategory.id;
        categoryName = selectedCategory.name;
      }

      final transaction = TransactionModel(
        id: widget.isEdit ? widget.transactionId! : '',
        userId: user.id,
        walletId: _selectedWalletId!,
        categoryId: categoryId,
        categoryName: categoryName,
        type: _selectedType,
        amount: amount,
        note: _noteController.text.trim(),
        date: _selectedDate,
        toWalletId: _isTransfer ? _selectedToWalletId : null,
      );

      if (widget.isEdit) {
        await ref
            .read(transactionRepositoryProvider)
            .updateTransaction(transaction);
      } else {
        await ref.read(transactionRepositoryProvider).addTransaction(transaction);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final categoriesAsync = _isTransfer
        ? const AsyncValue<List<CategoryModel>>.data(<CategoryModel>[])
        : ref.watch(categoriesStreamProvider(_selectedType));
    final formatter = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTypeTabs(),
                      const SizedBox(height: 16),
                      _buildAmountDisplay(formatter),
                      const SizedBox(height: 16),
                      _buildQuickPresets(),
                      const SizedBox(height: 24),
                      _buildNumpad(),
                      const SizedBox(height: 32),
                      if (_isTransfer)
                        _buildTransferInfo()
                      else
                        _buildCategoryPicker(categoriesAsync),
                      const SizedBox(height: 32),
                      _buildWalletAndDatePicker(walletsAsync),
                      const SizedBox(height: 16),
                      _buildNoteAndPhotoSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildStickyFooter(),
    );
  }

  Widget _buildTypeTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTypeTabItem('Keluar', TransactionType.expense),
          const SizedBox(width: 8),
          _buildTypeTabItem('Masuk', TransactionType.income),
          const SizedBox(width: 8),
          _buildTypeTabItem('Transfer', TransactionType.transfer),
        ],
      ),
    );
  }

  Widget _buildTypeTabItem(String label, TransactionType type) {
    final isSelected = _selectedType == type;

    Color background = const Color(0xFFEAEDFF);
    Color textColor = const Color(0xFF434655);

    if (isSelected) {
      switch (type) {
        case TransactionType.expense:
          background = const Color(0xFFFFDAD6);
          textColor = const Color(0xFFBA1A1A);
          break;
        case TransactionType.income:
          background = const Color(0xFFDCFCE7);
          textColor = const Color(0xFF15803D);
          break;
        case TransactionType.transfer:
          background = const Color(0xFFDBEAFE);
          textColor = const Color(0xFF1D4ED8);
          break;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _setTransactionType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(NumberFormat formatter) {
    final value = int.tryParse(_amountString) ?? 0;
    final displayAmount = formatter.format(value);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        children: [
          Text(
            _isTransfer ? 'Nominal Transfer' : 'Nominal Transaksi',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF004AC6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004AC6),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                displayAmount,
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF004AC6),
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['10rb', '20rb', '50rb', '100rb'].map((value) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                onPressed: () => _handlePresetPress(value),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: Color(0xFFFD761A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFD761A),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          children: [
            _buildNumpadRow(['1', '2', '3']),
            const SizedBox(height: 16),
            _buildNumpadRow(['4', '5', '6']),
            const SizedBox(height: 16),
            _buildNumpadRow(['7', '8', '9']),
            const SizedBox(height: 16),
            _buildNumpadRow([',', '0', 'backspace']),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((value) {
        if (value == 'backspace') {
          return _buildNumpadButton(value, icon: Icons.backspace_outlined);
        }
        return _buildNumpadButton(value);
      }).toList(),
    );
  }

  Widget _buildNumpadButton(String value, {IconData? icon}) {
    final isSpecial = value == ',' || value == 'backspace';
    return GestureDetector(
      onTap: () => _handleNumpadPress(value),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isSpecial ? Colors.transparent : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 24, color: const Color(0xFF0F172A))
              : Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTransferInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz, color: Color(0xFF1D4ED8)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Transfer memindahkan saldo dari dompet asal ke dompet tujuan tanpa masuk ke kategori pengeluaran.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kategori',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          data: (categories) {
            return SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategoryId == category.id;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategoryId = category.id),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: isSelected ? const EdgeInsets.all(2) : null,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF004AC6),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(
                                  category.color,
                                ).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CategoryUtils.getIcon(category.icon),
                                color: Color(category.color),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.name,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF131B2E)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletAndDatePicker(AsyncValue<List<WalletModel>> walletsAsync) {
    return walletsAsync.when(
      data: (wallets) {
        final sourceWallet = _findWallet(wallets, _selectedWalletId);
        final targetWallet = _findWallet(wallets, _selectedToWalletId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (_isTransfer) ...[
                _buildWalletField(
                  label: 'Dompet Asal',
                  wallet: sourceWallet,
                  icon: Icons.arrow_outward,
                  onTap: () => _showWalletSelector(
                    context,
                    wallets,
                    isTarget: false,
                  ),
                ),
                const SizedBox(height: 12),
                _buildWalletField(
                  label: 'Dompet Tujuan',
                  wallet: targetWallet,
                  icon: Icons.arrow_downward,
                  onTap: () => _showWalletSelector(
                    context,
                    wallets.where((wallet) => wallet.id != _selectedWalletId).toList(),
                    isTarget: true,
                  ),
                ),
                const SizedBox(height: 12),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _buildWalletField(
                        label: 'Dompet',
                        wallet: sourceWallet,
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => _showWalletSelector(
                          context,
                          wallets,
                          isTarget: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDateField()),
                  ],
                ),
              if (_isTransfer) _buildDateField(),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildWalletField({
    required String label,
    required WalletModel? wallet,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEDFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF737686)),
            const SizedBox(width: 8),
            if (wallet != null) ...[
              Icon(
                WalletIconUtils.getIcon(wallet.icon),
                color: Color(wallet.color),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF737686),
                    ),
                  ),
                  Text(
                    wallet?.name ?? 'Pilih Dompet',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF131B2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEDFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF737686),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF737686),
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF131B2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteAndPhotoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEDFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _noteController,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF131B2E),
                ),
                decoration: InputDecoration(
                  hintText: _isTransfer
                      ? 'Catatan transfer...'
                      : 'Tambah catatan...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF737686),
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.edit_note, color: Color(0xFF737686)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur kamera belum tersedia')),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEDFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: Color(0xFF004AC6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004AC6),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF004AC6).withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEdit
                        ? (_isTransfer
                              ? 'Simpan Transfer'
                              : 'Simpan Perubahan')
                        : (_isTransfer ? 'Simpan Transfer' : 'Simpan Transaksi'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  WalletModel? _findWallet(List<WalletModel> wallets, String? walletId) {
    if (walletId == null) return null;
    try {
      return wallets.firstWhere((wallet) => wallet.id == walletId);
    } catch (_) {
      return null;
    }
  }

  void _showWalletSelector(
    BuildContext context,
    List<WalletModel> wallets, {
    required bool isTarget,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTarget ? 'Pilih Dompet Tujuan' : 'Pilih Dompet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...wallets.map(
              (wallet) => ListTile(
                leading: Icon(
                  WalletIconUtils.getIcon(wallet.icon),
                  color: Color(wallet.color),
                ),
                title: Text(
                  wallet.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                trailing:
                    (isTarget
                            ? _selectedToWalletId == wallet.id
                            : _selectedWalletId == wallet.id)
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                onTap: () {
                  setState(() {
                    if (isTarget) {
                      _selectedToWalletId = wallet.id;
                    } else {
                      _selectedWalletId = wallet.id;
                      if (_selectedToWalletId == wallet.id) {
                        _selectedToWalletId = null;
                      }
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
