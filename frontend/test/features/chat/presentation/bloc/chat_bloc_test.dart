import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jy_companion/core/error/either.dart';
import 'package:jy_companion/core/error/failures.dart';
import 'package:jy_companion/features/chat/data/models/ws_message_model.dart';
import 'package:jy_companion/features/chat/domain/entities/message.dart';
import 'package:jy_companion/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:jy_companion/features/chat/presentation/bloc/chat/chat_event.dart';
import 'package:jy_companion/features/chat/presentation/bloc/chat/chat_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockChatWsDataSource mockWsDataSource;
  late MockGetMessagesUseCase mockGetMessagesUseCase;
  late StreamController<WsOutgoingMessage> wsStreamController;

  const testConversationId = '660e8400-e29b-41d4-a716-446655440001';

  final testMessages = [
    Message(
      id: 'msg1',
      role: 'user',
      contentType: 'text',
      content: '你好',
      createdAt: DateTime(2024, 6, 1, 10, 0),
    ),
    Message(
      id: 'msg2',
      role: 'assistant',
      contentType: 'text',
      content: '你好！有什么可以帮助你的？',
      createdAt: DateTime(2024, 6, 1, 10, 0, 5),
    ),
  ];

  setUp(() {
    mockWsDataSource = MockChatWsDataSource();
    mockGetMessagesUseCase = MockGetMessagesUseCase();
    wsStreamController = StreamController<WsOutgoingMessage>.broadcast();

    when(() => mockWsDataSource.messageStream)
        .thenAnswer((_) => wsStreamController.stream);
    when(() => mockWsDataSource.connect()).thenAnswer((_) async {});
    when(() => mockWsDataSource.disconnect()).thenAnswer((_) async {});
    when(() => mockWsDataSource.dispose()).thenReturn(null);
  });

  tearDown(() {
    wsStreamController.close();
  });

  ChatBloc buildBloc() => ChatBloc(mockWsDataSource, mockGetMessagesUseCase);

  group('ChatBloc', () {
    test('initial state is ChatState()', () {
      expect(buildBloc().state, const ChatState());
    });

    group('EnterChat', () {
      blocTest<ChatBloc, ChatState>(
        'connects WS and loads messages on enter',
        setUp: () {
          when(() => mockGetMessagesUseCase(any()))
              .thenAnswer((_) async => Right((
                    messages: testMessages,
                    total: 2,
                  )));
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ChatEvent.enterChat(testConversationId)),
        expect: () => [
          const ChatState(
            conversationId: testConversationId,
            messages: [],
            currentPage: 1,
            isLoadingHistory: true,
          ),
          isA<ChatState>()
              .having((s) => s.isLoadingHistory, 'isLoadingHistory', false)
              .having((s) => s.messages.length, 'messages.length', 2),
        ],
        verify: (_) {
          verify(() => mockWsDataSource.connect()).called(1);
          verify(() => mockGetMessagesUseCase(testConversationId)).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits error when loading messages fails',
        setUp: () {
          when(() => mockGetMessagesUseCase(any()))
              .thenAnswer((_) async => const Left(NetworkFailure()));
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ChatEvent.enterChat(testConversationId)),
        expect: () => [
          const ChatState(
            conversationId: testConversationId,
            messages: [],
            currentPage: 1,
            isLoadingHistory: true,
          ),
          isA<ChatState>()
              .having((s) => s.isLoadingHistory, 'isLoadingHistory', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('SendMessage', () {
      blocTest<ChatBloc, ChatState>(
        'adds user message to list and sends via WS',
        setUp: () {
          when(() => mockWsDataSource.sendChatMessage(
                conversationId: any(named: 'conversationId'),
                content: any(named: 'content'),
                contentType: any(named: 'contentType'),
              )).thenReturn(null);
        },
        build: buildBloc,
        seed: () => const ChatState(conversationId: testConversationId),
        act: (bloc) => bloc.add(const ChatEvent.sendMessage('你好')),
        expect: () => [
          isA<ChatState>()
              .having((s) => s.messages.length, 'messages.length', 1)
              .having((s) => s.messages.first.content, 'content', '你好')
              .having((s) => s.messages.first.role, 'role', 'user')
              .having((s) => s.isSending, 'isSending', true),
        ],
      );
    });

    group('WsMessageReceived', () {
      blocTest<ChatBloc, ChatState>(
        'handles stream_start -> stream_chunk -> stream_end flow',
        build: buildBloc,
        seed: () => const ChatState(conversationId: testConversationId),
        act: (bloc) {
          bloc.add(const ChatEvent.wsMessageReceived(
            WsOutgoingMessage(type: 'stream_start', data: {}),
          ));
          bloc.add(const ChatEvent.wsMessageReceived(
            WsOutgoingMessage(type: 'stream_chunk', data: {'content': '你好'}),
          ));
          bloc.add(const ChatEvent.wsMessageReceived(
            WsOutgoingMessage(type: 'stream_chunk', data: {'content': '！'}),
          ));
          bloc.add(const ChatEvent.wsMessageReceived(
            WsOutgoingMessage(
              type: 'stream_end',
              data: {
                'message_id': 'msg_final',
                'emotion_label': 'calm',
              },
            ),
          ));
        },
        expect: () => [
          // stream_start
          isA<ChatState>()
              .having((s) => s.isStreaming, 'isStreaming', true)
              .having((s) => s.streamingContent, 'streamingContent', ''),
          // stream_chunk 1
          isA<ChatState>()
              .having((s) => s.streamingContent, 'streamingContent', '你好'),
          // stream_chunk 2
          isA<ChatState>()
              .having((s) => s.streamingContent, 'streamingContent', '你好！'),
          // stream_end
          isA<ChatState>()
              .having((s) => s.isStreaming, 'isStreaming', false)
              .having((s) => s.streamingContent, 'streamingContent', '')
              .having((s) => s.messages.length, 'messages.length', 1)
              .having((s) => s.messages.last.content, 'content', '你好！')
              .having(
                  (s) => s.messages.last.emotionLabel, 'emotion', 'calm'),
        ],
      );
    });
  });
}
