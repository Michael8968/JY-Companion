import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../bloc/emotional_bloc.dart';
import '../bloc/emotional_event.dart';
import '../bloc/emotional_state.dart';
import '../widgets/breathing_guide_widget.dart';
import '../widgets/relaxation_animation_widget.dart';
import '../widgets/emotion_trend_widget.dart';

/// 情感陪伴页面：情绪日记、呼吸练习引导、放松动画、情绪趋势图。
class EmotionalPage extends StatelessWidget {
  const EmotionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EmotionalBloc>()..add(const EmotionalLoadEvent()),
      child: const _EmotionalView(),
    );
  }
}

class _EmotionalView extends StatelessWidget {
  const _EmotionalView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('情感陪伴'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: '情绪日记'),
              Tab(icon: Icon(Icons.air), text: '呼吸练习'),
              Tab(icon: Icon(Icons.spa), text: '放松'),
              Tab(icon: Icon(Icons.show_chart), text: '情绪趋势'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EmotionDiaryTab(),
            const BreathingGuideWidget(),
            const RelaxationAnimationWidget(),
            _EmotionTrendTab(),
          ],
        ),
      ),
    );
  }
}

class _EmotionDiaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmotionalBloc, EmotionalState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
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
        if (state.isLoading && state.emotions.isEmpty && state.gratitudeEntries.isEmpty) {
          return const JYLoading(message: '加载中…');
        }
        if (state.errorMessage != null &&
            state.emotions.isEmpty &&
            state.gratitudeEntries.isEmpty) {
          return JYErrorWidget(
            message: state.errorMessage!,
            onRetry: () => context.read<EmotionalBloc>().add(const EmotionalLoadEvent()),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            context.read<EmotionalBloc>().add(const EmotionalLoadEvent());
          },
          child: SingleChildScrollView(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '感恩日记',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddGratitude(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加感恩'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.gratitudeEntries.isEmpty)
                  JYEmptyState(
                    message: '写下一件今天感恩的事',
                    icon: Icons.favorite_border,
                    actionLabel: '添加',
                    action: () => _showAddGratitude(context),
                  )
                else
                  ...state.gratitudeEntries.take(10).map(
                        (e) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(e.content),
                            subtitle: Text(
                              _formatDate(e.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Text(
                  '近期情绪',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (state.emotions.isEmpty)
                  JYEmptyState(
                    message: '暂无情绪记录，与学伴对话时会自动记录',
                    icon: Icons.mood,
                  )
                else
                  ...state.emotions.take(10).map(
                        (e) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              _emotionIcon(e.emotionLabel),
                              color: AppColors.emotional,
                            ),
                            title: Text(e.emotionDisplay),
                            subtitle: Text(
                              '效价 ${e.valence.toStringAsFixed(2)} · ${_formatDate(e.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.month}月${d.day}日 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  IconData _emotionIcon(String label) {
    switch (label) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'calm':
        return Icons.sentiment_satisfied;
      case 'anxious':
      case 'fearful':
        return Icons.sentiment_dissatisfied;
      case 'sad':
      case 'depressed':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.mood;
    }
  }

  void _showAddGratitude(BuildContext context) {
    final controller = TextEditingController();
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
              '感恩日记',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '今天感恩的一件事…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final content = controller.text.trim();
                if (content.isEmpty) return;
                Navigator.of(ctx).pop();
                context
                    .read<EmotionalBloc>()
                    .add(EmotionalCreateGratitudeEvent(content));
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionTrendTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmotionalBloc, EmotionalState>(
      builder: (context, state) {
        if (state.emotions.isEmpty) {
          return JYEmptyState(
            message: '暂无情绪数据，与学伴对话后会显示趋势',
            icon: Icons.show_chart,
          );
        }
        return EmotionTrendWidget(emotions: state.emotions);
      },
    );
  }
}
