// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    _RegisterRequestModel(
      username: json['username'] as String,
      password: json['password'] as String,
      displayName: json['display_name'] as String,
      role: json['role'] as String? ?? 'student',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      grade: json['grade'] as String?,
      className: json['class_name'] as String?,
      studentId: json['student_id'] as String?,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        _RegisterRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'display_name': instance.displayName,
      'role': instance.role,
      'email': instance.email,
      'phone': instance.phone,
      'grade': instance.grade,
      'class_name': instance.className,
      'student_id': instance.studentId,
    };
