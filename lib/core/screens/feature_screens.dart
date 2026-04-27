import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_admin/core/data/feature_data_layers.dart';
import 'package:gym_admin/core/entities/shared_entities.dart';
import 'package:gym_admin/core/theme/app_theme.dart';
import 'package:gym_admin/core/widgets/app_widgets.dart';
import 'package:intl/intl.dart';



// ═══════════════════════════════════════════════════════════════════════════════
// ANALYTICS / DASHBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}
class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override void initState() { super.initState(); context.read<AnalyticsCubit>().load(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(title: 'Analytics Dashboard', subtitle: 'Overview of gym performance'),
            const SizedBox(height: 20),
            if (state is AnalyticsLoading) const AdminLoadingWidget()
            else if (state is AnalyticsError) AdminErrorWidget(message: state.msg, onRetry: () => context.read<AnalyticsCubit>().load())
            else if (state is AnalyticsLoaded) ...[
              // KPI Grid
              ResponsiveGrid(children: [
                KpiCard(title: 'Active Members', value: '${state.dashboard.activeMembers}', icon: Icons.people_outline, color: AppColors.primary, change: 5.2),
                KpiCard(title: 'Monthly Revenue', value: '\$${state.dashboard.revenue.toStringAsFixed(0)}', icon: Icons.attach_money, color: AppColors.purple, change: 12.1),
                KpiCard(title: 'Attendance Today', value: '${state.dashboard.attendanceCount}', icon: Icons.how_to_reg_outlined, color: AppColors.accent, change: -2.4),
                KpiCard(title: 'Total Members', value: '${state.dashboard.totalMembers > 0 ? state.dashboard.totalMembers : state.dashboard.activeMembers}', icon: Icons.groups_outlined, color: AppColors.cyan),
              ]),
              const SizedBox(height: 24),
              // Charts row
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (state.dashboard.attendanceByDay.isNotEmpty) Expanded(flex: 3, child: _AttendanceChart(data: state.dashboard.attendanceByDay)),
                if (state.dashboard.attendanceByDay.isNotEmpty) const SizedBox(width: 16),
                Expanded(flex: 2, child: _SummaryCard(dashboard: state.dashboard)),
              ]),
              if (state.trainerStats.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(title: 'Trainer Statistics'),
                const SizedBox(height: 12),
                _TrainerStatsTable(stats: state.trainerStats),
              ],
            ],
          ]),
        );
      },
    );
  }
}

class _AttendanceChart extends StatelessWidget {
  final Map<String, int> data;
  const _AttendanceChart({required this.data});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = data.entries.toList();
    final maxY = entries.isEmpty ? 10.0 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    return ContentCard(
      title: 'Attendance This Week',
      child: SizedBox(
        height: 220,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + 2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= entries.length) return const SizedBox.shrink();
              final key = entries[i].key;
              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(key.length > 3 ? key.substring(0, 3) : key, style: const TextStyle(fontSize: 10, color: Colors.grey)));
            })),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(entries.length, (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: entries[i].value.toDouble(), color: AppColors.primary, width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY + 2, color: isDark ? AppColors.darkBorder : Colors.grey.shade100)),
          ])),
        )),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DashboardEntity dashboard;
  const _SummaryCard({required this.dashboard});
  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: 'Quick Stats',
      child: Column(children: [
        _row(context, 'New Members (Month)', '${dashboard.newMembersThisMonth}', Icons.person_add_outlined, AppColors.info),
        const Divider(height: 20),
        _row(context, 'Active Members', '${dashboard.activeMembers}', Icons.people_outline, AppColors.primary),
        const Divider(height: 20),
        _row(context, 'Total Attendance', '${dashboard.attendanceCount}', Icons.how_to_reg_outlined, AppColors.accent),
        const Divider(height: 20),
        _row(context, 'Revenue', '\$${dashboard.revenue.toStringAsFixed(2)}', Icons.monetization_on_outlined, AppColors.purple),
      ]),
    );
  }

  Widget _row(BuildContext ctx, String label, String value, IconData icon, Color color) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    ]);
  }
}

