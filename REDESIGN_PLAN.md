# 🎨 VE-WALLET PREMIUM REDESIGN PLAN

## 📋 EXECUTIVE SUMMARY

**Status Audit**: Ditemukan **15+ masalah UI/UX critical** yang menyebabkan tampilan tidak konsisten, teks putih di background putih, flow membingungkan, dan desain belum premium.

**Target**: Transformasi total menjadi aplikasi **luxury fintech** dengan standar desain seperti Flip, Jenius, Bank Jago.

---

## 🔴 MASALAH CRITICAL YANG DITEMUKAN

### 1. **KONTRAS WARNA BERMASALAH** (Priority: CRITICAL)
| File | Line | Masalah | Impact |
|------|------|---------|--------|
| `dashboard_screen.dart` | 23 | `backgroundColor: Color(0xFFF8FAFC)` - Abu sangat terang | Teks abu-abu sulit dibaca |
| `goal_list_screen.dart` | 18 | `backgroundColor: Color(0xFFF8FAFC)` | Sama seperti atas |
| `budget_list_screen.dart` | 22 | `backgroundColor: Color(0xFFF8FAFC)` | Sama seperti atas |
| `transaction_screen.dart` | 59 | `Colors.white.withValues(alpha: 0.75)` pada glass AppBar | Konten di bawahnya terlihat blur |
| `wallet_screen.dart` | 45 | `color: Colors.white` pada profile button | Border outlineVariant terlalu tipis |
| `report_screen.dart` | 363, 437, 493, 553, 877, 912, 985 | Multiple `Colors.white` hardcoded | Tidak responsif dark mode |

### 2. **TEKS PUTIH DI BACKGROUND PUTIH** (Priority: CRITICAL)
```dart
// dashboard_screen.dart line 321-322
Container(
  color: Colors.white,  // ✅ OK
  child: Text(
    'Total saldo household',
    style: TextStyle(color: Color(0xFF64748B)), // ✅ OK abu-abu gelap
  ),
)

// TAPI DI TEMPAT LAIN:
Text(
  'Some text',
  style: TextStyle(color: Colors.white), // ❌ MASALAH: di background putih
)
```

**Lokasi spesifik**:
- `report_screen.dart`: Chart labels putih di card putih
- `admin_dashboard_screen.dart`: Multiple cards dengan teks putih di background putih
- `shared_account_screen.dart`: Icon putih di background transparan

### 3. **INCONSISTENT DESIGN SYSTEM** (Priority: HIGH)
```dart
// Ada 5 variasi background berbeda:
Color(0xFFF8FAFC)  // dashboard, goals, budget
Color(0xFFFAF8FF)  // AppColors.background
Color(0xFFFFFFFF)  // pure white
AppColors.surfaceContainerLowest  // wallet
Theme.of(context).scaffoldBackgroundColor  // settings
```

### 4. **FLOW UX MEMBINGUNGKAN** (Priority: HIGH)

#### A. **Navigation Flow Issues**
```
❌ MASALAH:
Dashboard → Settings → Profile → Back ke Dashboard (hilang context)
Transaction → Filter → Multi-select → Apply (tidak ada preview)
Wallet → Add Wallet → Tidak ada konfirmasi sukses yang jelas

✅ SOLUSI YANG DIRENCANAKAN:
- Implementasi nested navigation dengan state preservation
- Filter preview sebelum apply
- Success toast dengan haptic feedback
```

#### B. **Empty State Confusion**
```dart
// dashboard_screen.dart line 186-198
_HeroCard(
  title: 'Dashboard belum punya data',
  subtitle: 'Saat ini akun kamu belum terhubung ke shared account...',
)
// ❌ User bingung: harus buat apa dulu?

✅ SOLUSI: Step-by-step onboarding dengan progress indicator
```

#### C. **Report Screen Overwhelming**
```
❌ 4 charts + 3 period selectors + export options dalam 1 screen
✅ SOLUSI: Tabbed interface (Overview | Cashflow | Category | Trend)
```

