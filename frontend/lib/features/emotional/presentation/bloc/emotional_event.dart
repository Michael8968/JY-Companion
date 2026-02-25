sealed class EmotionalEvent {
  const EmotionalEvent();
}

class EmotionalLoadEvent extends EmotionalEvent {
  const EmotionalLoadEvent();
}

class EmotionalCreateGratitudeEvent extends EmotionalEvent {
  const EmotionalCreateGratitudeEvent(this.content);
  final String content;
}
