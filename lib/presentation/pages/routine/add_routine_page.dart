import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_routine.dart';
import '../../../data/models/dance_element.dart';
import '../../../domain/services/srs_algorithm_service.dart';
import '../../providers/routine_provider.dart';

/// 添加舞段页面
class AddRoutinePage extends ConsumerStatefulWidget {
  const AddRoutinePage({super.key});

  @override
  ConsumerState<AddRoutinePage> createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends ConsumerState<AddRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  // 视频源选择
  VideoSourceType _videoSourceType = VideoSourceType.none;
  String? _videoPath;
  VideoPlayerController? _videoController;
  int _trimStart = 0;
  int _trimEnd = 0;
  int _videoDuration = 0;

  MasteryLevel _masteryLevel = MasteryLevel.new_;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加舞段'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveRoutine,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 舞段名称
            _buildNameField(),
            const SizedBox(height: 16),

            // 分类
            _buildCategoryField(),
            const SizedBox(height: 24),

            // 视频源选择
            _buildVideoSourceTypeSelector(),
            const SizedBox(height: 16),

            // 视频选择区域
            if (_videoSourceType == VideoSourceType.localGallery)
              _buildVideoSection(),
            if (_videoSourceType == VideoSourceType.localGallery && _videoPath != null)
              const SizedBox(height: 16),
            if (_videoSourceType == VideoSourceType.localGallery && _videoPath != null)
              _buildTrimSection(),
            if (_videoSourceType == VideoSourceType.localGallery && _videoPath != null)
              const SizedBox(height: 24),

            // 初始熟练度
            _buildMasterySection(),
            const SizedBox(height: 24),

            // 备注
            _buildNotesField(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 名称输入
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '舞段名称 *',
        hintText: '例如: 基础步伐组合',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入舞段名称';
        }
        return null;
      },
    );
  }

  /// 分类输入
  Widget _buildCategoryField() {
    return TextFormField(
      controller: _categoryController,
      decoration: const InputDecoration(
        labelText: '分类 *',
        hintText: '例如: Popping',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入分类';
        }
        return null;
      },
    );
  }

  /// 视频源类型选择
  Widget _buildVideoSourceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '视频源',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _VideoSourceOption(
                icon: Icons.videocam_off_outlined,
                label: '无视频',
                isSelected: _videoSourceType == VideoSourceType.none,
                onTap: () => setState(() => _videoSourceType = VideoSourceType.none),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _VideoSourceOption(
                icon: Icons.video_library_outlined,
                label: '相册',
                isSelected: _videoSourceType == VideoSourceType.localGallery,
                onTap: () => setState(() => _videoSourceType = VideoSourceType.localGallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 视频选择区域
  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: _videoController != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击选择视频',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_videoPath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '已选择视频',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _pickVideo,
                  child: const Text('重新选择'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 裁剪控制
  Widget _buildTrimSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '视频裁剪',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Text(
              '开始: ${_formatDuration(_trimStart)}',
              style: AppTextStyles.bodySmall,
            ),
            const Spacer(),
            Text(
              '结束: ${_formatDuration(_trimEnd)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),

        RangeSlider(
          values: RangeValues(
            _trimStart.toDouble(),
            _trimEnd.toDouble(),
          ),
          min: 0,
          max: _videoDuration.toDouble(),
          onChanged: (values) {
            setState(() {
              _trimStart = values.start.round();
              _trimEnd = values.end.round();
            });
          },
        ),

        Center(
          child: TextButton.icon(
            onPressed: _previewTrim,
            icon: const Icon(Icons.play_arrow),
            label: const Text('预览裁剪片段'),
          ),
        ),
      ],
    );
  }

  /// 初始熟练度选择
  Widget _buildMasterySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '初始熟练度',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            children: MasteryLevel.values.map((level) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: level != MasteryLevel.mastered ? 8 : 0,
                  ),
                  child: _MasteryCard(
                    level: level,
                    isSelected: _masteryLevel == level,
                    onTap: () => setState(() => _masteryLevel = level),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 备注输入
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: '备注（可选）',
        hintText: '添加备注信息...',
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  /// 选择视频
  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        await _videoController?.dispose();

        _videoPath = video.path;
        _videoController = VideoPlayerController.file(File(_videoPath!));
        await _videoController!.initialize();

        _videoDuration = _videoController!.value.duration.inMilliseconds;
        _trimStart = 0;
        _trimEnd = _videoDuration;

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择视频失败: $e')),
        );
      }
    }
  }

  /// 预览裁剪片段
  void _previewTrim() {
    if (_videoController == null) return;

    _videoController!.seekTo(Duration(milliseconds: _trimStart));
    _videoController!.play();

    _videoController!.addListener(() {
      if (_videoController!.value.position.inMilliseconds >= _trimEnd) {
        _videoController!.pause();
        _videoController!.seekTo(Duration(milliseconds: _trimStart));
      }
    });
  }

  /// 保存舞段
  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    // 验证视频源
    if (_videoSourceType == VideoSourceType.localGallery && _videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择视频或更改为"无视频"')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final srsAlgorithm = SrsAlgorithmService();
      final initialMastery = srsAlgorithm.getInitialMasteryLevel(_masteryLevel);
      final now = DateTime.now().millisecondsSinceEpoch;

      String videoUri;
      switch (_videoSourceType) {
        case VideoSourceType.localGallery:
          videoUri = _videoPath!;
          break;
        case VideoSourceType.webUrl:
        case VideoSourceType.bundledAsset:
        case VideoSourceType.none:
          videoUri = '';
          break;
      }

      final routine = DanceRoutine(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        videoSourceType: _videoSourceType,
        videoUri: videoUri,
        trimStart: _trimStart,
        trimEnd: _trimEnd,
        status: RoutineStatus.new_,
        masteryLevel: initialMastery,
        lastPracticedAt: now,
        createdAt: now,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await ref.read(routineNotifierProvider.notifier).addRoutine(routine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('舞段已添加')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// 格式化时长
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 视频源选项卡片
class _VideoSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VideoSourceOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 熟练度卡片
class _MasteryCard extends StatelessWidget {
  final MasteryLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _MasteryCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (level) {
      case MasteryLevel.new_:
        return '新手';
      case MasteryLevel.learning:
        return '学习中';
      case MasteryLevel.mastered:
        return '已掌握';
    }
  }

  String get _description {
    switch (level) {
      case MasteryLevel.new_:
        return '熟练度: 0';
      case MasteryLevel.learning:
        return '熟练度: 30';
      case MasteryLevel.mastered:
        return '熟练度: 70';
    }
  }

  Color get _color {
    switch (level) {
      case MasteryLevel.new_:
        return AppColors.warning;
      case MasteryLevel.learning:
        return AppColors.info;
      case MasteryLevel.mastered:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _color : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? _color : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _description,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
