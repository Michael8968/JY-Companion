import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../../domain/entities/classroom_doubt.dart';
import '../../domain/entities/classroom_session.dart';
import '../../domain/entities/study_plan.dart';
import '../bloc/session_detail_bloc.dart';
import '../bloc/session_detail_event.dart';
import '../bloc/session_detail_state.dart';
import '../widgets/summary_outline_view.dart';
import '../widgets/summary_concepts_view.dart';

/// 课堂会话详情：摘要（大纲/图表双视图）、疑问点、学案查看。
class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionDetailBloc>()
        ..add(SessionDetailLoadEvent(sessionId)),
      child: _SessionDetailView(sessionId: sessionId),
    );
  }
}

class _SessionDetailView extends StatefulWidget {
  const _SessionDetailView({required this.sessionId});

  final String sessionId;

  @override
  State<_SessionDetailView> createState() => _SessionDetailViewState();
}

class _SessionDetailViewState extends State<_SessionDetailView> {
  int _summaryTabIndex = 0; // 0: 大纲, 1: 图表

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课堂复盘'),
      ),
      body: BlocConsumer<SessionDetailBloc, SessionDetailState>(
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
            if (state.isLoading && state.session == null) {
              return const JYLoading(message: '加载中…');
            }
            if (state.errorMessage != null && state.session == null) {
              return JYErrorWidget(
                message: state.errorMessage!,
                onRetry: () => context
                    .read<SessionDetailBloc>()
                    .add(SessionDetailLoadEvent(widget.sessionId)),
              );
            }
            final session = state.session;
            if (session == null) {
              return const JYEmptyState(
                message: '会话不存在',
                icon: Icons.class_,
              );
            }
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: '摘要'),
                      Tab(text: '疑问点'),
                      Tab(text: '学案'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSummaryTab(session),
                        _buildDoubtsTab(state.doubts, state.isLoadingDoubts),
                        _buildStudyPlanTab(
                          state.studyPlan,
                          state.isLoadingStudyPlan,
                          widget.sessionId,
                          context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }

  Widget _buildSummaryTab(ClassroomSession session) {
    final hasOutline = session.summaryOutline != null &&
        session.summaryOutline!.isNotEmpty;
    final hasConcepts = (session.summaryConcepts != null &&
            session.summaryConcepts!.isNotEmpty) ||
        (session.keyPoints != null && session.keyPoints!.isNotEmpty);
    if (!hasOutline && !hasConcepts) {
      return JYEmptyState(
        message: '暂无摘要，请等待转写完成',
        icon: Icons.summarize,
      );
    }
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('大纲')),
              ButtonSegment(value: 1, label: Text('图表')),
            ],
            selected: {_summaryTabIndex},
            onSelectionChanged: (s) =>
                setState(() => _summaryTabIndex = s.first),
          ),
          const SizedBox(height: 16),
          if (_summaryTabIndex == 0 && hasOutline)
            SummaryOutlineView(data: session.summaryOutline!),
          if (_summaryTabIndex == 1 && hasConcepts)
            SummaryConceptsView(
              concepts: session.summaryConcepts,
              keyPoints: session.keyPoints,
            ),
        ],
      ),
    );
  }

  Widget _buildDoubtsTab(List<ClassroomDoubt>? doubts, bool loading) {
    if (loading && (doubts == null || doubts.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (doubts == null || doubts.isEmpty) {
      return JYEmptyState(
        message: '暂无疑问点',
        icon: Icons.help_outline,
      );
    }
    return ListView.separated(
      padding: AppSpacing.paddingMd,
      itemCount: doubts.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final d = doubts[index];
        return Card(
          child: ListTile(
            title: Text(d.textExcerpt),
            subtitle: Text(
              '${d.doubtTypeDisplay} · 重要性 ${(d.importance * 100).toInt()}%',
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudyPlanTab(
    StudyPlan? plan,
    bool loading,
    String sessionId,
    BuildContext context,
  ) {
    if (loading && plan == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (plan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const JYEmptyState(
              message: '暂无学案，点击下方按钮生成',
              icon: Icons.menu_book,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<SessionDetailBloc>()
                  .add(SessionDetailGenerateStudyPlanEvent(sessionId)),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成学案'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.content != null && plan.content!.isNotEmpty) ...[
            Text(
              '学案内容',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(plan.content!),
            const SizedBox(height: 24),
          ],
          if (plan.reviewPoints != null && plan.reviewPoints!.isNotEmpty) ...[
            Text(
              '复习要点',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._mapToLines(plan.reviewPoints!).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $e'),
                )),
            const SizedBox(height: 24),
          ],
          if (plan.exercises != null && plan.exercises!.isNotEmpty) ...[
            Text(
              '推荐练习',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._mapToLines(plan.exercises!).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $e'),
                )),
          ],
        ],
      ),
    );
  }

  List<String> _mapToLines(Map<String, dynamic> map) {
    final list = <String>[];
    for (final e in map.entries) {
      if (e.value is String) {
        list.add('${e.key}: ${e.value}');
      } else if (e.value is List) {
        for (final item in e.value as List) {
          list.add(item.toString());
        }
      }
    }
    return list;
  }
}