---

## 🎯 REDESIGN STRATEGY

### **PHASE 1: FOUNDATION FIX** (Week 1)

#### 1.1 **Unified Color Palette** - "Luxury Fintech"
```dart
class AppColors {
  // NEW PRIMARY PALETTE - Deep Ocean Blue
  static const primary = Color(0xFF0A2540);      // Navy deep
  static const primaryLight = Color(0xFF1E3A5F); // Navy medium
  static const primaryAccent = Color(0xFF00D4AA); // Teal accent
  
  // NEW SURFACE PALETTE - Clean White Series
  static const surface = Color(0xFFFFFFFF);           // Pure white
  static const surfaceSubtle = Color(0xFFF8F9FA);     // Very light gray
  static const surfaceMuted = Color(0xFFF1F3F5);      // Light gray
  
  // NEW TEXT PALETTE - High Contrast
  static const textPrimary = Color(0xFF0F172A);       // Almost black
  static const textSecondary = Color(0xFF475569);     // Medium gray
  static const textTertiary = Color(0xFF94A3B8);      // Light gray
  
  // STATUS COLORS - Refined
  static const success = Color(0xFF10B981);           // Emerald
  static const warning = Color(0xFFF59E0B);           // Amber
  static const error = Color(0xFFEF4444);             // Red
  static const info = Color(0xFF3B82F6);              // Blue
  
  // GRADIENTS - Premium Feel
  static const gradientPrimary = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF0A2540), Color(0xFF1E3A5F), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

#### 1.2 **Typography System** - "Plus Jakarta Sans Premium"
```dart
class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';
  
  // Display - Hero sections
  static const displayLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.02,
  );
  static const displayMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.01,
  );
  
  // Headline - Section titles
  static const headlineLarge = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0,
  );
  static const headlineMedium = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0,
  );
  
  // Body - Content
  static const bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.4,
  );
  
  // Label - Buttons, chips
  static const labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.02,
  );
  static const labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.03,
  );
}
```

#### 1.3 **Spacing & Radius System**
```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 9999;
}
```

---

### **PHASE 2: SCREEN-BY-SCREEN REDESIGN** (Week 2-3)

#### 2.1 **Dashboard Screen** ⭐⭐⭐⭐⭐
**Current Issues**:
- Background abu-abu terlalu terang
- Hero card gradient terlalu gelap
- Chart bars tidak ada tooltip
- Empty state tidak actionable

**Redesign Plan**:
```dart
Scaffold(
  backgroundColor: AppColors.surfaceSubtle, // ✅ Konsisten
  body: CustomScrollView(
    slivers: [
      // Sliver 1: Premium Hero Card
      SliverToBoxAdapter(
        child: _PremiumHeroCard(
          totalBalance: totalBalance,
          incomeMonth: income,
          expenseMonth: expense,
          onRefresh: () => refresh(),
        ),
      ),
      
      // Sliver 2: Quick Actions (NEW)
      SliverToBoxAdapter(
        child: _QuickActionsRow([
          QuickAction(icon: Icons.add, label: 'Transaksi', onTap: addTx),
          QuickAction(icon: Icons.wallet, label: 'Dompet', onTap: goWallet),
          QuickAction(icon: Icons.pie_chart, label: 'Laporan', onTap: goReport),
          QuickAction(icon: Icons.target, label: 'Goals', onTap: goGoals),
        ]),
      ),
      
      // Sliver 3: Expense Chart with improvements
      SliverToBoxAdapter(child: _EnhancedExpenseChart()),
      
      // Sliver 4: Goals Preview (max 3)
      SliverToBoxAdapter(child: _GoalsPreview()),
      
      // Sliver 5: Budget Alerts (if any)
      if (hasAlerts) SliverToBoxAdapter(child: _BudgetAlerts()),
      
      // Sliver 6: Recent Transactions
      SliverToBoxAdapter(child: _RecentTransactions()),
    ],
  ),
)
```

**New Features**:
- ✅ Balance skeleton dengan shimmer effect
- ✅ Pull-to-refresh dengan custom indicator
- ✅ Chart tooltip on long-press
- ✅ Transaction swipe-to-edit
- ✅ Goal progress animation

---

#### 2.2 **Transaction Screen** ⭐⭐⭐⭐⭐
**Current Issues**:
- Glass AppBar terlalu blur
- Filter overlay menutupi semua screen
- Search toggle tidak intuitive
- No bulk actions

**Redesign Plan**:
```dart
Scaffold(
  backgroundColor: AppColors.surfaceSubtle,
  appBar: AppBar(
    backgroundColor: AppColors.surface, // ✅ Solid white, no blur
    elevation: 0,
    title: SearchField(
      hintText: 'Cari transaksi...',
      onChanged: search,
      prefixIcon: Icons.search,
    ),
    actions: [
      FilterChipGroup(filters: activeFilters),
      IconButton(icon: Icons.filter_list, onPressed: showFilterSheet),
    ],
  ),
  body: Column(
    children: [
      // Quick Filter Bar (NEW)
      _QuickFilterBar(
        selectedPeriod: period,
        selectedType: type,
        onFilterChange: updateFilters,
      ),
      
      // Transaction List with grouping
      Expanded(
        child: GroupedListView(
          groupBy: (tx) => _groupDate(tx.date),
          groupHeaderBuilder: (date) => _DateHeader(date),
          itemBuilder: (tx) => _TransactionTile(tx),
        ),
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton.extended(
    icon: Icon(Icons.add),
    label: Text('Transaksi'),
    onPressed: addTransaction,
  ),
)
```

**New Features**:
- ✅ Persistent search bar
- ✅ Quick filter chips (Today, Week, Month)
- ✅ Bottom sheet filter dengan live preview
- ✅ Swipe left: Edit, Swipe right: Delete
- ✅ Bulk select mode
- ✅ Category icon dengan color coding

---

#### 2.3 **Report Screen** ⭐⭐⭐⭐
**Current Issues**:
- Terlalu banyak chart dalam 1 page
- Period selector membingungkan
- Export hidden in bottom sheet
- Chart labels putih di background putih

**Redesign Plan**:
```dart
DefaultTabController(
  length: 4,
  child: Scaffold(
    appBar: AppBar(
      title: Text('Laporan'),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.trending_up), text: 'Arus Kas'),
          Tab(icon: Icon(Icons.pie_chart), text: 'Kategori'),
          Tab(icon: Icon(Icons.show_chart), text: 'Tren'),
        ],
      ),
      actions: [
        IconButton(icon: Icons.share, onPressed: export),
      ],
    ),
    body: TabBarView(
      children: [
        _OverviewTab(),      // Summary cards + mini charts
        _CashflowTab(),      // Bar chart income vs expense
        _CategoryTab(),      // Donut chart + legend
        _TrendTab(),         // Line chart 6 months
      ],
    ),
  ),
)
```

**Tab Details**:
- **Overview**: Total income/expense, net savings, top categories
- **Arus Kas**: Vertical bar chart, toggle income/expense
- **Kategori**: Interactive donut (tap to see details), legend dengan % 
- **Tren**: Line chart 6 bulan, comparison mode

---

#### 2.4 **Wallet Screen** ⭐⭐⭐⭐
**Current Issues**:
- Profile button border terlalu tipis
- Total balance card terlalu kecil
- No wallet analytics
- Archive feature incomplete

**Redesign Plan**:
```dart
Scaffold(
  backgroundColor: AppColors.surfaceSubtle,
  appBar: AppBar(
    title: Text('Dompet'),
    actions: [
      IconButton(icon: Icons.qr_code, onPressed: scanQR),
      IconButton(icon: Icons.add, onPressed: addWallet),
    ],
  ),
  body: SingleChildScrollView(
    child: Column(
      children: [
        // Hero: Total Balance dengan gradient premium
        _TotalBalanceHero(total: totalBalance),
        
        // Wallet Cards Carousel (NEW)
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: wallets.length,
            itemBuilder: (ctx, i) => _WalletCard(wallets[i]),
          ),
        ),
        
        // Wallet Analytics (NEW)
        _WalletAnalytics(
          byType: groupByType(wallets),
          byCurrency: groupByCurrency(wallets),
        ),
        
        // All Wallets List
        _AllWalletsList(wallets: wallets),
      ],
    ),
  ),
)
```

---

#### 2.5 **Goals Screen** ⭐⭐⭐⭐
**Current Issues**:
- Background tidak konsisten
- Progress bar basic
- No celebration on completion
- Deadline urgency not clear

**Redesign Plan**:
```dart
Scaffold(
  backgroundColor: AppColors.surfaceSubtle,
  appBar: AppBar(
    title: Text('Target Tabungan'),
    actions: [
      IconButton(icon: Icons.add, onPressed: addGoal),
    ],
  ),
  body: Column(
    children: [
      // Summary Card (NEW)
      _GoalsSummary(
        totalGoals: goals.length,
        completed: completed.length,
        totalSaved: totalSaved,
      ),
      
      // Active Goals
      Expanded(
        child: ListView.builder(
          itemCount: activeGoals.length,
          itemBuilder: (ctx, i) => _GoalCard(
            goal: activeGoals[i],
            onTap: () => navigateToDetail(activeGoals[i]),
          ),
        ),
      ),
      
      // Completed Goals Section (collapsible)
      _CompletedGoalsSection(goals: completed),
    ],
  ),
)
```

**Goal Card Enhancement**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.surface,
        goal.color.withValues(alpha: 0.05),
      ],
    ),
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(
      color: goal.color.withValues(alpha: 0.2),
      width: 1,
    ),
  ),
  child: Column(
    children: [
      // Header: Icon + Name + Days Left
      _GoalHeader(goal),
      
      // Progress: Animated progress bar dengan percentage
      _AnimatedProgressBar(progress: goal.progress),
      
      // Footer: Amount saved / target + edit/delete
      _GoalFooter(goal),
    ],
  ),
)
```

