import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route destinations for sidebar
// ─────────────────────────────────────────────────────────────────────────────
class NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

const List<NavDestination> kDestinations = [
  NavDestination(label: 'Dashboard',     icon: Icons.dashboard_outlined,     selectedIcon: Icons.dashboard,         path: '/dashboard'),
  NavDestination(label: 'Users',         icon: Icons.people_outline,          selectedIcon: Icons.people,            path: '/users'),
  NavDestination(label: 'Plans',         icon: Icons.star_outline,            selectedIcon: Icons.star,              path: '/plans'),
  NavDestination(label: 'Subscriptions', icon: Icons.card_membership_outlined,selectedIcon: Icons.card_membership,   path: '/subscriptions'),
  NavDestination(label: 'Workouts',      icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center,    path: '/workouts'),
  NavDestination(label: 'Attendance',    icon: Icons.how_to_reg_outlined,     selectedIcon: Icons.how_to_reg,        path: '/attendance'),
  NavDestination(label: 'Messages',      icon: Icons.chat_bubble_outline,     selectedIcon: Icons.chat_bubble,       path: '/messages'),
  NavDestination(label: 'Analytics',     icon: Icons.bar_chart_outlined,      selectedIcon: Icons.bar_chart,         path: '/analytics'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Admin Shell — sidebar + topbar + content area
// ─────────────────────────────────────────────────────────────────────────────
class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < AppConstants.mobileBreakpoint;

    if (isMobile) {
      return _MobileScaffold(child: widget.child);
    }

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: _sidebarCollapsed
                ? AppConstants.sidebarCollapsed
                : AppConstants.sidebarWidth,
            child: AdminSidebar(
              collapsed: _sidebarCollapsed,
              onToggle: () =>
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
          ),
          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                AdminTopBar(collapsed: _sidebarCollapsed),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────
class AdminSidebar extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;

  const AdminSidebar({super.key, required this.collapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          // ── Logo ─────────────────────────────────────────────────────────
          Container(
            height: AppConstants.topbarHeight,
            padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 16 : 20),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: Colors.white, size: 20),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FalconGym',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                      Text('Admin Panel',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(
                    collapsed ? Icons.menu_open : Icons.menu,
                    size: 18,
                  ),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // ── Nav Items ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: kDestinations.length,
              itemBuilder: (_, i) {
                final dest = kDestinations[i];
                final isSelected = currentPath.startsWith(dest.path);
                return _SidebarItem(
                  dest: dest,
                  isSelected: isSelected,
                  collapsed: collapsed,
                  onTap: () => context.go(dest.path),
                );
              },
            ),
          ),
          // ── Bottom ────────────────────────────────────────────────────────
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _SidebarItem(
              dest: const NavDestination(
                  label: 'Logout',
                  icon: Icons.logout,
                  selectedIcon: Icons.logout,
                  path: ''),
              isSelected: false,
              collapsed: collapsed,
              color: AppColors.danger,
              onTap: () => context.read<AuthCubit>().logout(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavDestination dest;
  final bool isSelected;
  final bool collapsed;
  final Color? color;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.dest,
    required this.isSelected,
    required this.collapsed,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isSelected ? AppColors.primary : Colors.grey);

    final tile = Material(
      color: isSelected
          ? AppColors.primary.withOpacity(0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 10 : 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isSelected ? dest.selectedIcon : dest.icon,
                color: c,
                size: 20,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dest.label,
                    style: TextStyle(
                      color: c,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(message: dest.label, child: tile);
    }
    return Padding(
        padding: const EdgeInsets.only(bottom: 2), child: tile);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────
class AdminTopBar extends StatelessWidget {
  final bool collapsed;

  const AdminTopBar({super.key, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;

    // Find current page title
    final dest = kDestinations
        .where((d) => currentPath.startsWith(d.path))
        .firstOrNull;
    final title = dest?.label ?? 'Dashboard';

    return Container(
      height: AppConstants.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          // Theme toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (ctx, mode) => IconButton(
              icon: Icon(mode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              tooltip: 'Toggle Theme',
              onPressed: () => ctx.read<ThemeCubit>().toggle(),
            ),
          ),
          const SizedBox(width: 8),
          // Admin info
          BlocBuilder<AuthCubit, AuthState>(
            builder: (ctx, state) {
              final name = state is AuthAuthenticated
                  ? state.user.username
                  : 'Admin';
              return PopupMenuButton<String>(
                tooltip: '',
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.18),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ]),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'logout',
                      child: Row(children: [
                        Icon(Icons.logout, size: 16, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text('Logout',
                            style: TextStyle(color: AppColors.danger)),
                      ])),
                ],
                onSelected: (v) {
                  if (v == 'logout') ctx.read<AuthCubit>().logout();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile scaffold with bottom nav / drawer
// ─────────────────────────────────────────────────────────────────────────────
class _MobileScaffold extends StatelessWidget {
  final Widget child;
  const _MobileScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.fitness_center, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          const Text('FalconGym Admin',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
        ]),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (ctx, mode) => IconButton(
              icon: Icon(mode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              onPressed: () => ctx.read<ThemeCubit>().toggle(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.fitness_center,
                        color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    const Text('FalconGym Admin',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    BlocBuilder<AuthCubit, AuthState>(builder: (_, s) {
                      final name =
                          s is AuthAuthenticated ? s.user.username : '';
                      return Text(name,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13));
                    }),
                  ]),
            ),
            ...kDestinations.map((d) => ListTile(
                  leading: Icon(
                    currentPath.startsWith(d.path) ? d.selectedIcon : d.icon,
                    color: currentPath.startsWith(d.path)
                        ? AppColors.primary
                        : null,
                  ),
                  title: Text(d.label),
                  selected: currentPath.startsWith(d.path),
                  selectedColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(d.path);
                  },
                )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Logout',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme cubit  (shared location for layout to use)
// ─────────────────────────────────────────────────────────────────────────────
class ThemeCubit extends Cubit<ThemeMode> {
  final dynamic _storage; // TokenStorage

  ThemeCubit(this._storage) : super(ThemeMode.dark) {
    final saved = _storage.savedTheme as bool?;
    if (saved != null) emit(saved ? ThemeMode.dark : ThemeMode.light);
  }

  void toggle() {
    final isDark = state == ThemeMode.dark;
    _storage.saveTheme(!isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
