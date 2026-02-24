import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jy_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final displayName = state.maybeWhen(
          authenticated: (user) => user.displayName,
          orElse: () => '同学',
        );

        final avatarUrl = state.maybeWhen(
          authenticated: (user) => user.avatarUrl,
          orElse: () => null,
        );

        return Row(
          children: [
            JYAvatar(
              imageUrl: avatarUrl,
              name: displayName,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你好，$displayName',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // TODO: Notifications
              },
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，注意休息哦';
    if (hour < 12) return '早上好，今天也要加油';
    if (hour < 14) return '中午好，记得午休哦';
    if (hour < 18) return '下午好，继续学习吧';
    return '晚上好，今天辛苦了';
  }
}
