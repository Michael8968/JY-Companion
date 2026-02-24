import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/jy_button.dart';
import '../../../../core/widgets/jy_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'role_selector.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gradeController = TextEditingController();
  final _classNameController = TextEditingController();
  final _studentIdController = TextEditingController();

  String _selectedRole = 'student';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gradeController.dispose();
    _classNameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthEvent.registerRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
              displayName: _displayNameController.text.trim(),
              role: _selectedRole,
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              grade: _gradeController.text.trim().isEmpty
                  ? null
                  : _gradeController.text.trim(),
              className: _classNameController.text.trim().isEmpty
                  ? null
                  : _classNameController.text.trim(),
              studentId: _studentIdController.text.trim().isEmpty
                  ? null
                  : _studentIdController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Form(
          key: _formKey,
          child: Column(
            children: [
              JYTextField(
                label: '用户名',
                controller: _usernameController,
                hint: '2-50个字符',
                validator: Validators.username,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              JYTextField(
                label: '显示名称',
                controller: _displayNameController,
                hint: '你在平台上显示的名称',
                validator: Validators.displayName,
                prefixIcon: const Icon(Icons.badge_outlined),
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              JYTextField(
                label: '密码',
                controller: _passwordController,
                hint: '至少6个字符',
                validator: Validators.password,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              JYTextField(
                label: '确认密码',
                controller: _confirmPasswordController,
                hint: '再次输入密码',
                validator: (value) => Validators.confirmPassword(
                  value,
                  _passwordController.text,
                ),
                obscureText: _obscureConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () =>
                        _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              RoleSelector(
                selectedRole: _selectedRole,
                onChanged: isLoading
                    ? null
                    : (role) => setState(() => _selectedRole = role),
              ),
              const SizedBox(height: 16),
              // Student-specific fields
              if (_selectedRole == 'student') ...[
                JYTextField(
                  label: '年级',
                  controller: _gradeController,
                  hint: '例如：高二',
                  prefixIcon: const Icon(Icons.school_outlined),
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                JYTextField(
                  label: '班级',
                  controller: _classNameController,
                  hint: '例如：3班',
                  prefixIcon: const Icon(Icons.class_outlined),
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                JYTextField(
                  label: '学号',
                  controller: _studentIdController,
                  hint: '选填',
                  prefixIcon: const Icon(Icons.numbers),
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
              ],
              JYTextField(
                label: '邮箱',
                controller: _emailController,
                hint: '选填',
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              JYTextField(
                label: '手机号',
                controller: _phoneController,
                hint: '选填',
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                enabled: !isLoading,
              ),
              const SizedBox(height: 32),
              JYButton(
                label: '注册',
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