**New Features**:
- ✅ Confetti animation saat goal completed
- ✅ Urgency badge (🔥 < 7 days, ⚠️ < 30 days)
- ✅ Milestone celebrations (25%, 50%, 75%)
- ✅ Quick add amount button

---

#### 2.6 **Budget Screen** ⭐⭐⭐⭐
**Current Issues**:
- Month picker basic
- Warning system tidak proactive
- No spending trend
- Related transactions hidden

**Redesign Plan**:
```dart
Scaffold(
  backgroundColor: AppColors.surfaceSubtle,
  appBar: AppBar(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Anggaran'),
        SizedBox(width: 8),
        Chip(
          avatar: Icon(Icons.calendar_month, size: 16),
          label: Text(formatMonth(selectedDate)),
          onTap: showMonthPicker,
        ),
      ],
    ),
    actions: [
      IconButton(icon: Icons.add, onPressed: addBudget),
    ],
  ),
  body: Column(
    children: [
      // Budget Health Summary (NEW)
      _BudgetHealthSummary(
        totalBudget: total,
        totalSpent: spent,
        remainingDays: daysLeft,
      ),
      
      // Budget Cards
      Expanded(
        child: ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (ctx, i) => _BudgetCard(
            budget: budgets[i],
            spent: calculateSpent(budgets[i]),
            onTap: () => showBudgetDetail(budgets[i]),
          ),
        ),
      ),
    ],
  ),
)
```

