import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/features/splash/presentation/screens/splash_screen.dart';
import 'package:ve_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:ve_wallet/features/auth/presentation/screens/login_screen.dart';
import 'package:ve_wallet/features/auth/presentation/screens/register_screen.dart';
import 'package:ve_wallet/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ve_wallet/features/main/presentation/screens/main_screen.dart';
import 'package:ve_wallet/features/admin/presentation/screens/admin_main_screen.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/screens/wallet_detail_screen.dart';
import 'package:ve_wallet/features/wallet/presentation/screens/add_edit_wallet_screen.dart';
import 'package:ve_wallet/features/report/presentation/screens/report_screen.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/screens/transaction_detail_screen.dart';
import 'package:ve_wallet/features/transaction/presentation/screens/add_edit_transaction_screen.dart';
import 'package:ve_wallet/features/settings/presentation/screens/settings_screen.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/presentation/screens/category_settings_screen.dart';
import 'package:ve_wallet/features/category/presentation/screens/add_edit_category_screen.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
import 'package:ve_wallet/features/budget/domain/models/budget_model.dart';
import 'package:ve_wallet/features/budget/presentation/screens/budget_list_screen.dart';
import 'package:ve_wallet/features/budget/presentation/screens/add_edit_budget_screen.dart';
import 'package:ve_wallet/features/goal/domain/models/goal_model.dart';
import 'package:ve_wallet/features/goal/presentation/screens/goal_list_screen.dart';
import 'package:ve_wallet/features/goal/presentation/screens/add_edit_goal_screen.dart';
import 'package:ve_wallet/features/goal/presentation/screens/goal_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.value;
      final isAuthPath = state.uri.path == '/login' || 
                        state.uri.path == '/register' || 
                        state.uri.path == '/onboarding' ||
                        state.uri.path == '/';

      if (authState.isLoading) return null;

      if (user == null) {
        if (!isAuthPath && state.uri.path != '/forgot-password') return '/login';
      } else {
        if (isAuthPath) return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/wallet-detail',
        builder: (context, state) {
          final wallet = state.extra as WalletModel;
          return WalletDetailScreen(wallet: wallet);
        },
      ),
      GoRoute(
        path: '/add-wallet',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isEdit = extra?['isEdit'] as bool? ?? false;
          final initialWallet = extra?['wallet'] as WalletModel?;
          return AddEditWalletScreen(isEdit: isEdit, initialWallet: initialWallet);
        },
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddEditTransactionScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/transaction-detail',
        builder: (context, state) {
          final transaction = state.extra as TransactionModel;
          return TransactionDetailScreen(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/category-settings',
        builder: (context, state) => const CategorySettingsScreen(),
      ),
      GoRoute(
        path: '/add-edit-category',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isEdit = extra?['isEdit'] as bool? ?? false;
          final category = extra?['category'] as CategoryModel?;
          final type = extra?['type'] as TransactionType?;
          return AddEditCategoryScreen(
            isEdit: isEdit,
            initialCategory: category,
            initialType: type,
          );
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainScreen(),
      ),
      GoRoute(
        path: '/budget-list',
        builder: (context, state) => const BudgetListScreen(),
      ),
      GoRoute(
        path: '/add-edit-budget',
        builder: (context, state) {
          final budget = state.extra as BudgetModel?;
          return AddEditBudgetScreen(initialBudget: budget);
        },
      ),
      GoRoute(
        path: '/goal-list',
        builder: (context, state) => const GoalListScreen(),
      ),
      GoRoute(
        path: '/goal-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GoalDetailScreen(goalId: id);
        },
      ),
      GoRoute(
        path: '/add-edit-goal',
        builder: (context, state) {
          final goal = state.extra as GoalModel?;
          return AddEditGoalScreen(initialGoal: goal);
        },
      ),
    ],
  );
});
