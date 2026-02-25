import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_button.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../../domain/entities/classroom_session.dart';
import '../../domain/usecases/create_session_usecase.dart';
import '../../domain/usecases/transcribe_session_usecase.dart';

/// 课堂复盘入口：开始复盘（创建会话 → 转写 → 详情）。
class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  bool _isCreating = false;

  void _startReplay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CreateSessionSheet(
        onCreate: _onCreateSession,
        isCreating: _isCreating,
      ),
    );
  }

  Future<void> _onCreateSession({
    required String title,
    required String subject,
    String? audioUrl,
  }) async {
    setState(() => _isCreating = true);
    final create = getIt<CreateSessionUseCase>();
    final result = await create(
      title: title,
      subject: subject,
      audioUrl: audioUrl,
    );
    if (!mounted) return;
    setState(() => _isCreating = false);
    result.fold(
      (failure) {
        setState(() => _isCreating = false);
        JYSnackbar.show(
          context,
          message: failure.message,
          type: SnackbarType.error,
        );
      },
      (session) async {
        Navigator.of(context).pop();
        await _transcribeAndOpen(session);
      },
    );
  }

  Future<void> _transcribeAndOpen(ClassroomSession session) async {
    JYSnackbar.show(
      context,
      message: '正在转写与摘要，请稍候…',
      type: SnackbarType.info,
    );
    final transcribe = getIt<TranscribeSessionUseCase>();
    final result = await transcribe(session.id);
    if (!mounted) return;
    result.fold(
      (failure) {
        if (mounted) setState(() => _isCreating = false);
        JYSnackbar.show(
          context,
          message: failure.message,
          type: SnackbarType.error,
        );
      },
      (updated) {
        if (mounted) setState(() => _isCreating = false);
        context.push('/home/classroom/session/${updated.id}');
      },
    );
  }

  void _onUploadTap() {
    JYSnackbar.show(
      context,
      message: '录音上传需配置存储后使用，当前可先创建会话再查看学案',
      type: SnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('课堂复盘')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.classroom.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusLg,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.class_,
                      size: 48,
                      color: AppColors.classroom,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '上传课堂录音，自动转写并生成摘要与学案',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _onUploadTap,
                icon: const Icon(Icons.mic),
                label: const Text('选择 / 上传录音'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              JYButton(
                label: '开始课堂复盘',
                onPressed: _isCreating ? null : _startReplay,
                isLoading: _isCreating,
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 24),
              Text(
                '说明：填写课程标题与学科后创建会话，系统将进行转写与结构化摘要，并生成个性化学案。',
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

class _CreateSessionSheet extends StatefulWidget {
  const _CreateSessionSheet({
    required this.onCreate,
    required this.isCreating,
  });

  final Future<void> Function({
    required String title,
    required String subject,
    String? audioUrl,
  }) onCreate;
  final bool isCreating;

  @override
  State<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<_CreateSessionSheet> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  String _subject = '数学';

  static const _subjects = [
    '数学',
    '物理',
    '化学',
    '语文',
    '英语',
    '生物',
    '历史',
    '地理',
    '政治',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      JYSnackbar.show(
        context,
        message: '请输入课程标题',
        type: SnackbarType.warning,
      );
      return;
    }
    widget.onCreate(
      title: title,
      subject: _subject,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '新建课堂复盘',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '课程标题',
              hintText: '例如：二次函数复习课',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(
              labelText: '学科',
              border: OutlineInputBorder(),
            ),
            items: _subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _subject = v ?? '数学'),
          ),
          const SizedBox(height: 24),
          JYButton(
            label: '创建并转写',
            onPressed: widget.isCreating ? null : _submit,
            isLoading: widget.isCreating,
          ),
        ],
      ),
    );
  }
}
