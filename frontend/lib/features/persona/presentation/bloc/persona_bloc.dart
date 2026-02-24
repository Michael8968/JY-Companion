import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/bind_persona_usecase.dart';
import '../../domain/usecases/list_bindings_usecase.dart';
import '../../domain/usecases/list_personas_usecase.dart';
import 'persona_event.dart';
import 'persona_state.dart';

@injectable
class PersonaBloc extends Bloc<PersonaEvent, PersonaState> {
  final ListPersonasUseCase _listPersonasUseCase;
  final BindPersonaUseCase _bindPersonaUseCase;
  final ListBindingsUseCase _listBindingsUseCase;

  PersonaBloc(
    this._listPersonasUseCase,
    this._bindPersonaUseCase,
    this._listBindingsUseCase,
  ) : super(const PersonaState()) {
    on<PersonaEvent>(_onEvent);
  }

  Future<void> _onEvent(
    PersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    await event.when(
      load: () => _onLoad(emit),
      bind: (personaId, nickname) => _onBind(personaId, nickname, emit),
    );
  }

  Future<void> _onLoad(Emitter<PersonaState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final personasResult = await _listPersonasUseCase();
    final bindingsResult = await _listBindingsUseCase();

    personasResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (personas) {
        bindingsResult.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            personas: personas,
            errorMessage: failure.message,
          )),
          (bindings) => emit(state.copyWith(
            isLoading: false,
            personas: personas,
            bindings: bindings,
          )),
        );
      },
    );
  }

  Future<void> _onBind(
    String personaId,
    String? nickname,
    Emitter<PersonaState> emit,
  ) async {
    emit(state.copyWith(isBinding: true, errorMessage: null, successMessage: null));

    final result = await _bindPersonaUseCase(personaId, nickname: nickname);
    result.fold(
      (failure) => emit(state.copyWith(
        isBinding: false,
        errorMessage: failure.message,
      )),
      (binding) => emit(state.copyWith(
        isBinding: false,
        bindings: [...state.bindings, binding],
        successMessage: '绑定成功',
      )),
    );
  }
}
