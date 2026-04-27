import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_admin/features/plans/domain/entities/plan_entity.dart';
import 'package:gym_admin/features/plans/domain/usecases/plans_usecases.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

// ── States ────────────────────────────────────────────────────────────────────
abstract class PlansState extends Equatable {
  const PlansState();
  @override
  List<Object?> get props => [];
}

class PlansInitial extends PlansState {}

class PlansLoading extends PlansState {}

class PlansLoaded extends PlansState {
  final List<PlanEntity> plans;
  const PlansLoaded(this.plans);
  @override
  List<Object> get props => [plans];
}

class PlansError extends PlansState {
  final String message;
  const PlansError(this.message);
  @override
  List<Object> get props => [message];
}

class PlanActionSuccess extends PlansState {
  final String message;
  const PlanActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class PlansCubit extends Cubit<PlansState> {
  final GetPlansUseCase _get;
  final CreatePlanUseCase _create;
  final UpdatePlanUseCase _update;
  final DeletePlanUseCase _delete;

  PlansCubit(this._get, this._create, this._update, this._delete)
      : super(PlansInitial());

  Future<void> load() async {
    emit(PlansLoading());
    (await _get())
        .fold((f) => emit(PlansError(f.message)), (p) => emit(PlansLoaded(p)));
  }

  Future<void> create(Map<String, dynamic> data) async {
    (await _create(data)).fold((f) => emit(PlansError(f.message)), (_) {
      emit(const PlanActionSuccess('Plan created'));
      load();
    });
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    (await _update(id, data)).fold((f) => emit(PlansError(f.message)), (_) {
      emit(const PlanActionSuccess('Plan updated'));
      load();
    });
  }

  Future<void> delete(int id) async {
    (await _delete(id)).fold((f) => emit(PlansError(f.message)), (_) {
      emit(const PlanActionSuccess('Plan deleted'));
      load();
    });
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlansCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlansCubit, PlansState>(
      listener: (context, state) {
        if (state is PlanActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating));
        }
        if (state is PlansError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating));
        }
      },
      builder: (context, state) {
        final plans = state is PlansLoaded ? state.plans : <PlanEntity>[];
        return Padding(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              title: 'Plans Management',
              subtitle: '${plans.length} plans available',
              actions: [
                AddButton(label: 'New Plan', onPressed: () => _showDialog())
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: state is PlansLoading
                  ? const AdminLoadingWidget()
                  : ContentCard(
                      padding: EdgeInsets.zero,
                      child: AdminDataTable(
                        emptyMessage: 'No plans yet. Create your first plan.',
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Duration')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: plans
                            .map((p) => DataRow(cells: [
                                  DataCell(Text(p.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600))),
                                  DataCell(SizedBox(
                                      width: 240,
                                      child: Text(p.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis))),
                                  DataCell(Text('${p.durationDays} days')),
                                  DataCell(Text(
                                      '\$${p.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary))),
                                  DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TableActionButton(
                                            icon: Icons.edit_outlined,
                                            color: AppColors.info,
                                            tooltip: 'Edit',
                                            onTap: () => _showDialog(plan: p)),
                                        const SizedBox(width: 8),
                                        TableActionButton(
                                            icon: Icons.delete_outline,
                                            color: AppColors.danger,
                                            tooltip: 'Delete',
                                            onTap: () =>
                                                DeleteConfirmDialog.show(
                                                    context,
                                                    itemName: p.name,
                                                    onConfirm: () => context
                                                        .read<PlansCubit>()
                                                        .delete(p.id))),
                                      ])),
                                ]))
                            .toList(),
                      ),
                    ),
            ),
          ]),
        );
      },
    );
  }

  void _showDialog({PlanEntity? plan}) {
    showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
              value: context.read<PlansCubit>(),
              child: _PlanDialog(plan: plan),
            ));
  }
}

// ── Plan Dialog ───────────────────────────────────────────────────────────────
class _PlanDialog extends StatefulWidget {
  final PlanEntity? plan;
  const _PlanDialog({this.plan});
  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl,
      _descCtrl,
      _priceCtrl,
      _durationCtrl;
  bool get isEdit => widget.plan != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.plan?.name ?? '');
    _descCtrl = TextEditingController(text: widget.plan?.description ?? '');
    _priceCtrl =
        TextEditingController(text: widget.plan?.price.toString() ?? '');
    _durationCtrl = TextEditingController(
        text: widget.plan?.durationDays.toString() ?? '30');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _descCtrl, _priceCtrl, _durationCtrl])
      c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Plan' : 'Create New Plan'),
      content: SizedBox(
        width: 420,
        child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Plan Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Price (\$)', prefixText: '\$'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Required';
                          if (double.tryParse(v!) == null) return 'Invalid';
                          return null;
                        })),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _durationCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Duration (days)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Required';
                          if (int.tryParse(v!) == null) return 'Invalid';
                          return null;
                        })),
              ]),
            ])),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        BlocConsumer<PlansCubit, PlansState>(
          listener: (_, s) {
            if (s is PlanActionSuccess) Navigator.pop(context);
          },
          builder: (ctx, s) => ElevatedButton(
            onPressed: s is PlansLoading
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    final data = {
                      'name': _nameCtrl.text.trim(),
                      'description': _descCtrl.text.trim(),
                      'price': double.parse(_priceCtrl.text),
                      'duration_days': int.parse(_durationCtrl.text),
                    };
                    isEdit
                        ? ctx.read<PlansCubit>().update(widget.plan!.id, data)
                        : ctx.read<PlansCubit>().create(data);
                  },
            child: Text(isEdit ? 'Save Changes' : 'Create Plan'),
          ),
        ),
      ],
    );
  }
}
