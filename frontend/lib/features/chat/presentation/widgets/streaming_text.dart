import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jy_avatar.dart';

class StreamingText extends StatefulWidget {
  const StreamingText({super.key, required this.text});

  final String text;

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const JYAvatar(name: 'AI', radius: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.assistantBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: widget.text.isEmpty
                ? _buildTypingIndicator()
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.text,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.assistantBubbleText,
                            height: 1.5,
                          ),
                        ),
                        WidgetSpan(
                          child: AnimatedBuilder(
                            animation: _cursorController,
                            builder: (_, __) => Opacity(
                              opacity: _cursorController.value,
                              child: const Text(
                                '\u258b',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _cursorController,
          builder: (_, __) {
            final delay = index * 0.2;
            final value =
                ((_cursorController.value + delay) % 1.0).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.3 + value * 0.7),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