**Budget Card Status**:
```dart
enum BudgetStatus {
  safe,      // < 50% used, green
  warning,   // 50-80% used, yellow
  danger,    // 80-100% used, orange
  exceeded,  // > 100% used, red
}

_BudgetCard(
  status: getStatus(budget),
  categoryIcon: category.icon,
  categoryName: category.name,
  budgetAmount: budget.amount,
  spentAmount: spent,
  percentage: spent / budget.amount,
  transactionCount: txCount,
  onTap: showDetail,
)
```

---

#### 2.7 **Settings Screen** ⭐⭐⭐⭐
**Current Issues**:
- 3 tabs overwhelming
- Some options not working
- Profile section basic
- No backup/export data

**Redesign Plan**:
```dart
Scaffold(
  backgroundColor: AppColors.surfaceSubtle,
  appBar: AppBar(title: Text('Pengaturan')),
  body: ListView(
    children: [
      // Profile Header
      _ProfileHeader(user: currentUser),
      
      // Account Section
      _SettingsSection(
        title: 'Akun',
        items: [
          SettingsTile(icon: Icons.person, label: 'Edit Profil', onTap: editProfile),
          SettingsTile(icon: Icons.security, label: 'Keamanan', onTap: security),
          SettingsTile(icon: Icons.notifications, label: 'Notifikasi', onTap: notifications),
        ],
      ),
      
      // Preferences Section
      _SettingsSection(
        title: 'Preferensi',
        items: [
          SettingsTile(icon: Icons.language, label: 'Bahasa', onTap: language),
          SettingsTile(icon: Icons.palette, label: 'Tema', onTap: theme),
          SettingsTile(icon: Icons.attach_money, label: 'Mata Uang', onTap: currency),
        ],
      ),
      
      // Data Section (NEW)
      _SettingsSection(
        title: 'Data',
        items: [
          SettingsTile(icon: Icons.backup, label: 'Backup Data', onTap: backup),
          SettingsTile(icon: Icons.file_download, label: 'Export CSV', onTap: exportCsv),
          SettingsTile(icon: Icons.restore, label: 'Restore', onTap: restore),
        ],
      ),
      
      // Support Section
      _SettingsSection(
        title: 'Bantuan',
        items: [
          SettingsTile(icon: Icons.help, label: 'Pusat Bantuan', onTap: help),
          SettingsTile(icon: Icons.feedback, label: 'Kirim Feedback', onTap: feedback),
          SettingsTile(icon: Icons.info, label: 'Tentang', onTap: about),
        ],
      ),
      
      // Logout Button
      Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: AnimatedTapButton(
          variant: ButtonVariant.danger,
          label: 'Keluar',
          icon: Icons.logout,
          onTap: logout,
        ),
      ),
    ],
  ),
)
```

