import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/category_utils.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
import 'package:ve_wallet/features/category/presentation/providers/category_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? transactionId;

  const AddEditTransactionScreen({
    super.key,
    this.isEdit = false,
    this.transactionId,
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
  String? _selectedCategoryId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransactionData();
      });
    }
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
        _selectedCategoryId = tx.categoryId;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data transaksi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleNumpadPress(String val) {
    setState(() {
      if (val == 'backspace') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (val == ',') {
        // IDR usually doesn't use decimals, but we'll add logic if it's not already there
        if (!_amountString.contains(',')) {
          _amountString += ',';
        }
      } else {
        if (_amountString == '0') {
          _amountString = val;
        } else if (_amountString.replaceAll(',', '').length < 12) {
          _amountString += val;
        }
      }
    });
  }

  void _handlePresetPress(String val) {
    setState(() {
      final cleanAmount = _amountString.replaceAll(',', '');
      final currentAmount = int.tryParse(cleanAmount) ?? 0;
      final presetVal = int.parse(val.replaceAll('rb', '000'));
      _amountString = (currentAmount + presetVal).toString();
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
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Dompet dan Kategori')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final categories = await ref
          .read(categoryRepositoryProvider)
          .getCategories(type: _selectedType);
      final selectedCat = categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
      );

      final transaction = TransactionModel(
        id: widget.isEdit ? widget.transactionId! : '',
        userId: user.id,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId!,
        categoryName: selectedCat.name,
        type: _selectedType,
        amount: amount,
        note: _noteController.text,
        date: _selectedDate,
      );

      if (widget.isEdit) {
        await ref
            .read(transactionRepositoryProvider)
            .updateTransaction(transaction);
      } else {
        await ref
            .read(transactionRepositoryProvider)
            .addTransaction(transaction);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider(_selectedType));

    // Custom formatter for IDR style (dot for thousand separator)
    final formatter = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      backgroundColor: Colors.black.withValues(
        alpha: 0.4,
      ), // Simulated overlay background
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
              // Drag Handle
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
                      // Type Tabs
                      _buildTypeTabs(),

                      const SizedBox(height: 16),

                      // Amount Display
                      _buildAmountDisplay(formatter),

                      const SizedBox(height: 16),

                      // Quick Presets
                      _buildQuickPresets(),

                      const SizedBox(height: 24),

                      // Custom Numpad
                      _buildNumpad(),

                      const SizedBox(height: 32),

                      // Category Selection (Horizontal)
                      _buildCategoryPicker(categoriesAsync),

                      const SizedBox(height: 32),

                      // Wallet & Date
                      _buildWalletAndDatePicker(walletsAsync),

                      const SizedBox(height: 16),

                      // Note & Photo
                      _buildNoteAndPhotoSection(),

                      const SizedBox(height: 120), // Padding for sticky button
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
          _buildTypeTabItem('Transfer', null, isTransfer: true),
        ],
      ),
    );
  }

  Widget _buildTypeTabItem(
    String label,
    TransactionType? type, {
    bool isTransfer = false,
  }) {
    final isSelected = isTransfer
        ? false
        : _selectedType == type; // Transfer logic not yet fully implemented

    Color bgColor = const Color(0xFFEAEDFF);
    Color textColor = const Color(0xFF434655);

    if (isSelected) {
      if (type == TransactionType.expense) {
        bgColor = const Color(0xFFFFDAD6);
        textColor = const Color(0xFFBA1A1A);
      } else if (type == TransactionType.income) {
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: isTransfer
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Transfer akan segera hadir!'),
                  ),
                );
              }
            : () {
                setState(() {
                  _selectedType = type!;
                  _selectedCategoryId = null;
                });
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
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
    // Parsing amount for display
    String displayAmount = _amountString;
    if (!displayAmount.contains(',')) {
      final value = int.tryParse(displayAmount) ?? 0;
      displayAmount = formatter.format(value);
    } else {
      // Handle decimals manually to keep formatter's style
      final parts = displayAmount.split(',');
      final whole = int.tryParse(parts[0]) ?? 0;
      displayAmount = '${formatter.format(whole)},${parts[1]}';
    }

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
            'Nominal Transaksi',
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
        children: ['10rb', '20rb', '50rb', '100rb'].map((val) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                onPressed: () => _handlePresetPress(val),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: Color(0xFFFD761A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  val,
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
      children: values.map((val) {
        if (val == 'backspace') {
          return _buildNumpadButton(val, icon: Icons.backspace_outlined);
        }
        return _buildNumpadButton(val);
      }).toList(),
    );
  }

  Widget _buildNumpadButton(String val, {IconData? icon}) {
    final isSpecial = val == ',' || val == 'backspace';
    return GestureDetector(
      onTap: () => _handleNumpadPress(val),
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
                  val,
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

  Widget _buildCategoryPicker(AsyncValue categoriesAsync) {
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
                  final cat = categories[index];
                  final isSelected = _selectedCategoryId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: isSelected
                                ? const EdgeInsets.all(2)
                                : null,
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
                                color: Color(cat.color).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CategoryUtils.getIcon(cat.icon),
                                color: Color(cat.color),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
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
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $err'),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletAndDatePicker(AsyncValue walletsAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Wallet Picker
          Expanded(
            child: walletsAsync.when(
              data: (wallets) {
                final selectedWallet = wallets.cast<dynamic>().firstWhere(
                  (w) => w.id == _selectedWalletId,
                  orElse: () => null,
                );
                return GestureDetector(
                  onTap: () => _showWalletSelector(context, wallets),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEDFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                          color: Color(0xFF737686),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dompet',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF737686),
                                ),
                              ),
                              Text(
                                selectedWallet?.name ?? 'Pilih Dompet',
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
              },
              loading: () => Container(),
              error: (error, stack) => Container(),
            ),
          ),
          const SizedBox(width: 12),
          // Date Picker
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
            ),
          ),
        ],
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
                  hintText: 'Tambah catatan...',
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
                const SnackBar(
                  content: Text('Fitur Kamera akan segera hadir!'),
                ),
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
                    widget.isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi',
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

  void _showWalletSelector(BuildContext context, List<dynamic> wallets) {
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
              'Pilih Dompet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...wallets.map(
              (w) => ListTile(
                leading: Icon(
                  WalletIconUtils.getIcon(w.icon),
                  color: Color(w.color),
                ),
                title: Text(
                  w.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                trailing: _selectedWalletId == w.id
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedWalletId = w.id);
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
