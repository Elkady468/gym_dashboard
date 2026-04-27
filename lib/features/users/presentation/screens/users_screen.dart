import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/users_cubit.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UsersCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersCubit, UsersState>(
      listener: (context, state) {
        if (state is UserActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        }
        if (state is UsersError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'User Management',
                subtitle: state is UsersLoaded
                    ? '${state.users.length} members total'
                    : null,
              ),
              const SizedBox(height: 20),
              // ── Toolbar ──────────────────────────────────────────────────
              Row(children: [
                AdminSearchBar(
                  hintText: 'Search users...',
                  controller: _searchCtrl,
                  onChanged: (q) =>
                      context.read<UsersCubit>().loadUsers(search: q),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () => context
                      .read<UsersCubit>()
                      .loadUsers(search: _searchCtrl.text),
                ),
              ]),
              const SizedBox(height: 16),
              // ── Table ────────────────────────────────────────────────────
              SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: ContentCard(
                  padding: EdgeInsets.zero,
                  child: _buildTable(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(UsersState state) {
    if (state is UsersLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: AdminLoadingWidget(),
      );
    }

    final users = state is UsersLoaded ? state.users : <UserEntity>[];

    return AdminDataTable(
      isLoading: state is UsersLoading,
      emptyMessage: 'No users found',
      minWidth: 800,
      columns: const [
        DataColumn2(label: Text('User'), size: ColumnSize.L),
        DataColumn2(label: Text('Email')),
        DataColumn2(label: Text('Role')),
        DataColumn2(label: Text('Status')),
        DataColumn2(label: Text('Joined')),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows: users.map((u) => _buildRow(u)).toList(),
    );
  }

  DataRow _buildRow(UserEntity u) {
    final joined = u.dateJoined != null
        ? DateFormat('MMM d, yyyy').format(u.dateJoined!)
        : '—';
    return DataRow(cells: [
      DataCell(Row(children: [
        UserAvatar(name: u.fullName.isNotEmpty ? u.fullName : u.username),
        const SizedBox(width: 10),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(u.fullName.isNotEmpty ? u.fullName : u.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Text('@${u.username}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
      ])),
      DataCell(Text(u.email, style: const TextStyle(fontSize: 13))),
      DataCell(StatusBadge(
        label: u.role.toUpperCase(),
        color: u.role == 'admin'
            ? AppColors.purple
            : u.role == 'trainer'
                ? AppColors.info
                : AppColors.primary,
      )),
      DataCell(StatusBadge(
        label: u.isActive ? 'Active' : 'Inactive',
        color: u.isActive ? AppColors.success : AppColors.danger,
      )),
      DataCell(Text(joined,
          style: const TextStyle(fontSize: 12, color: Colors.grey))),
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        TableActionButton(
          icon: Icons.edit_outlined,
          color: AppColors.info,
          tooltip: 'Edit',
          onTap: () => _showEditDialog(u),
        ),
        const SizedBox(width: 8),
        TableActionButton(
          icon: Icons.delete_outline,
          color: AppColors.danger,
          tooltip: 'Delete',
          onTap: () => DeleteConfirmDialog.show(
            context,
            itemName: u.username,
            onConfirm: () => context.read<UsersCubit>().deleteUser(u.id),
          ),
        ),
      ])),
    ]);
  }

  void _showEditDialog(UserEntity user) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<UsersCubit>(),
        child: _EditUserDialog(user: user),
      ),
    );
  }
}

// ── Edit User Dialog ──────────────────────────────────────────────────────────
class _EditUserDialog extends StatefulWidget {
  final UserEntity user;
  const _EditUserDialog({required this.user});
  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstCtrl,
      _lastCtrl,
      _emailCtrl,
      _phoneCtrl;
  late String _role;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.user.firstName);
    _lastCtrl = TextEditingController(text: widget.user.lastName);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _role = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _phoneCtrl])
      c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        UserAvatar(name: widget.user.fullName, radius: 18),
        const SizedBox(width: 10),
        Text('Edit ${widget.user.username}'),
      ]),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: _field(_firstCtrl, 'First Name')),
              const SizedBox(width: 12),
              Expanded(child: _field(_lastCtrl, 'Last Name')),
            ]),
            const SizedBox(height: 12),
            _field(_emailCtrl, 'Email',
                type: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Invalid email'),
            const SizedBox(height: 12),
            _field(_phoneCtrl, 'Phone',
                type: TextInputType.phone, required: false),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: ['member', 'trainer', 'admin']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Active Account'),
              value: _isActive,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        BlocConsumer<UsersCubit, UsersState>(
          listener: (_, state) {
            if (state is UserActionSuccess) Navigator.pop(context);
          },
          builder: (ctx, state) => ElevatedButton(
            onPressed: state is UsersLoading
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    ctx.read<UsersCubit>().updateUser(widget.user.id, {
                      'first_name': _firstCtrl.text.trim(),
                      'last_name': _lastCtrl.text.trim(),
                      'email': _emailCtrl.text.trim(),
                      if (_phoneCtrl.text.trim().isNotEmpty)
                        'phone': _phoneCtrl.text.trim(),
                      'role': _role,
                      'is_active': _isActive,
                    });
                  },
            child: state is UsersLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
    bool required = true,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(labelText: label),
        validator: validator ??
            (required ? (v) => (v?.isEmpty ?? true) ? 'Required' : null : null),
      );
}
