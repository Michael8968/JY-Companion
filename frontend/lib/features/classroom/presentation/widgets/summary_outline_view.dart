import 'package:flutter/material.dart';


/// 摘要大纲视图：树形/列表展示 summary_outline。
class SummaryOutlineView extends StatelessWidget {
  const SummaryOutlineView({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return _buildMap(context, data, 0);
  }

  Widget _buildMap(
    BuildContext context,
    Map<String, dynamic> map,
    int level,
  ) {
    final children = <Widget>[];
    for (final e in map.entries) {
      if (e.value == null) continue;
      if (e.value is Map<String, dynamic>) {
        children.add(
          Padding(
            padding: EdgeInsets.only(left: (level + 1) * 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.key,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                _buildMap(context, e.value as Map<String, dynamic>, level + 1),
              ],
            ),
          ),
        );
      } else if (e.value is List) {
        children.add(
          Padding(
            padding: EdgeInsets.only(left: (level + 1) * 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.key,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                _buildList(context, e.value as List, level + 1),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: EdgeInsets.only(left: (level + 1) * 16.0),
            child: Text(
              '${e.key}: ${e.value}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 8));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildList(BuildContext context, List list, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.asMap().entries.map((entry) {
        final i = entry.key;
        final v = entry.value;
        if (v is Map<String, dynamic>) {
          return Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: _buildMap(context, v, level + 1),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text(
            '${i + 1}. $v',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}
