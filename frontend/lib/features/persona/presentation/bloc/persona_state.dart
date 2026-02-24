import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/persona.dart';
import '../../domain/entities/persona_binding.dart';

part 'persona_state.freezed.dart';

@freezed
class PersonaState with _$PersonaState {
  const factory PersonaState({
    @Default([]) List<Persona> personas,
    @Default([]) List<PersonaBinding> bindings,
    @Default(false) bool isLoading,
    @Default(false) bool isBinding,
    String? errorMessage,
    String? successMessage,
  }) = _PersonaState;
}
