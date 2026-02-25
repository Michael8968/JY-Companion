import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_button.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../core/widgets/jy_text_field.dart';
import '../../../../injection.dart';
import '../../domain/entities/evaluate_result.dart';
import '../../domain/entities/generate_result.dart';
import '../bloc/creative_bloc.dart';
import '../bloc/creative_event.dart';
import '../bloc/creative_state.dart';

/// 创意创作页面：创意生成、作品评价、作品库。
class CreativePage extends StatelessWidget {
  const CreativePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CreativeBloc>(),
      child: const _CreativeView(),
    );
  }
}

class _CreativeView extends StatelessWidget {
  const _CreativeView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('创意创作'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.auto_awesome), text: '创意生成'),
              Tab(icon: Icon(Icons.rate_review), text: '作品评价'),
              Tab(icon: Icon(Icons.collections_bookmark), text: '作品库'),
            ],
          ),
        ),
        body: BlocConsumer<CreativeBloc, CreativeState>(
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
                _GenerateTab(
                  result: state.generateResult,
                  isLoading: state.isLoading,
                  onGenerate: (topic, style) => context
                      .read<CreativeBloc>()
                      .add(CreativeGenerateEvent(topic: topic, style: style)),
                ),
                _EvaluateTab(
                  result: state.evaluateResult,
                  isLoading: state.isLoading,
                  onEvaluate: (text, genre) => context
                      .read<CreativeBloc>()
                      .add(CreativeEvaluateEvent(text: text, genre: genre)),
                ),
                _LibraryTab(items: state.libraryItems),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GenerateTab extends StatefulWidget {
  const _GenerateTab({
    required this.result,
    required this.isLoading,
    required this.onGenerate,
  });

  final GenerateResult? result;
  final bool isLoading;
  final void Function(String topic, String? style) onGenerate;

  @override
  State<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<_GenerateTab> {
  final _topicController = TextEditingController();
  final _styleController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JYTextField(
            label: '主题',
            controller: _topicController,
            hint: '例如：一只会说话的猫',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          JYTextField(
            label: '风格（可选）',
            controller: _styleController,
            hint: '例如：童话、科幻',
          ),
          const SizedBox(height: 24),
          JYButton(
            label: '生成创意',
            onPressed: widget.isLoading
                ? null
                : () {
                    final topic = _topicController.text.trim();
                    if (topic.isEmpty) {
                      JYSnackbar.show(
                        context,
                        message: '请输入主题',
                        type: SnackbarType.warning,
                      );
                      return;
                    }
                    final style = _styleController.text.trim();
                    widget.onGenerate(
                      topic,
                      style.isEmpty ? null : style,
                    );
                  },
            isLoading: widget.isLoading,
            icon: Icons.auto_awesome,
          ),
          if (widget.result != null) ...[
            const SizedBox(height: 24),
            Text(
              '生成结果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: SelectableText(
                  widget.result!.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvaluateTab extends StatefulWidget {
  const _EvaluateTab({
    required this.result,
    required this.isLoading,
    required this.onEvaluate,
  });

  final EvaluateResult? result;
  final bool isLoading;
  final void Function(String text, String? genre) onEvaluate;

  @override
  State<_EvaluateTab> createState() => _EvaluateTabState();
}

class _EvaluateTabState extends State<_EvaluateTab> {
  final _textController = TextEditingController();
  final _genreController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JYTextField(
            label: '作品内容',
            controller: _textController,
            hint: '粘贴或输入待评价的文本',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          JYTextField(
            label: '体裁（可选）',
            controller: _genreController,
            hint: '例如：小说、诗歌',
          ),
          const SizedBox(height: 24),
          JYButton(
            label: '获取评价',
            onPressed: widget.isLoading
                ? null
                : () {
                    final text = _textController.text.trim();
                    if (text.isEmpty) {
                      JYSnackbar.show(
                        context,
                        message: '请输入作品内容',
                        type: SnackbarType.warning,
                      );
                      return;
                    }
                    final genre = _genreController.text.trim();
                    widget.onEvaluate(
                      text,
                      genre.isEmpty ? null : genre,
                    );
                  },
            isLoading: widget.isLoading,
            icon: Icons.rate_review,
          ),
          if (widget.result != null) ...[
            const SizedBox(height: 24),
            Text(
              '评价结果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: SelectableText(
                  widget.result!.evaluation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({required this.items});

  final List<CreativeWorkItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return JYEmptyState(
        message: '在「创意生成」中生成内容后会自动加入作品库',
        icon: Icons.collections_bookmark,
      );
    }
    return ListView.separated(
      padding: AppSpacing.paddingMd,
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final preview = item.content.length > 100
            ? '${item.content.substring(0, 100)}…'
            : item.content;
        return Card(
          child: ListTile(
            title: Text(item.topic),
            subtitle: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => _showDetail(context, item),
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, CreativeWorkItem item) {
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
                item.topic,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SelectableText(
                item.content,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
