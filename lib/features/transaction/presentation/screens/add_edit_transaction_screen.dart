import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
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
  String? _receiptUrl;
  XFile? _receiptFile;
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
        _receiptUrl = tx.receiptUrl;
      });
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(context, 'Gagal memuat data transaksi: $e');
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
      AppUI.showWarning(context, 'Nominal harus lebih dari 0');
      return;
    }

    if (_selectedWalletId == null) {
      AppUI.showWarning(context, 'Pilih dompet asal');
      return;
    }

    if (_isTransfer) {
      if (_selectedToWalletId == null) {
        AppUI.showWarning(context, 'Pilih dompet tujuan');
        return;
      }
      if (_selectedWalletId == _selectedToWalletId) {
        AppUI.showWarning(context, 'Dompet asal dan tujuan tidak boleh sama');
        return;
      }
    } else if (_selectedCategoryId == null) {
      AppUI.showWarning(context, 'Pilih kategori');
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
        receiptUrl: await _resolveReceiptUrl(user.id),
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
      AppUI.showError(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _resolveReceiptUrl(String userId) async {
    if (_receiptFile == null) {
      return _receiptUrl;
    }

    final extensionIndex = _receiptFile!.path.lastIndexOf('.');
    final extension = extensionIndex >= 0
        ? _receiptFile!.path.substring(extensionIndex)
        : '.jpg';
    final fileName =
        '$userId/${DateTime.now().millisecondsSinceEpoch}$extension';
    final file = File(_receiptFile!.path);

    try {
      await Supabase.instance.client.storage
          .from('receipts')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      return Supabase.instance.client.storage.from('receipts').getPublicUrl(
            fileName,
          );
    } catch (_) {
      return _receiptFile!.path;
    }
  }

  bool _isLocalReceiptPath(String value) {
    return !value.startsWith('http://') && !value.startsWith('https://');
  }

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1800,
      );
      if (file == null || !mounted) return;
      setState(() {
        _receiptFile = file;
        _receiptUrl = null;
      });
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(context, 'Gagal mengambil foto struk: $e');
    }
  }

  void _showReceiptPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickReceipt(ImageSource.gallery);
                },
              ),
              if (_receiptFile != null || _receiptUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Foto Struk'),
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _receiptFile = null;
                      _receiptUrl = null;
                    });
                  },
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

    Color activeColor;
    Color activeBg;

    switch (type) {
      case TransactionType.expense:
        activeColor = const Color(0xFFEF4444);
        activeBg = const Color(0xFFFEF2F2);
        break;
      case TransactionType.income:
        activeColor = const Color(0xFF10B981);
        activeBg = const Color(0xFFECFDF5);
        break;
      case TransactionType.transfer:
        activeColor = const Color(0xFF3B82F6);
        activeBg = const Color(0xFFEFF6FF);
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _setTransactionType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? activeColor : const Color(0xFF64748B),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(NumberFormat formatter) {
    final value = int.tryParse(_amountString) ?? 0;
    final displayAmount = formatter.format(value);

    Color themeColor;
    switch (_selectedType) {
      case TransactionType.expense:
        themeColor = const Color(0xFFEF4444);
        break;
      case TransactionType.income:
        themeColor = const Color(0xFF10B981);
        break;
      case TransactionType.transfer:
        themeColor = const Color(0xFF3B82F6);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.08),
            themeColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            _isTransfer ? 'NOMINAL TRANSFER' : 'NOMINAL TRANSAKSI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: themeColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: themeColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayAmount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: themeColor,
                      letterSpacing: -1.5,
                    ),
                  ),
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
              child: InkWell(
                onTap: () => _handlePresetPress(value),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
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
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: isSpecial ? Colors.transparent : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isSpecial
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 24, color: const Color(0xFF1E293B))
              : Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
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
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Color(category.color)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(category.color).withValues(alpha: isSelected ? 0.2 : 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CategoryUtils.getIcon(category.icon),
                                color: Color(category.color),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (wallet != null ? Color(wallet.color) : AppColors.primary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                wallet != null ? WalletIconUtils.getIcon(wallet.icon) : icon,
                size: 20,
                color: wallet != null ? Color(wallet.color) : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    wallet?.name ?? 'Pilih Dompet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TANGGAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
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
    final hasReceipt = _receiptFile != null || _receiptUrl != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                    ),
                  ),
                  child: TextField(
                    controller: _noteController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: _isTransfer
                          ? 'Catatan transfer...'
                          : 'Tambah catatan...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      icon: const Icon(
                        Icons.sticky_note_2_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showReceiptPicker,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasReceipt 
                        ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                        : [AppColors.surfaceContainerHigh.withValues(alpha: 0.5), AppColors.surfaceContainerHigh.withValues(alpha: 0.3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: hasReceipt ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Icon(
                    hasReceipt
                        ? Icons.receipt_long_rounded
                        : Icons.add_a_photo_rounded,
                    color: hasReceipt ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          if (hasReceipt) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: _receiptFile != null
                          ? Image.file(
                              File(_receiptFile!.path),
                              fit: BoxFit.cover,
                            )
                          : _isLocalReceiptPath(_receiptUrl!)
                              ? Image.file(
                                  File(_receiptUrl!),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _receiptUrl!,
                                  fit: BoxFit.cover,
                                ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _receiptFile = null;
                          _receiptUrl = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rocket_launch_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.isEdit
                          ? (_isTransfer
                                ? 'Update Transfer'
                                : 'Simpan Perubahan')
                          : (_isTransfer ? 'Kirim Transfer' : 'Catat Transaksi'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
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
