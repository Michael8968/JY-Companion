import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jy_companion/core/error/either.dart';
import 'package:jy_companion/core/error/failures.dart';
import 'package:jy_companion/features/chat/domain/entities/conversation.dart';
import 'package:jy_companion/features/chat/presentation/bloc/conversation_list/conversation_list_bloc.dart';
import 'package:jy_companion/features/chat/presentation/bloc/conversation_list/conversation_list_event.dart';
import 'package:jy_companion/features/chat/presentation/bloc/conversation_list/conversation_list_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockListConversationsUseCase mockListConversations;
  late MockCreateConversationUseCase mockCreateConversation;
  late MockDeleteConversationUseCase mockDeleteConversation;

  final testConversations = [
    Conversation(
      id: 'conv1',
      agentType: 'academic',
      title: '数学函数',
      status: 'active',
      messageCount: 5,
      lastMessageAt: DateTime(2024, 6, 1),
      createdAt: DateTime(2024, 6, 1),
    ),
    Conversation(
      id: 'conv2',
      agentType: 'emotional',
      title: null,
      status: 'active',
      messageCount: 12,
      lastMessageAt: DateTime(2024, 5, 30),
      createdAt: DateTime(2024, 5, 30),
    ),
  ];

  setUp(() {
    mockListConversations = MockListConversationsUseCase();
    mockCreateConversation = MockCreateConversationUseCase();
    mockDeleteConversation = MockDeleteConversationUseCase();
  });

  ConversationListBloc buildBloc() => ConversationListBloc(
        mockListConversations,
        mockCreateConversation,
        mockDeleteConversation,
      );

  group('ConversationListBloc', () {
    test('initial state is ConversationListState()', () {
      expect(buildBloc().state, const ConversationListState());
    });

    group('Load', () {
      blocTest<ConversationListBloc, ConversationListState>(
        'emits loaded state with conversations',
        setUp: () {
          when(() => mockListConversations(page: any(named: 'page'), size: any(named: 'size')))
              .thenAnswer((_) async => Right(testConversations));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ConversationListEvent.load()),
        expect: () => [
          const ConversationListState(isLoading: true),
          ConversationListState(conversations: testConversations),
        ],
      );

      blocTest<ConversationListBloc, ConversationListState>(
        'emits error when loading fails',
        setUp: () {
          when(() => mockListConversations(page: any(named: 'page'), size: any(named: 'size')))
              .thenAnswer((_) async => const Left(NetworkFailure()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ConversationListEvent.load()),
        expect: () => [
          const ConversationListState(isLoading: true),
          isA<ConversationListState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('Create', () {
      blocTest<ConversationListBloc, ConversationListState>(
        'creates conversation and adds to list',
        setUp: () {
          final newConversation = Conversation(
            id: 'conv3',
            agentType: 'academic',
            title: null,
            status: 'active',
            messageCount: 0,
            createdAt: DateTime(2024, 6, 2),
          );
          when(() => mockCreateConversation(
                agentType: any(named: 'agentType'),
                personaId: any(named: 'personaId'),
                title: any(named: 'title'),
              )).thenAnswer((_) async => Right(newConversation));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ConversationListEvent.create(agentType: 'academic'),
        ),
        expect: () => [
          const ConversationListState(isCreating: true),
          isA<ConversationListState>()
              .having((s) => s.isCreating, 'isCreating', false)
              .having((s) => s.conversations.length, 'length', 1)
              .having((s) => s.createdConversationId, 'createdId', 'conv3'),
        ],
      );
    });

    group('Delete', () {
      blocTest<ConversationListBloc, ConversationListState>(
        'removes conversation from list',
        setUp: () {
          when(() => mockDeleteConversation(any()))
              .thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        seed: () => ConversationListState(conversations: testConversations),
        act: (bloc) =>
            bloc.add(const ConversationListEvent.delete('conv1')),
        expect: () => [
          isA<ConversationListState>()
              .having((s) => s.conversations.length, 'length', 1)
              .having(
                  (s) => s.conversations.first.id, 'remaining', 'conv2'),
        ],
      );
    });
  });
}
