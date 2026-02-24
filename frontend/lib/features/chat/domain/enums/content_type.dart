enum ContentType {
  text('text'),
  image('image'),
  audio('audio'),
  file('file');

  final String value;
  const ContentType(this.value);

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentType.text,
    );
  }
}
