/// 用户摘要（管理后台）
class UserSummary {
  const UserSummary({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return '管理员';
      case 'teacher':
        return '教师';
      case 'parent':
        return '家长';
      case 'student':
        return '学生';
      default:
        return role;
    }
  }

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    final isActive = json['is_active'] as bool? ??
        ((json['status'] as String?) == 'active');
    return UserSummary(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String? ?? 'student',
      isActive: isActive,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          role == other.role &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, username, role, isActive, createdAt);
}
