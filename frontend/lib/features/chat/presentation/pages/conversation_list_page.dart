import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../injection.dart';
import '../../domain/enums/agent_type.dart';
import '../bloc/conversation_list/conversation_list_bloc.dart';
import '../bloc/conversation_list/conversation_list_event.dart';
import '../bloc/conversation_list/conversation_list_state.dart';
import '../widgets/conversation_tile.dart';

class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationListBloc>()
        ..add(const ConversationListEvent.load()),
      child: const _ConversationListView(),
    );
  }
}

class _ConversationListView extends StatelessWidget {
  const _ConversationListView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationListBloc, ConversationListState>(
      listenWhen: (prev, curr) =>
          prev.createdConversationId != curr.createdConversationId &&
          curr.createdConversationId != null,
      listener: (context, state) {
        if (state.createdConversationId != null) {
          context.push('/chat/${state.createdConversationId}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ConversationListState state) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const JYLoading(message: '加载对话列表...');
    }

    if (state.errorMessage != null && state.conversations.isEmpty) {
      return JYErrorWidget(
        message: state.errorMessage!,
        onRetry: () => context
            .read<ConversationListBloc>()
            .add(const ConversationListEvent.load()),
      );
    }

    if (state.conversations.isEmpty) {
      return JYEmptyState(
        message: '还没有对话，点击右下角按钮开始',
        icon: Icons.chat_bubble_outline,
        actionLabel: '新建对话',
        action: () => _showCreateDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<ConversationListBloc>()
            .add(const ConversationListEvent.refresh());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () => context.push('/chat/${conversation.id}'),
            onDelete: () => context
                .read<ConversationListBloc>()
                .add(ConversationListEvent.delete(conversation.id)),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择对话类型',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: AgentType.values.map((type) {
                return _AgentTypeOption(
                  type: type,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<ConversationListBloc>().add(
                          ConversationListEvent.create(
                            agentType: type.value,
                          ),
                        );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AgentTypeOption extends StatelessWidget {
  const _AgentTypeOption({required this.type, required this.onTap});

  final AgentType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: type.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              type.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
