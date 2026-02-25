import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_button.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/progress_report.dart';
import '../bloc/career_bloc.dart';
import '../bloc/career_event.dart';
import '../bloc/career_state.dart';

/// 生涯规划页面：目标管理、甘特图、进度报告。
class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CareerBloc>()..add(const CareerLoadEvent()),
      child: const _CareerView(),
    );
  }
}

class _CareerView extends StatelessWidget {
  const _CareerView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('生涯规划'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flag), text: '目标管理'),
              Tab(icon: Icon(Icons.timeline), text: '甘特图'),
              Tab(icon: Icon(Icons.assessment), text: '进度报告'),
            ],
          ),
        ),
        body: BlocConsumer<CareerBloc, CareerState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              JYSnackbar.show(
                context,
                message: state.errorMessage!,
                type: SnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.goals.isEmpty) {
              return const JYLoading(message: '加载中…');
            }
            if (state.errorMessage != null && state.goals.isEmpty) {
              return JYErrorWidget(
                message: state.errorMessage!,
                onRetry: () =>
                    context.read<CareerBloc>().add(const CareerLoadEvent()),
              );
            }
            return TabBarView(
              children: [
                _GoalsTab(
                  goals: state.goals,
                  isLoading: state.isLoading,
                  onCreateGoal: () => _showCreateGoal(context),
                  onUpdateGoal: (id, progress, status) => context
                      .read<CareerBloc>()
                      .add(CareerUpdateGoalEvent(
                        goalId: id,
                        progressPercent: progress,
                        status: status,
                      )),
                ),
                _GanttTab(goals: state.goals),
                _ReportsTab(
                  reports: state.reports,
                  isLoading: state.isLoading,
                  onLoadReports: () => context
                      .read<CareerBloc>()
                      .add(const CareerLoadReportsEvent()),
                  onGenerateReport: (start, end) => context
                      .read<CareerBloc>()
                      .add(CareerGenerateReportEvent(
                        periodStart: start,
                        periodEnd: end,
                      )),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCreateGoal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '新建目标',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: 'SMART 目标标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.of(ctx).pop();
                context.read<CareerBloc>().add(CareerCreateGoalEvent(
                      title: title,
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                    ));
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab({
    required this.goals,
    required this.isLoading,
    required this.onCreateGoal,
    required this.onUpdateGoal,
  });

  final List<Goal> goals;
  final bool isLoading;
  final VoidCallback onCreateGoal;
  final void Function(String goalId, double? progressPercent, String? status)
      onUpdateGoal;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (goals.isEmpty)
          JYEmptyState(
            message: '暂无目标，点击右下角添加',
            icon: Icons.flag,
            actionLabel: '新建目标',
            action: onCreateGoal,
          )
        else
          RefreshIndicator(
            onRefresh: () async {
              context.read<CareerBloc>().add(const CareerLoadEvent());
            },
            child: ListView.separated(
              padding: AppSpacing.paddingMd,
              itemCount: goals.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _GoalCard(
                  goal: goal,
                  onUpdate: onUpdateGoal,
                );
              },
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: onCreateGoal,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onUpdate});

  final Goal goal;
  final void Function(String, double?, String?) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(goal.statusDisplay),
                  backgroundColor: _statusColor(goal.status),
                ),
                const SizedBox(width: 4),
                Text(
                  goal.priorityDisplay,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            if (goal.description != null && goal.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  goal.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progressPercent.clamp(0.0, 1.0) / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.career),
            ),
            const SizedBox(height: 4),
            Text(
              '${goal.progressPercent.toInt()}%'
              '${goal.deadline != null ? " · 截止 ${goal.deadline}" : ""}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (goal.status == 'active') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      final p = (goal.progressPercent + 25).clamp(0.0, 100.0);
                      onUpdate(goal.id, p, null);
                    },
                    child: const Text('+25%'),
                  ),
                  TextButton(
                    onPressed: () => onUpdate(goal.id, null, 'completed'),
                    child: const Text('完成'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success.withValues(alpha: 0.2);
      case 'paused':
        return AppColors.warning.withValues(alpha: 0.2);
      case 'abandoned':
        return AppColors.error.withValues(alpha: 0.2);
      default:
        return AppColors.career.withValues(alpha: 0.2);
    }
  }
}

class _GanttTab extends StatelessWidget {
  const _GanttTab({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return JYEmptyState(
        message: '暂无目标，在目标管理中添加后在此查看时间线',
        icon: Icons.timeline,
      );
    }
    final activeGoals =
        goals.where((g) => g.status == 'active' && g.deadline != null).toList();
    if (activeGoals.isEmpty) {
      return JYEmptyState(
        message: '暂无带截止日期的进行中目标',
        icon: Icons.timeline,
      );
    }
    return ListView.builder(
      padding: AppSpacing.paddingMd,
      itemCount: activeGoals.length,
      itemBuilder: (context, index) {
        final goal = activeGoals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: (goal.progressPercent / 100 * 10).round().clamp(1, 10),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.career,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10 -
                          (goal.progressPercent / 100 * 10).round().clamp(0, 9),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.progressPercent.toInt()}% · 截止 ${goal.deadline ?? "-"}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({
    required this.reports,
    required this.isLoading,
    required this.onLoadReports,
    required this.onGenerateReport,
  });

  final List<ProgressReport> reports;
  final bool isLoading;
  final VoidCallback onLoadReports;
  final void Function(String periodStart, String periodEnd) onGenerateReport;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JYButton(
            label: '生成本周报告',
            onPressed: isLoading ? null : () => _generateWeekReport(context),
            isLoading: isLoading,
            icon: Icons.assessment,
          ),
          const SizedBox(height: 16),
          Text(
            '历史报告',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (reports.isEmpty)
            JYEmptyState(
              message: '点击上方按钮生成进度报告',
              icon: Icons.assessment,
            )
          else
            ...reports.take(10).map(
                  (r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${r.periodStart} ~ ${r.periodEnd}'),
                      subtitle: r.content != null && r.content!.isNotEmpty
                          ? Text(
                              r.content!.length > 80
                                  ? '${r.content!.substring(0, 80)}…'
                                  : r.content!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () => _showReportDetail(context, r),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _generateWeekReport(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    onGenerateReport(
      _formatDate(start),
      _formatDate(end),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _showReportDetail(BuildContext context, ProgressReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${report.periodStart} ~ ${report.periodEnd}',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (report.content != null && report.content!.isNotEmpty)
                SelectableText(report.content!),
            ],
          ),
        ),
      ),
    );
  }
}
