import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jy_app_bar.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../injection.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/streaming_text.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatBloc>()
        ..add(ChatEvent.enterChat(conversationId)),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(
          appBar: JYAppBar(
            title: '对话',
            actions: [
              if (!state.wsConnected)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.cloud_off,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
            ],
          ),
          body: WillPopScope(
            onWillPop: () async {
              context.read<ChatBloc>().add(const ChatEvent.leaveChat());
              return true;
            },
            child: Column(
              children: [
                // Connection lost banner
                if (!state.wsConnected)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: AppColors.warning.withValues(alpha: 0.2),
                    child: const Text(
                      '连接已断开，正在重连...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Messages
                Expanded(child: _buildMessageList(context, state)),
                // Input
                ChatInputBar(
                  onSend: (content) {
                    context
                        .read<ChatBloc>()
                        .add(ChatEvent.sendMessage(content));
                  },
                  enabled: state.wsConnected && !state.isSending,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList(BuildContext context, ChatState state) {
    if (state.isLoadingHistory && state.messages.isEmpty) {
      return const JYLoading(message: '加载消息...');
    }

    if (state.errorMessage != null && state.messages.isEmpty) {
      return JYErrorWidget(message: state.errorMessage!);
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length +
          (state.isStreaming ? 1 : 0) +
          (state.hasMoreMessages ? 1 : 0),
      itemBuilder: (context, index) {
        // Streaming message at the bottom (index 0 since reversed)
        if (state.isStreaming && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StreamingText(text: state.streamingContent),
          );
        }

        final messageIndex = state.isStreaming ? index - 1 : index;
        final reversedIndex = state.messages.length - 1 - messageIndex;

        // Load more indicator at the top
        if (reversedIndex < 0) {
          if (state.hasMoreMessages) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<ChatBloc>()
                  .add(const ChatEvent.loadMoreMessages());
            });
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final message = state.messages[reversedIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MessageBubble(message: message),
        );
      },
    );
  }
}
