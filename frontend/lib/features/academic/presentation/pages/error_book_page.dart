import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../../domain/entities/subject.dart';
import '../bloc/error_book_bloc.dart';
import '../bloc/error_book_event.dart';
import '../bloc/error_book_state.dart';
import '../widgets/error_record_tile.dart';

/// 错题本页面：列表、学科筛选、查看错因、标记复习。
class ErrorBookPage extends StatelessWidget {
  const ErrorBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ErrorBookBloc>()
        ..add(const ErrorBookLoadEvent(subject: null)),
      child: const _ErrorBookView(),
    );
  }
}

class _ErrorBookView extends StatelessWidget {
  const _ErrorBookView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        actions: [
          PopupMenuButton<Subject?>(
            icon: const Icon(Icons.filter_list),
            tooltip: '按学科筛选',
            onSelected: (v) => context
                .read<ErrorBookBloc>()
                .add(ErrorBookLoadEvent(subject: v)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('全部学科'),
              ),
              ...Subject.values
                  .map((s) => PopupMenuItem(value: s, child: Text(s.displayName))),
            ],
          ),
        ],
      ),
      body: BlocListener<ErrorBookBloc, ErrorBookState>(
        listenWhen: (prev, curr) =>
            curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            JYSnackbar.show(
              context,
              message: state.errorMessage!,
              type: SnackbarType.error,
            );
          }
        },
        child: BlocBuilder<ErrorBookBloc, ErrorBookState>(
        builder: (context, state) {
          if (state.isLoading && state.errors.isEmpty) {
            return const JYLoading(message: '加载错题本...');
          }
          if (state.errorMessage != null && state.errors.isEmpty) {
            return JYErrorWidget(
              message: state.errorMessage!,
              onRetry: () => context
                  .read<ErrorBookBloc>()
                  .add(ErrorBookLoadEvent(subject: state.currentSubject)),
            );
          }
          if (state.errors.isEmpty) {
            return JYEmptyState(
              message: '暂无错题记录',
              icon: Icons.book_outlined,
              actionLabel: '去学业辅导',
              action: () => Navigator.of(context).pop(),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ErrorBookBloc>()
                  .add(ErrorBookLoadEvent(subject: state.currentSubject));
            },
            child: ListView.separated(
              padding: AppSpacing.paddingMd,
              itemCount: state.errors.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = state.errors[index];
                return ErrorRecordTile(
                  record: record,
                  onReview: () => context
                      .read<ErrorBookBloc>()
                      .add(ErrorBookReviewEvent(record.id)),
                );
              },
            ),
          );
        },
        ),
      ),
    );
  }
}
