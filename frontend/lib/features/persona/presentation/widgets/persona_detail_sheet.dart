import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jy_avatar.dart';
import '../../../../core/widgets/jy_button.dart';
import '../../domain/entities/persona.dart';
import '../bloc/persona_bloc.dart';
import '../bloc/persona_event.dart';
import '../bloc/persona_state.dart';

class PersonaDetailSheet extends StatelessWidget {
  const PersonaDetailSheet({
    super.key,
    required this.persona,
    required this.isBound,
  });

  final Persona persona;
  final bool isBound;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              JYAvatar(
                imageUrl: persona.avatarUrl,
                name: persona.displayName,
                radius: 40,
              ),
              const SizedBox(height: 16),
              Text(
                persona.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (persona.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  persona.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _buildTraitRow(context, '语言风格', persona.speakingStyle),
              _buildTraitRow(context, '语气', persona.tone),
              _buildTraitRow(context, '口头禅', persona.catchphrase),
              _buildTraitRow(context, '幽默度', persona.humorLevel),
              _buildTraitRow(context, '共情力', persona.empathyLevel),
              _buildTraitRow(context, '回复长度', persona.responseLength),
              _buildTraitRow(context, '鼓励方式', persona.encouragementStyle),
              _buildTraitRow(context, '教学方法', persona.teachingApproach),
              const SizedBox(height: 32),
              BlocBuilder<PersonaBloc, PersonaState>(
                builder: (context, state) {
                  if (isBound) {
                    return JYButton(
                      label: '已绑定',
                      onPressed: null,
                      style: JYButtonStyle.secondary,
                    );
                  }
                  return JYButton(
                    label: '绑定此学伴',
                    onPressed: () {
                      context.read<PersonaBloc>().add(
                            PersonaEvent.bind(personaId: persona.id),
                          );
                      Navigator.pop(context);
                    },
                    isLoading: state.isBinding,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTraitRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
