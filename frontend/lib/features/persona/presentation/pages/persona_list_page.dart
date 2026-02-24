import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/jy_empty_state.dart';
import '../../../../core/widgets/jy_error_widget.dart';
import '../../../../core/widgets/jy_loading.dart';
import '../../../../core/widgets/jy_snackbar.dart';
import '../../../../injection.dart';
import '../bloc/persona_bloc.dart';
import '../bloc/persona_event.dart';
import '../bloc/persona_state.dart';
import '../widgets/persona_card.dart';
import '../widgets/persona_detail_sheet.dart';

class PersonaListPage extends StatelessWidget {
  const PersonaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PersonaBloc>()..add(const PersonaEvent.load()),
      child: const _PersonaListView(),
    );
  }
}

class _PersonaListView extends StatelessWidget {
  const _PersonaListView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonaBloc, PersonaState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage &&
          curr.successMessage != null,
      listener: (context, state) {
        if (state.successMessage != null) {
          JYSnackbar.show(
            context,
            message: state.successMessage!,
            type: SnackbarType.success,
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.personas.isEmpty) {
          return const JYLoading(message: '加载学伴...');
        }

        if (state.errorMessage != null && state.personas.isEmpty) {
          return JYErrorWidget(
            message: state.errorMessage!,
            onRetry: () => context
                .read<PersonaBloc>()
                .add(const PersonaEvent.load()),
          );
        }

        if (state.personas.isEmpty) {
          return const JYEmptyState(
            message: '暂无可用的学伴',
            icon: Icons.people_outline,
          );
        }

        final boundIds = state.bindings.map((b) => b.personaId).toSet();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: state.personas.length,
          itemBuilder: (context, index) {
            final persona = state.personas[index];
            final isBound = boundIds.contains(persona.id);

            return PersonaCard(
              persona: persona,
              isBound: isBound,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => BlocProvider.value(
                  value: context.read<PersonaBloc>(),
                  child: PersonaDetailSheet(
                    persona: persona,
                    isBound: isBound,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
