import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          unauthenticated: () => context.go('/login'),
        );
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildProfileHeader(context),
              const SizedBox(height: 32),
              _buildSettingsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

        return Column(
          children: [
            JYAvatar(
              imageUrl: user?.avatarUrl,
              name: user?.displayName,
              radius: 40,
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? '未登录',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            if (user != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _roleLabel(user.role),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        final isAdmin = user?.role == 'admin';

        return Column(
          children: [
            if (isAdmin) ...[
              _SettingsTile(
                icon: Icons.admin_panel_settings_outlined,
                title: '管理后台',
                onTap: () => context.go('/home/admin'),
              ),
              const SizedBox(height: 8),
            ],
            _SettingsTile(
              icon: Icons.person_outline,
              title: '账号信息',
              onTap: () {
                // TODO: Navigate to account info
              },
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: '关于',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: '星澜学伴',
                  applicationVersion: '0.1.0',
                  children: [
                    const Text('AI 智能学习伙伴'),
                    const Text('星澜中学出品'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.logout,
              title: '退出登录',
              textColor: AppColors.error,
              onTap: () => _confirmLogout(context),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'student' => '学生',
      'teacher' => '教师',
      'parent' => '家长',
      'admin' => '管理员',
      _ => role,
    };
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor ?? AppColors.textHint,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
    );
  }
}
