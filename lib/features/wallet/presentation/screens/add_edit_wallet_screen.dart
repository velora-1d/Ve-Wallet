import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class AddEditWalletScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final WalletModel? initialWallet;

  const AddEditWalletScreen({
    super.key, 
    this.isEdit = false,
    this.initialWallet,
  });

  @override
  ConsumerState<AddEditWalletScreen> createState() => _AddEditWalletScreenState();
}

class _AddEditWalletScreenState extends ConsumerState<AddEditWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  
  String _selectedType = 'Bank';
  Color _selectedColor = AppColors.primary;
  IconData _selectedIcon = Icons.account_balance_wallet;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _walletTypes = [
    {'name': 'Tunai', 'icon': Icons.money},
    {'name': 'Bank', 'icon': Icons.account_balance},
    {'name': 'E-Wallet', 'icon': Icons.account_balance_wallet},
    {'name': 'Investasi', 'icon': Icons.trending_up},
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

  final List<IconData> _availableIcons = [
    Icons.account_balance_wallet,
    Icons.account_balance,
    Icons.money,
    Icons.credit_card,
    Icons.savings,
    Icons.payments,
    Icons.trending_up,
    Icons.wallet,
  ];

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
    _balanceController.text = wallet.balance.toStringAsFixed(0);
    _selectedColor = Color(wallet.color);
    _selectedIcon = IconData(int.parse(wallet.icon), fontFamily: 'MaterialIcons');
    // Note: Type detection is based on initial name or some mapping, 
    // for now we'll just keep the default or maybe add 'type' to model later
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

        final walletRepo = ref.read(walletRepositoryProvider);

        final balance = double.tryParse(_balanceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

        final wallet = WalletModel(
          id: widget.isEdit ? (widget.initialWallet?.id ?? '') : '',
          userId: user.id,
          name: _nameController.text,
          balance: balance,
          color: _selectedColor.toARGB32(),
          icon: _selectedIcon.codePoint.toString(),
          createdAt: widget.isEdit ? widget.initialWallet?.createdAt : DateTime.now(),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan dompet: $e')),
          );
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.isEdit ? 'Edit Dompet' : 'Tambah Dompet Baru',
          style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          _isLoading 
            ? const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
            : TextButton(
                onPressed: _saveWallet,
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          const SizedBox(width: 8),
        ],
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Tabungan Utama',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Balance Input
              _buildSectionTitle('Saldo Awal'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) => value!.isEmpty ? 'Saldo tidak boleh kosong' : null,
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Wallet Type
              _buildSectionTitle('Tipe Dompet'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _walletTypes.map((type) {
                  final isSelected = _selectedType == type['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type['name']),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryContainer : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? null : Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Icon(
                            type['icon'],
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                          border: isSelected ? Border.all(color: AppColors.onSurface, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
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
                children: _availableIcons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: _selectedColor, width: 2) : Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : AppColors.onSurfaceVariant,
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedColor,
            _selectedColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_selectedIcon, color: Colors.white, size: 28),
              ),
              Text(
                _selectedType,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            _nameController.text.isEmpty ? 'Nama Dompet' : _nameController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp ${_balanceController.text.isEmpty ? '0' : _balanceController.text}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
