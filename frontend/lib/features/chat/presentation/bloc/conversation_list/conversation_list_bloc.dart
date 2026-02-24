import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/create_conversation_usecase.dart';
import '../../../domain/usecases/delete_conversation_usecase.dart';
import '../../../domain/usecases/list_conversations_usecase.dart';
import 'conversation_list_event.dart';
import 'conversation_list_state.dart';

@injectable
class ConversationListBloc
    extends Bloc<ConversationListEvent, ConversationListState> {
  final ListConversationsUseCase _listConversationsUseCase;
  final CreateConversationUseCase _createConversationUseCase;
  final DeleteConversationUseCase _deleteConversationUseCase;

  ConversationListBloc(
    this._listConversationsUseCase,
    this._createConversationUseCase,
    this._deleteConversationUseCase,
  ) : super(const ConversationListState()) {
    on<ConversationListEvent>(_onEvent);
  }

  Future<void> _onEvent(
    ConversationListEvent event,
    Emitter<ConversationListState> emit,
  ) async {
    await event.when(
      load: () => _onLoad(emit),
      refresh: () => _onRefresh(emit),
      create: (agentType, personaId, title) =>
          _onCreate(agentType, personaId, title, emit),
      delete: (id) => _onDelete(id, emit),
    );
  }

  Future<void> _onLoad(Emitter<ConversationListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _listConversationsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (conversations) => emit(state.copyWith(
        isLoading: false,
        conversations: conversations,
      )),
    );
  }

  Future<void> _onRefresh(Emitter<ConversationListState> emit) async {
    final result = await _listConversationsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (conversations) => emit(state.copyWith(
        conversations: conversations,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onCreate(
    String agentType,
    String? personaId,
    String? title,
    Emitter<ConversationListState> emit,
  ) async {
    emit(state.copyWith(
      isCreating: true,
      createdConversationId: null,
      errorMessage: null,
    ));

    final result = await _createConversationUseCase(
      agentType: agentType,
      personaId: personaId,
      title: title,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isCreating: false,
        errorMessage: failure.message,
      )),
      (conversation) => emit(state.copyWith(
        isCreating: false,
        conversations: [conversation, ...state.conversations],
        createdConversationId: conversation.id,
      )),
    );
  }

  Future<void> _onDelete(
    String conversationId,
    Emitter<ConversationListState> emit,
  ) async {
    final result = await _deleteConversationUseCase(conversationId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        conversations:
            state.conversations.where((c) => c.id != conversationId).toList(),
      )),
    );
  }
}
