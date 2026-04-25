import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ve_wallet/features/report/presentation/screens/report_screen.dart';
import 'package:ve_wallet/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:ve_wallet/features/wallet/presentation/screens/wallet_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _selectedIndex;
  final List<int> _tabHistory = [];

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionScreen(),
    ReportScreen(),
    WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    if (_selectedIndex != 0) {
      _tabHistory.add(0);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _tabHistory.add(_selectedIndex);
      _selectedIndex = index;
    });
  }

  void _handleBackNavigation() {
    if (_tabHistory.isNotEmpty) {
      setState(() {
        _selectedIndex = _tabHistory.removeLast();
      });
    }
  }

  void _showAddTransaction() {
    context.push('/add-transaction');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _selectedIndex, children: _screens),
        floatingActionButton: SizedBox(
          height: 62,
          width: 62,
          child: FloatingActionButton(
            onPressed: _showAddTransaction,
            backgroundColor: AppColors.primary,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              height: 72,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Aktivitas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insert_chart_outlined_rounded),
                  selectedIcon: Icon(Icons.insert_chart_rounded),
                  label: 'Laporan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Dompet',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