class _TrainerStatsTable extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const _TrainerStatsTable({required this.stats});
  @override
  Widget build(BuildContext context) {
    return ContentCard(
      padding: EdgeInsets.zero,
      child: AdminDataTable(
        columns: const [
          DataColumn(label: Text('Trainer')),
          DataColumn(label: Text('Assigned Members')),
          DataColumn(label: Text('Workouts Created')),
        ],
        rows: stats.map((s) => DataRow(cells: [
          DataCell(Row(children: [
            UserAvatar(name: s['trainer_name'] as String? ?? ''),
            const SizedBox(width: 8),
            Text(s['trainer_name'] as String? ?? '—', style: const TextStyle(fontWeight: FontWeight.w500)),
          ])),
          DataCell(Text('${s['assigned_members'] ?? 0}')),
          DataCell(Text('${s['workouts_created'] ?? 0}')),
        ])).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTIONS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}
class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override void initState() { super.initState(); context.read<SubscriptionsCubit>().load(); }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
      listener: (ctx, s) {
        if (s is SubsActionSuccess) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.msg), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
        if (s is SubsError) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.msg), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating));
      },
      builder: (context, state) {
        final subs = state is SubsLoaded ? state.subs : <SubscriptionEntity>[];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              title: 'Subscriptions',
              subtitle: '${subs.length} total subscriptions',
              actions: [AddButton(label: 'Assign Plan', onPressed: () => _showDialog())],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ContentCard(
                padding: EdgeInsets.zero,
                child: state is SubsLoading
                    ? const AdminLoadingWidget()
                    : AdminDataTable(
                        emptyMessage: 'No subscriptions found',
                        minWidth: 900,
                        columns: const [
                          DataColumn(label: Text('Member')),
                          DataColumn(label: Text('Plan')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('Expiry')),
                          DataColumn(label: Text('Remaining')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: subs.map((s) {
                          final fmt = DateFormat('MMM d, yyyy');
                          return DataRow(cells: [
                            DataCell(Row(children: [UserAvatar(name: s.username), const SizedBox(width: 8), Text(s.username, style: const TextStyle(fontWeight: FontWeight.w500))])),
                            DataCell(Text(s.planName, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
                            DataCell(Text(fmt.format(s.startDate), style: const TextStyle(fontSize: 12))),
                            DataCell(Text(fmt.format(s.expiryDate), style: const TextStyle(fontSize: 12))),
                            DataCell(StatusBadge(label: '${s.remainingDays}d left', color: s.remainingDays > 7 ? AppColors.success : AppColors.warning)),
                            DataCell(StatusBadge(label: s.isActive ? 'Active' : 'Expired', color: s.isActive ? AppColors.success : AppColors.danger)),
                            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                              TableActionButton(icon: Icons.edit_outlined, color: AppColors.info, tooltip: 'Edit', onTap: () => _showDialog(sub: s)),
                              const SizedBox(width: 8),
                              TableActionButton(icon: Icons.delete_outline, color: AppColors.danger, tooltip: 'Delete',
                                onTap: () => DeleteConfirmDialog.show(context, itemName: '${s.username} — ${s.planName}',
                                    onConfirm: () => context.read<SubscriptionsCubit>().delete(s.id))),
                            ])),
                          ]);
                        }).toList(),
                      ),
              ),
            ),
          ]),
        );
      },
    );
  }

  void _showDialog({SubscriptionEntity? sub}) {
    showDialog(context: context, builder: (_) => BlocProvider.value(
      value: context.read<SubscriptionsCubit>(),
      child: _SubDialog(sub: sub),
    ));
  }
}

