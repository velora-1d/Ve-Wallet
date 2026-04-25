import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/core/utils/nominal_input_formatter.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
import 'package:ve_wallet/features/shared_account/presentation/providers/shared_account_provider.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditWalletScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final WalletModel? initialWallet;

  const AddEditWalletScreen({
    super.key,
    this.isEdit = false,
    this.initialWallet,
  });

  @override
  ConsumerState<AddEditWalletScreen> createState() =>
      _AddEditWalletScreenState();
}

class _AddEditWalletScreenState extends ConsumerState<AddEditWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedType = 'Bank';
  Color _selectedColor = AppColors.primary;
  String _selectedIconKey = WalletIconUtils.defaultIconKey;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _walletTypes = [
    {'name': 'Tunai', 'dbValue': 'cash', 'icon': Icons.money},
    {'name': 'Bank', 'dbValue': 'bank', 'icon': Icons.account_balance},
    {
      'name': 'E-Wallet',
      'dbValue': 'ewallet',
      'icon': Icons.account_balance_wallet,
    },
  ];

  final List<Color> _availableColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    AppColors.success,
    Colors.deepPurple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  final List<String> _availableIcons = WalletIconUtils.walletIcons.keys.toList(
    growable: false,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialWallet != null) {
      _loadWalletData();
    }
  }

  void _loadWalletData() {
    final wallet = widget.initialWallet!;
    _nameController.text = wallet.name;
    _balanceController.text = NominalInputFormatter.formatNumber(
      wallet.balance.toInt(),
    );
    _selectedColor = Color(wallet.color);
    _selectedIconKey = WalletIconUtils.resolveIconKey(wallet.icon);
    final matchedType = _walletTypes.firstWhere(
      (type) => type['dbValue'] == wallet.type,
      orElse: () => _walletTypes[1],
    );
    _selectedType = matchedType['name'] as String;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = ref.read(currentUserProvider);
        if (user == null) throw Exception('User not logged in');
        final currentHousehold = await ref.read(
          sharedAccountRepositoryProvider,
        ).getCurrentHousehold();
        if (currentHousehold == null) {
          throw Exception('Buat atau gabung shared account dulu sebelum menambah dompet');
        }

        final walletRepo = ref.read(walletRepositoryProvider);

        final balance = NominalInputFormatter.parseToDouble(
          _balanceController.text,
        );
        final selectedType = _walletTypes.firstWhere(
          (type) => type['name'] == _selectedType,
          orElse: () => _walletTypes[1],
        );

        final wallet = WalletModel(
          id: widget.isEdit ? (widget.initialWallet?.id ?? '') : '',
          userId: user.id,
          householdId: widget.isEdit
              ? (widget.initialWallet?.householdId ?? currentHousehold.id)
              : currentHousehold.id,
          name: _nameController.text,
          type: selectedType['dbValue'] as String,
          balance: balance,
          color: _selectedColor.toARGB32(),
          icon: _selectedIconKey,
          createdAt: widget.isEdit
              ? widget.initialWallet?.createdAt
              : DateTime.now(),
        );

        if (widget.isEdit) {
          await walletRepo.updateWallet(wallet);
        } else {
          await walletRepo.addWallet(wallet);
        }

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          AppUI.showError(context, 'Gagal menyimpan dompet: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.isEdit ? 'Edit Dompet' : 'Dompet Baru',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveWallet,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  widget.isEdit ? 'Simpan Perubahan' : 'Buat Dompet Sekarang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              _buildPreviewCard(),
              const SizedBox(height: 32),

              // Name Input
              _buildSectionTitle('Nama Dompet'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Tabungan Utama',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  onChanged: (val) => setState(() {}),
                ),
              ),
              const SizedBox(height: 24),

              // Balance Input
              _buildSectionTitle('Saldo Saat Ini'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NominalInputFormatter()],
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Rp',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    hintText: '0',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Saldo tidak boleh kosong' : null,
                  onChanged: (val) => setState(() {}),
                ),
              ),
              const SizedBox(height: 24),

              // Wallet Type
              _buildSectionTitle('Tipe Dompet'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _walletTypes.map((type) {
                    final isSelected = _selectedType == type['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type['name']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                ? const Color(0xFF0F172A).withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              type['icon'],
                              size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Color Selection
              _buildSectionTitle('Warna Ikon'),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.onSurface, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Icon Selection
              _buildSectionTitle('Ikon Dompet'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _availableIcons.map((iconKey) {
                  final icon = WalletIconUtils.getIcon(iconKey);
                  final isSelected = _selectedIconKey == iconKey;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconKey = iconKey),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? _selectedColor
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E293B),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedColor,
            _selectedColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            WalletIconUtils.getIcon(_selectedIconKey),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedType.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    _nameController.text.isEmpty ? 'NAMA DOMPET' : _nameController.text.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_balanceController.text.isEmpty ? '0' : _balanceController.text}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
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
}
