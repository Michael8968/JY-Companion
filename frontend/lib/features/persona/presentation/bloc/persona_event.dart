import 'package:freezed_annotation/freezed_annotation.dart';

part 'persona_event.freezed.dart';

@freezed
class PersonaEvent with _$PersonaEvent {
  const factory PersonaEvent.load() = _Load;
  const factory PersonaEvent.bind({
    required String personaId,
    String? nickname,
  }) = _Bind;
}
