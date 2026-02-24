class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = '此字段']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 2) {
      return '用户名至少2个字符';
    }
    if (value.length > 50) {
      return '用户名不能超过50个字符';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6个字符';
    }
    if (value.length > 128) {
      return '密码不能超过128个字符';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入显示名称';
    }
    if (value.length > 100) {
      return '显示名称不能超过100个字符';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[\w\-.]+@[\w\-.]+\.\w+$');
    if (!regex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^1[3-9]\d{9}$');
    if (!regex.hasMatch(value)) {
      return '请输入有效的手机号码';
    }
    return null;
  }
}
