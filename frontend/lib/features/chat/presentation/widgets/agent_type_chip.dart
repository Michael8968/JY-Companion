import 'package:flutter/material.dart';

import '../../domain/enums/agent_type.dart';

class AgentTypeChip extends StatelessWidget {
  const AgentTypeChip({super.key, required this.agentType});

  final AgentType agentType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: agentType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(agentType.icon, size: 14, color: agentType.color),
          const SizedBox(width: 4),
          Text(
            agentType.displayName,
            style: TextStyle(
              fontSize: 12,
              color: agentType.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
