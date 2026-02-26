import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/avatar_preset.dart';
import '../widgets/avatar_preview_card.dart';
import '../widgets/avatar_renderer.dart';

/// 学伴数字形象选择页面。
/// 展示 2-3 个预设形象供用户选择，选中后可在大预览区查看动画效果。
class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key, this.currentPresetId});

  /// 当前已选的形象 id，null 表示未选择
  final String? currentPresetId;

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId =
        widget.currentPresetId ?? AvatarPreset.defaultPreset.id;
  }

  AvatarPreset get _selectedPreset =>
      AvatarPreset.findById(_selectedId) ?? AvatarPreset.defaultPreset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择学伴形象')),
      body: Column(
        children: [
          // ── 大预览区 ──
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (_selectedPreset.themeColor != null
                            ? Color(_selectedPreset.themeColor!)
                            : AppColors.primary)
                        .withValues(alpha: 0.08),
                    AppColors.background,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AvatarRenderer(
                      key: ValueKey(_selectedId),
                      assetPath: _selectedPreset.assetPath,
                      stateMachineName: _selectedPreset.stateMachineName,
                      artboardName: _selectedPreset.artboardName,
                      placeholderSize: 200,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedPreset.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedPreset.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // ── 形象选择网格 ──
          Expanded(
            flex: 2,
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AvatarPreset.all.length,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: AvatarPreset.all.length,
                itemBuilder: (context, index) {
                  final preset = AvatarPreset.all[index];
                  return AvatarPreviewCard(
                    preset: preset,
                    isSelected: preset.id == _selectedId,
                    onTap: () => setState(() => _selectedId = preset.id),
                  );
                },
              ),
            ),
          ),

          // ── 确认按钮 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selectedId),
                child: const Text('确认选择'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