---

### **PHASE 3: UX FLOW IMPROVEMENTS** (Week 4)

#### 3.1 **Onboarding Flow Redesign**
```
OLD: Splash → Onboarding (3 slides) → Login/Register → Dashboard
NEW: Splash → Onboarding (interactive) → Auth (biometric option) → Household Setup → Dashboard

Household Setup Flow:
1. Check if has household
2. If no: Show options
   - Create New Household
   - Join with Invite Code
   - Skip for Now (personal mode)
3. Set household name & avatar
4. Done → Dashboard with tutorial overlay
```

#### 3.2 **Add Transaction Flow**
```
OLD: FAB → Bottom Sheet → Form → Submit
NEW: FAB → Modal Bottom Sheet (full screen mobile) → Smart Form → Confirmation → Success Toast

Smart Form Features:
- Auto-complete category based on history
- Recent amounts quick select
- Voice input for amount (future)
- Split transaction support
- Recurring transaction toggle
- Attachment (receipt photo)
```

#### 3.3 **Filter Flow**
```
OLD: Filter icon → Overlay → Select → Apply (no preview)
NEW: Filter icon → Bottom Sheet → Live Preview → Apply/Reset

Live Preview:
- Show result count
- Mini chart preview
- Clear all button
- Save as preset option
```

