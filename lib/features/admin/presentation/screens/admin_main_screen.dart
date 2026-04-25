import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
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
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                  label: 'Security',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
