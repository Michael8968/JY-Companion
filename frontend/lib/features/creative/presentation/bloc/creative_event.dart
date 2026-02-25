sealed class CreativeEvent {
  const CreativeEvent();
}

class CreativeGenerateEvent extends CreativeEvent {
  const CreativeGenerateEvent({required this.topic, this.style});
  final String topic;
  final String? style;
}

class CreativeEvaluateEvent extends CreativeEvent {
  const CreativeEvaluateEvent({required this.text, this.genre});
  final String text;
  final String? genre;
}

class CreativeAddToLibraryEvent extends CreativeEvent {
  const CreativeAddToLibraryEvent({required this.topic, required this.content});
  final String topic;
  final String content;
}
