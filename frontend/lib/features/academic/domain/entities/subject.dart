/// 学科枚举，与后端 Subject 一致。
enum Subject {
  math('math', '数学'),
  physics('physics', '物理'),
  chemistry('chemistry', '化学'),
  chinese('chinese', '语文'),
  english('english', '英语'),
  biology('biology', '生物'),
  history('history', '历史'),
  geography('geography', '地理'),
  politics('politics', '政治');

  const Subject(this.value, this.displayName);
  final String value;
  final String displayName;

  static Subject? fromString(String? v) {
    if (v == null) return null;
    for (final s in Subject.values) {
      if (s.value == v) return s;
    }
    return null;
  }
}