class _SubDialog extends StatefulWidget {
  final SubscriptionEntity? sub;
  const _SubDialog({this.sub});
  @override State<_SubDialog> createState() => _SubDialogState();
}
class _SubDialogState extends State<_SubDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  bool _isActive = true;
  bool get isEdit => widget.sub != null;

  @override void initState() {
    super.initState();
    if (isEdit) {
      final fmt = DateFormat('yyyy-MM-dd');
      _userCtrl.text = widget.sub!.userId.toString();
      _planCtrl.text = widget.sub!.planId.toString();
      _startCtrl.text = fmt.format(widget.sub!.startDate);
      _expiryCtrl.text = fmt.format(widget.sub!.expiryDate);
      _isActive = widget.sub!.isActive;
    } else {
      _startCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _expiryCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30)));
    }
  }
  @override void dispose() { for (final c in [_userCtrl, _planCtrl, _startCtrl, _expiryCtrl]) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Subscription' : 'Assign Plan'),
      content: SizedBox(width: 400, child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'User ID'), keyboardType: TextInputType.number,
          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _planCtrl, decoration: const InputDecoration(labelText: 'Plan ID'), keyboardType: TextInputType.number,
          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _startCtrl, decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
        const SizedBox(height: 4),
        SwitchListTile(title: const Text('Active'), value: _isActive, activeColor: AppColors.primary, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => _isActive = v)),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
          listener: (_, s) { if (s is SubsActionSuccess) Navigator.pop(context); },
          builder: (ctx, s) => ElevatedButton(
            onPressed: s is SubsLoading ? null : () {
              if (!_formKey.currentState!.validate()) return;
              final data = {'user': int.parse(_userCtrl.text), 'plan': int.parse(_planCtrl.text), 'start_date': _startCtrl.text, 'expiry_date': _expiryCtrl.text, 'is_active': _isActive};
              isEdit ? ctx.read<SubscriptionsCubit>().update(widget.sub!.id, data) : ctx.read<SubscriptionsCubit>().create(data);
            },
            child: Text(isEdit ? 'Save' : 'Assign'),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WORKOUTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  @override State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}
