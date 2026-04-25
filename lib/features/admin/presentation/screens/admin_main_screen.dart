import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/widgets/app_bottom_nav.dart';
import 'package:ve_wallet/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:ve_wallet/features/admin/presentation/screens/admin_history_screen.dart';
import 'package:ve_wallet/features/admin/presentation/screens/admin_profile_screen.dart';
import 'package:ve_wallet/features/admin/presentation/screens/admin_security_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  static const _navItems = [
    AppBottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings_rounded,
      label: 'Security',
    ),
    AppBottomNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    AppBottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int _selectedIndex = 0;
  final List<int> _tabHistory = [];

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminSecurityScreen(),
    AdminHistoryScreen(),
    AdminProfileScreen(),
  ];

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
          accentColor: AppColors.primary,
        ),
      ),
    );
  }
}
