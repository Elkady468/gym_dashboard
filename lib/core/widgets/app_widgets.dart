import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KPI / Stat Card
// ─────────────────────────────────────────────────────────────────────────────
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double? change;          // positive = up, negative = down

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.change,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                if (change != null)
                  _ChangeChip(change: change!),
              ],
            ),
            const SizedBox(height: 16),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: color)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  final double change;
  const _ChangeChip({required this.change});
  @override
  Widget build(BuildContext context) {
    final isUp = change >= 0;
    final color = isUp ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: color),
        const SizedBox(width: 2),
        Text('${change.abs().toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const SectionHeader({super.key, required this.title, this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (subtitle != null)
                Text(subtitle!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Data Table wrapper
// ─────────────────────────────────────────────────────────────────────────────
class AdminDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isLoading;
  final String? emptyMessage;
  final double minWidth;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage,
    this.minWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return _ShimmerTable(isDark: isDark);
    }

    if (rows.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(emptyMessage ?? 'No data found',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: minWidth,
      headingRowHeight: 48,
      dataRowHeight: 56,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      columns: columns,
      rows: rows,
    );
  }
}

class _ShimmerTable extends StatelessWidget {
  final bool isDark;
  const _ShimmerTable({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : Colors.grey.shade200,
      highlightColor: isDark ? AppColors.darkBorder : Colors.grey.shade100,
      child: Column(
        children: List.generate(
          6,
          (_) => Container(
            height: 52,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class AdminSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const AdminSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 18),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────────────────────────────────────
class TableActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const TableActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm Delete Dialog
// ─────────────────────────────────────────────────────────────────────────────
class DeleteConfirmDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.itemName,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String itemName,
    required VoidCallback onConfirm,
  }) =>
      showDialog(
        context: context,
        builder: (_) => DeleteConfirmDialog(itemName: itemName, onConfirm: onConfirm),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
        const SizedBox(width: 8),
        const Text('Delete Confirmation'),
      ]),
      content: Text('Are you sure you want to delete "$itemName"?\nThis action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error / Loading / Empty states
// ─────────────────────────────────────────────────────────────────────────────
class AdminLoadingWidget extends StatelessWidget {
  const AdminLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppColors.primary));
}

class AdminErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AdminErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.danger),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ]),
    );
  }
}

class AdminEmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  const AdminEmptyWidget({super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 52, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar initials widget
// ─────────────────────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String? name;
  final double radius;

  const UserAvatar({super.key, this.name, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name ?? '?');
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.18),
      child: Text(initials,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.55,
          )),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (n.isNotEmpty) return n[0].toUpperCase();
    return '?';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card container with title
// ─────────────────────────────────────────────────────────────────────────────
class ContentCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? headerActions;
  final EdgeInsets padding;

  const ContentCard({
    super.key,
    this.title,
    required this.child,
    this.headerActions,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Text(title!,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (headerActions != null) ...headerActions!,
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary Add button
// ─────────────────────────────────────────────────────────────────────────────
class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const AddButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive grid layout
// ─────────────────────────────────────────────────────────────────────────────
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns = 4,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    int cols = columns;
    if (w < 900) cols = 2;
    if (w < 600) cols = 1;

    return LayoutBuilder(
      builder: (_, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