#### 3.4 **Error Handling**
```dart
// Global error handler
ErrorWidget.builder = (errorDetails) {
  return _FriendlyErrorScreen(
    message: getFriendlyMessage(errorDetails.exception),
    actionLabel: 'Coba Lagi',
    onRetry: errorDetails.context?.refresh,
  );
};

// Specific error states
enum ErrorState {
  network,      // "Koneksi internet bermasalah"
  permission,   // "Akses ditolak, periksa pengaturan"
  empty,        // "Belum ada data"
  timeout,      // "Request timeout, coba lagi"
  unknown,      // "Terjadi kesalahan"
}
```

---

### **PHASE 4: MICRO-INTERACTIONS & POLISH** (Week 4)

#### 4.1 **Animations**
```dart
// Page transitions
PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
)

// List item animations
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: items.map((item) => FadeIn(child: item)).toList(),
)

// Progress bar animations
TweenAnimationBuilder(
  tween: Tween(begin: 0, end: progress),
  duration: Duration(milliseconds: 1000),
  builder: (ctx, value, child) => LinearProgressIndicator(value: value),
)

// Confetti on goal completion
ConfettiWidget(
  confettiKey: confettiKey,
  blastDirectionality: BlastDirectionality.explosive,
  particleDrag: 0.05,
  emissionFrequency: 0.05,
  numberOfParticles: 30,
  gravity: 0.1,
)
```

#### 4.2 **Haptic Feedback**
```dart
// On button tap
HapticFeedback.lightImpact();

// On success
HapticFeedback.mediumImpact();

// On error
HapticFeedback.vibrate();

// On selection changed
HapticFeedback.selectionClick();
```

#### 4.3 **Loading States**
```dart
// Skeleton loaders
AppSkeleton(
  shape: SkeletonShape.rectangular,
  height: 100,
  borderRadius: BorderRadius.circular(16),
)

// Shimmer effect
Shimmer.fromColors(
  baseColor: Colors.grey.shade300,
  highlightColor: Colors.grey.shade100,
  child: _SkeletonUI(),
)

// Progress indicators
CircularProgressIndicator.adaptive()
LinearProgressIndicator(minHeight: 4)
```

---

## 📁 FILE STRUCTURE CHANGES

### **New Files to Create**
```
lib/core/
├── design/
│   ├── app_components.dart (existing, enhance)
│   ├── app_spacing.dart (NEW)
│   ├── app_radius.dart (NEW)
│   └── app_shadows.dart (NEW)
├── theme/
│   ├── app_theme.dart (enhance)
│   ├── app_typography.dart (NEW)
│   └── app_colors.dart (replace)
└── widgets/
    ├── app_skeleton.dart (enhance)
    ├── app_error_state.dart (NEW)
    ├── app_empty_state.dart (NEW)
    ├── app_loading_state.dart (NEW)
    └── app_success_toast.dart (NEW)

lib/features/
├── dashboard/
│   └── presentation/
│       ├── screens/dashboard_screen.dart (redesign)
│       └── widgets/
│           ├── premium_hero_card.dart (NEW)
│           ├── quick_actions_row.dart (NEW)
│           └── enhanced_expense_chart.dart (NEW)
├── transaction/
│   └── presentation/
│       ├── screens/transaction_screen.dart (redesign)
│       └── widgets/
│           ├── quick_filter_bar.dart (NEW)
│           ├── transaction_tile.dart (enhance)
│           └── filter_bottom_sheet.dart (NEW)
├── report/
│   └── presentation/
│       ├── screens/report_screen.dart (redesign)
│       └── widgets/
│           ├── overview_tab.dart (NEW)
│           ├── cashflow_tab.dart (NEW)
│           ├── category_tab.dart (NEW)
│           └── trend_tab.dart (NEW)
├── wallet/
│   └── presentation/
│       ├── screens/wallet_screen.dart (redesign)
│       └── widgets/
│           ├── total_balance_hero.dart (NEW)
│           ├── wallet_card_carousel.dart (NEW)
│           └── wallet_analytics.dart (NEW)
├── goal/
│   └── presentation/
│       ├── screens/goal_list_screen.dart (redesign)
│       └── widgets/
│           ├── goals_summary.dart (NEW)
│           ├── goal_card.dart (enhance)
│           └── confetti_overlay.dart (NEW)
├── budget/
│   └── presentation/
│       ├── screens/budget_list_screen.dart (redesign)
│       └── widgets/
│           ├── budget_health_summary.dart (NEW)
│           ├── budget_card.dart (enhance)
│           └── month_picker_dialog.dart (NEW)
└── settings/
    └── presentation/
        ├── screens/settings_screen.dart (redesign)
        └── widgets/
            ├── profile_header.dart (NEW)
            ├── settings_section.dart (NEW)
            └── settings_tile.dart (NEW)
```