class _WorkoutsScreenState extends State<WorkoutsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); context.read<WorkoutsCubit>().load(); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutsCubit, WorkoutsState>(
      listener: (ctx, s) {
        if (s is WorkoutActionSuccess) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.msg), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
        if (s is WorkoutsError) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.msg), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating));
      },
      builder: (ctx, state) {
        final plans       = state is WorkoutsLoaded ? state.plans : <WorkoutPlanEntity>[];
        final assignments  = state is WorkoutsLoaded ? state.assignments : <AssignmentEntity>[];
        final exercises    = state is WorkoutsLoaded ? state.exercises : <ExerciseEntity>[];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(title: 'Workouts', subtitle: '${plans.length} plans · ${assignments.length} assignments',
              actions: [AddButton(label: 'New Plan', onPressed: () => _showPlanDialog())]),
            const SizedBox(height: 16),
            TabBar(controller: _tabs, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [Tab(text: 'Workout Plans'), Tab(text: 'Exercises'), Tab(text: 'Assignments')]),
            const SizedBox(height: 16),
            Expanded(child: TabBarView(controller: _tabs, children: [
              // Plans tab
              ContentCard(padding: EdgeInsets.zero, child: AdminDataTable(
                emptyMessage: 'No workout plans', columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Difficulty')), DataColumn(label: Text('Actions'))],
                rows: plans.map((p) => DataRow(cells: [
                  DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(StatusBadge(label: p.difficulty, color: p.difficulty == 'beginner' ? AppColors.success : p.difficulty == 'advanced' ? AppColors.danger : AppColors.warning)),
                  DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                    TableActionButton(icon: Icons.fitness_center, color: AppColors.info, tooltip: 'View Exercises', onTap: () { ctx.read<WorkoutsCubit>().loadExercises(p.id); _tabs.animateTo(1); }),
                    const SizedBox(width: 8),
                    TableActionButton(icon: Icons.delete_outline, color: AppColors.danger, tooltip: 'Delete',
                      onTap: () => DeleteConfirmDialog.show(context, itemName: p.name, onConfirm: () => ctx.read<WorkoutsCubit>().deletePlan(p.id))),
                  ])),
                ])).toList(),
              )),
              // Exercises tab
              ContentCard(padding: EdgeInsets.zero, child: AdminDataTable(
                emptyMessage: 'Select a plan to view exercises', columns: const [DataColumn(label: Text('Exercise')), DataColumn(label: Text('Sets')), DataColumn(label: Text('Reps')), DataColumn(label: Text('Rest'))],
                rows: exercises.map((e) => DataRow(cells: [
                  DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text('${e.sets}')),
                  DataCell(Text('${e.reps}')),
                  DataCell(Text('${e.restSeconds}s')),
                ])).toList(),
              )),
              // Assignments tab
              ContentCard(padding: EdgeInsets.zero, child: AdminDataTable(
                emptyMessage: 'No assignments yet', columns: const [DataColumn(label: Text('Member')), DataColumn(label: Text('Plan')), DataColumn(label: Text('Date'))],
                rows: assignments.map((a) => DataRow(cells: [
                  DataCell(Row(children: [UserAvatar(name: a.username), const SizedBox(width: 8), Text(a.username)])),
                  DataCell(Text(a.plan.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(DateFormat('MMM d, yyyy').format(a.assignedDate), style: const TextStyle(fontSize: 12))),
                ])).toList(),
              )),
            ])),
          ]),
        );
      },
    );
  }

  void _showPlanDialog() {
    final nameCtrl = TextEditingController();
    final diffCtrl = ValueNotifier('intermediate');
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Create Workout Plan'),
      content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Plan Name')),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(valueListenable: diffCtrl, builder: (_, val, __) => DropdownButtonFormField<String>(
          value: val,
          decoration: const InputDecoration(labelText: 'Difficulty'),
          items: ['beginner', 'intermediate', 'advanced'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (v) => diffCtrl.value = v ?? val,
        )),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (nameCtrl.text.trim().isEmpty) return;
          context.read<WorkoutsCubit>().createPlan({'name': nameCtrl.text.trim(), 'difficulty': diffCtrl.value});
          Navigator.pop(context);
        }, child: const Text('Create')),
      ],
    ));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MESSAGING SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});
  @override State<MessagingScreen> createState() => _MessagingScreenState();
}
class _MessagingScreenState extends State<MessagingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); context.read<MessagingCubit>().load(); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingCubit, MessagingState>(
      builder: (ctx, state) {
        final inbox = state is MessagingLoaded ? state.inbox : <MessageEntity>[];
        final sent  = state is MessagingLoaded ? state.sent  : <MessageEntity>[];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(title: 'Messages', subtitle: '${inbox.length} in inbox',
              actions: [AddButton(label: 'Send Message', icon: Icons.send, onPressed: () => _showComposeDialog(ctx))]),
            const SizedBox(height: 16),
            TabBar(controller: _tabs, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [Tab(text: 'Inbox'), Tab(text: 'Sent')]),
            const SizedBox(height: 16),
            Expanded(child: TabBarView(controller: _tabs, children: [
              _messageList(inbox),
              _messageList(sent),
            ])),
          ]),
        );
      },
    );
  }

  Widget _messageList(List<MessageEntity> msgs) {
    if (msgs.isEmpty) return const AdminEmptyWidget(message: 'No messages', icon: Icons.chat_bubble_outline);
    return ContentCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: msgs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = msgs[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: UserAvatar(name: m.senderName),
            title: Row(children: [
              Text(m.senderName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (m.isBroadcast) ...[const SizedBox(width: 8), const StatusBadge(label: 'Broadcast', color: AppColors.purple)],
              const Spacer(),
              Text(DateFormat('MMM d, HH:mm').format(m.sentAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
            subtitle: Text(m.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          );
        },
      ),
    );
  }

  void _showComposeDialog(BuildContext ctx) {
    final contentCtrl = TextEditingController();
    final receiverCtrl = TextEditingController();
    var isBroadcast = false;
    showDialog(context: ctx, builder: (_) => StatefulBuilder(builder: (ctx2, setS) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Send Message'),
      content: SizedBox(width: 440, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile(title: const Text('Broadcast to all'), value: isBroadcast, activeColor: AppColors.primary, contentPadding: EdgeInsets.zero,
          onChanged: (v) => setS(() => isBroadcast = v)),
        if (!isBroadcast) ...[const SizedBox(height: 8), TextFormField(controller: receiverCtrl, decoration: const InputDecoration(labelText: 'Receiver User ID'), keyboardType: TextInputType.number)],
        const SizedBox(height: 12),
        TextFormField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 4),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
        ElevatedButton.icon(icon: const Icon(Icons.send, size: 16), label: const Text('Send'),
          onPressed: () {
            if (contentCtrl.text.trim().isEmpty) return;
            context.read<MessagingCubit>().sendMessage(
              receiverId: isBroadcast ? null : int.tryParse(receiverCtrl.text),
              content: contentCtrl.text.trim(), broadcast: isBroadcast);
            Navigator.pop(ctx2);
          }),
      ],
    )));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ATTENDANCE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override State<AttendanceScreen> createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreen> {
  final _dateCtrl = TextEditingController();
  @override void initState() { super.initState(); context.read<AttendanceCubit>().load(); }
  @override void dispose() { _dateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (ctx, state) {
        final records = state is AttendanceLoaded ? state.records : <AttendanceEntity>[];
        final active = records.where((r) => r.isActive).length;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(title: 'Attendance', subtitle: '$active active sessions · ${records.length} total records'),
            const SizedBox(height: 20),
            // Filters
            Row(children: [
              SizedBox(width: 200, child: TextFormField(controller: _dateCtrl, decoration: const InputDecoration(labelText: 'Filter by date (YYYY-MM-DD)', isDense: true, prefixIcon: Icon(Icons.date_range, size: 18)))),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: () => ctx.read<AttendanceCubit>().load(date: _dateCtrl.text.trim().isNotEmpty ? _dateCtrl.text.trim() : null), child: const Text('Filter')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () { _dateCtrl.clear(); ctx.read<AttendanceCubit>().load(); }, child: const Text('Clear')),
            ]),
            const SizedBox(height: 16),
            Expanded(child: ContentCard(
              padding: EdgeInsets.zero,
              child: state is AttendanceLoading
                  ? const AdminLoadingWidget()
                  : AdminDataTable(
                      emptyMessage: 'No attendance records',
                      minWidth: 750,
                      columns: const [DataColumn(label: Text('Member')), DataColumn(label: Text('Check In')), DataColumn(label: Text('Check Out')), DataColumn(label: Text('Duration')), DataColumn(label: Text('Status'))],
                      rows: records.map((r) {
                        final fmt = DateFormat('MMM d, HH:mm');
                        final dur = r.duration;
                        final durStr = dur != null ? '${dur.inHours}h ${dur.inMinutes.remainder(60)}m' : '—';
                        return DataRow(cells: [
                          DataCell(Row(children: [UserAvatar(name: r.username), const SizedBox(width: 8), Text(r.username, style: const TextStyle(fontWeight: FontWeight.w500))])),
                          DataCell(Text(fmt.format(r.checkIn), style: const TextStyle(fontSize: 12))),
                          DataCell(Text(r.checkOut != null ? fmt.format(r.checkOut!) : '—', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(durStr, style: const TextStyle(fontSize: 12))),
                          DataCell(StatusBadge(label: r.isActive ? 'Active' : 'Done', color: r.isActive ? AppColors.success : Colors.grey)),
                        ]);
                      }).toList(),
                    ),
            )),
          ]),
        );
      },
    );
  }
}
