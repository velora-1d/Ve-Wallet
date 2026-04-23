import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ve_wallet/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:ve_wallet/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:ve_wallet/features/report/presentation/screens/report_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionScreen(),
    const ReportScreen(),
    const WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransaction() {
    context.push('/add-transaction');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransaction,
        backgroundColor: AppColors.primaryContainer,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildNavItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard,
                    'Home',
                  ),
                  _buildNavItem(
                    1,
                    Icons.receipt_long_outlined,
                    Icons.receipt_long,
                    'Activity',
                  ),
                ],
              ),
              const SizedBox(width: 40), // Space for FAB
              Row(
                children: [
                  _buildNavItem(
                    2,
                    Icons.bar_chart_outlined,
                    Icons.bar_chart,
                    'Report',
                  ),
                  _buildNavItem(
                    3,
                    Icons.account_balance_wallet_outlined,
                    Icons.account_balance_wallet,
                    'Dompet',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.outline,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