### **Files to Modify**
```
lib/core/constants/app_colors.dart (REPLACE)
lib/core/theme/app_theme.dart (ENHANCE)
lib/core/design/app_components.dart (ENHANCE)
lib/main.dart (add global error handler, theme config)
```

---

## 🎨 DESIGN INSPIRATION REFERENCES

### **Color Palette Inspiration**
- **Flip**: Clean white dengan blue accent
- **Jenius**: Bold gradients, modern typography
- **Bank Jago**: Minimalist, high contrast
- **Wise**: Friendly colors, clear hierarchy

### **Component Inspiration**
- **Cards**: Elevated dengan subtle shadow (elevation 2-4)
- **Buttons**: Rounded corners (12-16px), bold labels
- **Charts**: Minimalist grid, clear labels, interactive tooltips
- **Lists**: Generous padding (16-20px), clear separators

---

## ✅ ACCEPTANCE CRITERIA

### **Visual Quality**
- [ ] Semua teks memiliki kontras ratio ≥ 4.5:1
- [ ] Tidak ada teks putih di background putih
- [ ] Consistent spacing (4px grid system)
- [ ] Consistent border radius (8/12/16/20/28px)
- [ ] All shadows follow elevation system

### **UX Quality**
- [ ] Semua empty state memiliki CTA jelas
- [ ] Semua loading state menggunakan skeleton
- [ ] Semua error state memiliki retry option
- [ ] Semua forms memiliki validation real-time
- [ ] Semua actions memiliki confirmation jika destructive

### **Performance**
- [ ] First paint < 2 seconds
- [ ] List scroll 60fps
- [ ] Chart render < 500ms
- [ ] Navigation transition < 300ms

### **Accessibility**
- [ ] Semua icons memiliki label
- [ ] Semua buttons memiliki min 48x48 touch area
- [ ] Support dynamic font sizing
- [ ] Screen reader compatible

---

## 📊 ESTIMATED EFFORT

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Phase 1: Foundation | Color, Typography, Spacing | 2 days |
| Phase 2: Screens | 7 screens redesign | 8 days |
| Phase 3: UX Flows | Navigation, Forms, Filters | 3 days |
| Phase 4: Polish | Animations, Haptics, Loading | 3 days |
| Testing & Bugfix | QA, fixes | 4 days |
| **TOTAL** | | **20 days (~4 weeks)** |

---

## 🚀 NEXT STEPS

1. **Review Plan Ini** - Pastikan semua sesuai ekspektasi
2. **Approve Design Direction** - Luxury fintech aesthetic
3. **Prioritize Screens** - Mana yang mau dikerjakan duluan
4. **Start Implementation** - Phase by phase
5. **Weekly Review** - Check progress setiap minggu

---

## 💬 CATATAN PENTING

### **Do's** ✅
- Gunakan `AppColors.*` bukan hardcoded colors
- Ikuti spacing system (4px grid)
- Selalu provide empty state
- Add loading states untuk semua async operations
- Test di light & dark mode
- Maintain backward compatibility

### **Don'ts** ❌
- Jangan gunakan `Colors.white` hardcoded
- Jangan mix different background colors
- Jangan skip error handling
- Jangan lupa accessibility
- Jangan hardcode strings (gunakan AppText)

---

**Dibuat oleh**: AI Assistant  
**Tanggal**: 2025  
**Version**: 1.0  

**Status**: Menunggu Review & Approval

