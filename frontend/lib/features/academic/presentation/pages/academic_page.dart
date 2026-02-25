import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_button.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../core/widgets/jy_text_field.dart';
import '../../../../injection.dart';
import '../../domain/entities/subject.dart';
import '../../../chat/domain/usecases/create_conversation_usecase.dart';

/// 学业辅导页面：题目输入（文本 + 拍照占位）、跳转分步解答对话、错题本入口。
class AcademicPage extends StatefulWidget {
  const AcademicPage({super.key});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
  final _questionController = TextEditingController();
  Subject _subject = Subject.math;
  bool _isCreating = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _startTutoring() async {
    final question = _questionController.text.trim();
    setState(() => _isCreating = true);
    final createConversation = getIt<CreateConversationUseCase>();
    final result = await createConversation(
      agentType: 'academic',
      personaId: null,
      title: question.isEmpty
          ? '学业辅导'
          : question.length > 20
              ? '${question.substring(0, 20)}…'
              : question,
    );
    if (!mounted) return;
    setState(() => _isCreating = false);
    result.fold(
      (failure) => JYSnackbar.show(
        context,
        message: failure.message,
        type: SnackbarType.error,
      ),
      (conversation) {
        context.push('/chat/${conversation.id}');
        if (question.isNotEmpty) {
          // 用户进入对话后可手动发送首条题目，或后续由前端支持首条消息
        }
      },
    );
  }

  void _onPhotoTap() {
    JYSnackbar.show(
      context,
      message: '拍照识别功能敬请期待',
      type: SnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学业辅导'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/home/academic/error-book'),
            icon: const Icon(Icons.book, size: 20),
            label: const Text('错题本'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '输入题目',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: JYTextField(
                      label: '题目内容（支持文字输入）',
                      controller: _questionController,
                      hint: '输入或粘贴题目，开始获得分步解答',
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _onPhotoTap,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                    ),
                    tooltip: '拍照识别',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Subject>(
                value: _subject,
                decoration: const InputDecoration(
                  labelText: '学科',
                  border: OutlineInputBorder(),
                ),
                items: Subject.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _subject = v ?? Subject.math),
              ),
              const SizedBox(height: 24),
              JYButton(
                label: '开始解答',
                onPressed: _isCreating ? null : _startTutoring,
                isLoading: _isCreating,
                icon: Icons.auto_stories,
              ),
              const SizedBox(height: 24),
              Text(
                '说明：点击「开始解答」将进入学业辅导对话，AI 将为你提供分步讲解。错题可自动收录到错题本。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
