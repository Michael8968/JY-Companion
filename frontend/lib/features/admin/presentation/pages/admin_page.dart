import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../../domain/entities/crisis_alert_summary.dart';
import '../../domain/entities/platform_stats.dart';
import '../../domain/entities/user_summary.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// 管理后台：数据统计、用户管理、预警处理。
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()
        ..add(const AdminLoadEvent())
        ..add(const AdminLoadUsersEvent())
        ..add(const AdminLoadAlertsEvent()),
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatelessWidget {
  const _AdminView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('管理后台'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.analytics_outlined), text: '数据统计'),
              Tab(icon: Icon(Icons.people_outline), text: '用户管理'),
              Tab(icon: Icon(Icons.warning_amber_outlined), text: '预警处理'),
            ],
          ),
        ),
        body: BlocConsumer<AdminBloc, AdminState>(
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
            return TabBarView(
              children: [
                _StatsTab(state: state),
                _UsersTab(state: state),
                _AlertsTab(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.state});
  final AdminState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.stats == null) {
      return const JYLoading(message: '加载中…');
    }
    if (state.errorMessage != null && state.stats == null) {
      return JYErrorWidget(
        message: state.errorMessage!,
        onRetry: () => context.read<AdminBloc>().add(const AdminLoadEvent()),
      );
    }
    final stats = state.stats;
    if (stats == null) {
      return const JYEmptyState(message: '暂无数据');
    }
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatCard(
            title: '总用户数',
            value: '${stats.totalUsers}',
            icon: Icons.people,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: '今日活跃',
            value: '${stats.activeUsersToday}',
            icon: Icons.today,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: '总会话数',
            value: '${stats.totalConversations}',
            icon: Icons.chat_bubble_outline,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: '总消息数',
            value: '${stats.totalMessages}',
            icon: Icons.message_outlined,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: '待处理预警',
            value: '${stats.activeCrisisAlerts}',
            icon: Icons.warning_amber,
            highlight: stats.activeCrisisAlerts > 0,
          ),
          if (stats.avgResponseTimeMs != null) ...[
            const SizedBox(height: 12),
            _StatCard(
              title: '平均响应时间(ms)',
              value: stats.avgResponseTimeMs!.toStringAsFixed(0),
              icon: Icons.timer_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.highlight = false,
  });
  final String title;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: highlight ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: highlight ? AppColors.error : null,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.state});
  final AdminState state;

  @override
  Widget build(BuildContext context) {
    final users = state.users;
    if (users.isEmpty && state.usersTotal == 0) {
      return const JYEmptyState(message: '暂无用户');
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const AdminLoadUsersEvent());
      },
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return _UserTile(
            user: u,
            onToggleActive: () {
              context.read<AdminBloc>().add(AdminUpdateUserStatusEvent(
                    userId: u.id,
                    isActive: !u.isActive,
                  ));
            },
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onToggleActive});
  final UserSummary user;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(user.username),
        subtitle: Text(
          '${user.roleDisplay} · ${user.isActive ? "正常" : "已停用"}',
        ),
        trailing: Switch(
          value: user.isActive,
          onChanged: (_) => onToggleActive(),
        ),
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab({required this.state});
  final AdminState state;

  @override
  Widget build(BuildContext context) {
    final alerts = state.alerts;
    if (alerts.isEmpty && state.alertsTotal == 0) {
      return const JYEmptyState(message: '暂无预警');
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const AdminLoadAlertsEvent());
      },
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final a = alerts[index];
          return _AlertTile(
            alert: a,
            onResolve: () => _showResolveDialog(context, a),
          );
        },
      ),
    );
  }

  void _showResolveDialog(BuildContext context, CrisisAlertSummary alert) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('处理预警'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('预警级别：${alert.alertLevelDisplay}'),
            const SizedBox(height: 8),
            Text('触发内容：${alert.triggerContent}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: '处理备注（选填）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AdminBloc>().add(AdminResolveAlertEvent(
                    alertId: alert.id,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  ));
            },
            child: const Text('确认解决'),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onResolve});
  final CrisisAlertSummary alert;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final isActive = alert.status == 'active';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? AppColors.error.withValues(alpha: 0.05) : null,
      child: ListTile(
        title: Text('${alert.alertLevelDisplay} · ${alert.statusDisplay}'),
        subtitle: Text(
          '用户 ${alert.userId} · ${alert.triggerContent}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isActive
            ? FilledButton(
                onPressed: onResolve,
                child: const Text('处理'),
              )
            : null,
      ),
    );
  }
}
