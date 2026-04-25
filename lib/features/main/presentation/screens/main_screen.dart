import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/widgets/app_bottom_nav.dart';
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
  static const _navItems = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Aktivitas',
    ),
    AppBottomNavItem(
      icon: Icons.insert_chart_outlined_rounded,
      activeIcon: Icons.insert_chart_rounded,
      label: 'Laporan',
    ),
    AppBottomNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Dompet',
    ),
  ];

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
          height: 66,
          width: 66,
          child: FloatingActionButton(
            onPressed: _showAddTransaction,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
          withCenterGap: true,
          accentColor: AppColors.primary,
        ),
      ),
    );
  }
}
