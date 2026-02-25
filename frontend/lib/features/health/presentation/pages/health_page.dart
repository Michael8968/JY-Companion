import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../../domain/entities/exercise_plan.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/screen_time_record.dart';
import '../bloc/health_bloc.dart';
import '../bloc/health_event.dart';
import '../bloc/health_state.dart';

/// 健康守护页面：屏幕时间统计、运动计划、提醒配置。
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HealthBloc>()..add(const HealthLoadEvent()),
      child: const _HealthView(),
    );
  }
}

class _HealthView extends StatelessWidget {
  const _HealthView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('健康守护'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.screen_search_desktop), text: '屏幕时间'),
              Tab(icon: Icon(Icons.fitness_center), text: '运动计划'),
              Tab(icon: Icon(Icons.notifications_active), text: '提醒配置'),
            ],
          ),
        ),
        body: BlocConsumer<HealthBloc, HealthState>(
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
            if (state.isLoading &&
                state.screenTimeHistory.isEmpty &&
                state.reminderConfig == null) {
              return const JYLoading(message: '加载中…');
            }
            if (state.errorMessage != null &&
                state.screenTimeHistory.isEmpty &&
                state.reminderConfig == null) {
              return JYErrorWidget(
                message: state.errorMessage!,
                onRetry: () =>
                    context.read<HealthBloc>().add(const HealthLoadEvent()),
              );
            }
            return TabBarView(
              children: [
                _ScreenTimeTab(records: state.screenTimeHistory),
                _ExercisePlanTab(
                  plan: state.exercisePlan,
                  isLoading: state.isLoading,
                  onLoadPlan: (type) => context
                      .read<HealthBloc>()
                      .add(HealthLoadExercisePlanEvent(type)),
                  onComplete: (id) => context
                      .read<HealthBloc>()
                      .add(HealthCompleteExerciseEvent(id)),
                ),
                _ReminderConfigTab(
                  config: state.reminderConfig,
                  onUpdate: (body) => context
                      .read<HealthBloc>()
                      .add(HealthUpdateReminderEvent(body)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScreenTimeTab extends StatelessWidget {
  const _ScreenTimeTab({required this.records});

  final List<ScreenTimeRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return JYEmptyState(
        message: '暂无屏幕时间记录，客户端会定期上报',
        icon: Icons.screen_search_desktop,
      );
    }
    final todayTotal = _todayTotalMinutes(records);
    final weekTotal = _weekTotalMinutes(records);
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HealthBloc>().add(const HealthLoadEvent());
      },
      child: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日使用',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${todayTotal} 分钟',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.health,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '近 7 日合计',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${weekTotal} 分钟',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '最近记录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...records.take(15).map(
                  (r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${r.durationMinutes} 分钟'),
                      subtitle: Text(
                        '连续 ${r.continuousMinutes} 分钟 · ${_formatDate(r.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  int _todayTotalMinutes(List<ScreenTimeRecord> list) {
    final now = DateTime.now();
    return list
        .where((r) =>
            r.createdAt.year == now.year &&
            r.createdAt.month == now.month &&
            r.createdAt.day == now.day)
        .fold<int>(0, (sum, r) => sum + r.durationMinutes);
  }

  int _weekTotalMinutes(List<ScreenTimeRecord> list) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return list
        .where((r) => r.createdAt.isAfter(weekAgo))
        .fold<int>(0, (sum, r) => sum + r.durationMinutes);
  }

  String _formatDate(DateTime d) {
    return '${d.month}月${d.day}日 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _ExercisePlanTab extends StatelessWidget {
  const _ExercisePlanTab({
    required this.plan,
    required this.isLoading,
    required this.onLoadPlan,
    required this.onComplete,
  });

  final ExercisePlan? plan;
  final bool isLoading;
  final void Function(String) onLoadPlan;
  final void Function(String) onComplete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '选择类型',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PlanTypeChip(
                label: '拉伸',
                value: 'stretch',
                onTap: () => onLoadPlan('stretch'),
              ),
              const SizedBox(width: 8),
              _PlanTypeChip(
                label: '力量',
                value: 'strength',
                onTap: () => onLoadPlan('strength'),
              ),
              const SizedBox(width: 8),
              _PlanTypeChip(
                label: '协调',
                value: 'coordination',
                onTap: () => onLoadPlan('coordination'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading && plan == null)
            const Center(child: CircularProgressIndicator())
          else if (plan == null)
            JYEmptyState(
              message: '选择上方类型获取运动计划',
              icon: Icons.fitness_center,
            )
          else
            _PlanCard(
              plan: plan!,
              onComplete: () => onComplete(plan!.id),
            ),
        ],
      ),
    );
  }
}

class _PlanTypeChip extends StatelessWidget {
  const _PlanTypeChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      onSelected: (_) => onTap(),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onComplete});

  final ExercisePlan plan;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.planTypeDisplay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${plan.durationMinutes} 分钟',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (plan.exercises != null && plan.exercises!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...plan.exercises!.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${e.key}: ${e.value}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 16),
            if (!plan.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('完成'),
                ),
              )
            else
              Chip(
                label: const Text('已完成'),
                backgroundColor: AppColors.success.withValues(alpha: 0.2),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReminderConfigTab extends StatelessWidget {
  const _ReminderConfigTab({
    required this.config,
    required this.onUpdate,
  });

  final ReminderConfig? config;
  final void Function(Map<String, dynamic>) onUpdate;

  @override
  Widget build(BuildContext context) {
    if (config == null) {
      return JYEmptyState(
        message: '加载提醒配置中…',
        icon: Icons.notifications_active,
      );
    }
    final c = config!;
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '提醒间隔（分钟）',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c.reminderIntervalMinutes}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '强制休息（连续分钟）',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text('${c.forcedBreakMinutes}'),
                  const SizedBox(height: 8),
                  Text(
                    '休息时长（分钟）',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text('${c.breakDurationMinutes}'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('护眼休息'),
                    value: c.eyeRestEnabled,
                    onChanged: (v) => onUpdate({
                      ...c.toUpdateJson(),
                      'eye_rest_enabled': v,
                    }),
                  ),
                  SwitchListTile(
                    title: const Text('运动提醒'),
                    value: c.exerciseEnabled,
                    onChanged: (v) => onUpdate({
                      ...c.toUpdateJson(),
                      'exercise_enabled': v,
                    }),
                  ),
                  SwitchListTile(
                    title: const Text('坐姿提醒'),
                    value: c.postureEnabled,
                    onChanged: (v) => onUpdate({
                      ...c.toUpdateJson(),
                      'posture_enabled': v,
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '说明：提醒间隔达到后将推送休息提醒，强制休息时长内建议离开屏幕。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
