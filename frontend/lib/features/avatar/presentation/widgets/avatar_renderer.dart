import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../../../core/theme/app_colors.dart';

/// 数字形象渲染器（Rive 集成）。
/// 加载 [assetPath] 指定的 .riv 文件，可选 [stateMachineName] / [artboardName]。
/// 加载成功后通过 [onControllerReady] 回调暴露 [RiveWidgetController]，便于外部驱动状态机输入。
/// 若资源不存在或加载失败，显示占位占位图（待任务 9.5 提供预设 .riv 后即可正常显示）。
class AvatarRenderer extends StatefulWidget {
  const AvatarRenderer({
    super.key,
    this.assetPath = 'assets/animations/avatar/companion.riv',
    this.stateMachineName,
    this.artboardName,
    this.fit = BoxFit.contain,
    this.onControllerReady,
    this.placeholderSize = 120,
  });

  /// Rive 资源路径（默认 companion.riv，需在 9.5 中提供）
  final String assetPath;
  /// 状态机名称，null 表示使用默认
  final String? stateMachineName;
  /// Artboard 名称，null 表示使用默认
  final String? artboardName;
  final BoxFit fit;
  /// 控制器就绪回调，可在此驱动 Number/Boolean/Trigger 输入
  final void Function(RiveWidgetController controller)? onControllerReady;
  /// 加载失败时占位区域大小
  final double placeholderSize;

  @override
  State<AvatarRenderer> createState() => _AvatarRendererState();
}

class _AvatarRendererState extends State<AvatarRenderer> {
  late final FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      widget.assetPath,
      riveFactory: Factory.flutter,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  Controller _buildController(File file) {
    return RiveWidgetController(
      file,
      artboardSelector: widget.artboardName != null
          ? ArtboardSelector.byName(widget.artboardName!)
          : const ArtboardDefault(),
      stateMachineSelector: widget.stateMachineName != null
          ? StateMachineSelector.byName(widget.stateMachineName!)
          : const StateMachineDefault(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      controller: _buildController,
      builder: (context, state) {
        return switch (state) {
          RiveLoading() => _buildPlaceholder(isLoading: true),
          RiveFailed() => _buildPlaceholder(isLoading: false),
          RiveLoaded() => _onLoaded(state),
        };
      },
    );
  }

  Widget _onLoaded(RiveLoaded state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onControllerReady?.call(state.controller);
    });
    return RiveWidget(
      controller: state.controller,
      fit: widget.fit,
    );
  }

  Widget _buildPlaceholder({required bool isLoading}) {
    return SizedBox(
      width: widget.placeholderSize,
      height: widget.placeholderSize,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.face_6_outlined,
                size: widget.placeholderSize * 0.6,
                color: AppColors.textHint,
              ),
      ),
    );
  }
}
