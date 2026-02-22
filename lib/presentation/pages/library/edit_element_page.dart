import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_element.dart';
import '../../providers/user_elements_provider.dart';

/// 编辑元素页面
class EditElementPage extends ConsumerStatefulWidget {
  final String elementId;

  const EditElementPage({super.key, required this.elementId});

  @override
  ConsumerState<EditElementPage> createState() => _EditElementPageState();
}

class _EditElementPageState extends ConsumerState<EditElementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _urlController = TextEditingController();

  // 视频源选择
  VideoSourceType _videoSourceType = VideoSourceType.none;
  String? _videoPath;
  VideoPlayerController? _videoController;
  int _trimStart = 0;
  int _trimEnd = 0;
  int _videoDuration = 0;

  // 熟练度
  int _masteryLevel = 0;

  bool _isSaving = false;
  bool _isLoading = true;
  DanceElement? _originalElement;

  @override
  void initState() {
    super.initState();
    _loadElement();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _urlController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  /// 加载元素数据
  Future<void> _loadElement() async {
    final element = await ref.read(elementByIdProvider(widget.elementId).future);
    if (element != null && mounted) {
      _originalElement = element;
      _nameController.text = element.name;
      _categoryController.text = element.category;
      _videoSourceType = element.videoSourceType;
      _trimStart = element.trimStart;
      _trimEnd = element.trimEnd;
      _masteryLevel = element.masteryLevel;

      if (element.videoSourceType == VideoSourceType.webUrl) {
        _urlController.text = element.videoUri;
      } else if (element.videoSourceType == VideoSourceType.localGallery) {
        _videoPath = element.videoUri;
        _loadVideoController(element.videoUri);
      }

      setState(() => _isLoading = false);
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('元素不存在')),
      );
      context.pop();
    }
  }

  /// 加载视频控制器
  Future<void> _loadVideoController(String path) async {
    try {
      _videoController = VideoPlayerController.file(File(path));
      await _videoController!.initialize();
      _videoDuration = _videoController!.value.duration.inMilliseconds;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('加载视频失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('编辑元素')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑元素'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveElement,
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
            // 元素名称
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
            if (_videoSourceType == VideoSourceType.webUrl)
              _buildUrlSection(),
            if (_videoSourceType == VideoSourceType.localGallery && _videoPath != null)
              const SizedBox(height: 16),
            if (_videoSourceType == VideoSourceType.localGallery && _videoPath != null)
              _buildTrimSection(),
            const SizedBox(height: 24),

            // 熟练度
            _buildMasterySection(),
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
        labelText: '元素名称 *',
        hintText: '例如: Walk Out',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入元素名称';
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
            const SizedBox(width: 8),
            Expanded(
              child: _VideoSourceOption(
                icon: Icons.link,
                label: '链接',
                isSelected: _videoSourceType == VideoSourceType.webUrl,
                onTap: () => setState(() => _videoSourceType = VideoSourceType.webUrl),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// URL 输入区域
  Widget _buildUrlSection() {
    return TextFormField(
      controller: _urlController,
      decoration: const InputDecoration(
        labelText: '视频链接',
        hintText: '粘贴 YouTube 或其他视频链接',
        prefixIcon: Icon(Icons.link),
      ),
      keyboardType: TextInputType.url,
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

        // 开始时间
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

        // 预览按钮
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

  /// 熟练度选择
  Widget _buildMasterySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '熟练度',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$_masteryLevel%',
              style: AppTextStyles.heading3.copyWith(
                color: _getMasteryColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _masteryLevel.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: _getMasteryColor(),
          onChanged: (value) {
            setState(() => _masteryLevel = value.round());
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '新手',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
            Text(
              '已掌握',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ],
    );
  }

  Color _getMasteryColor() {
    if (_masteryLevel < 30) {
      return AppColors.warning;
    } else if (_masteryLevel < 70) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }

  /// 选择视频
  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        // 释放旧的控制器
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

    // 在到达结束时间时暂停
    _videoController!.addListener(() {
      if (_videoController!.value.position.inMilliseconds >= _trimEnd) {
        _videoController!.pause();
        _videoController!.seekTo(Duration(milliseconds: _trimStart));
      }
    });
  }

  /// 保存元素
  Future<void> _saveElement() async {
    if (!_formKey.currentState!.validate()) return;

    // 验证视频源
    if (_videoSourceType == VideoSourceType.localGallery && _videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择视频或更改为"无视频"')),
      );
      return;
    }

    if (_videoSourceType == VideoSourceType.webUrl && _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入视频链接或更改为"无视频"')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      String videoUri;
      switch (_videoSourceType) {
        case VideoSourceType.localGallery:
          videoUri = _videoPath!;
          break;
        case VideoSourceType.webUrl:
          videoUri = _urlController.text.trim();
          break;
        case VideoSourceType.bundledAsset:
        case VideoSourceType.none:
          videoUri = '';
          break;
      }

      // 根据熟练度计算状态
      final newStatus = _masteryLevel < 30
          ? ElementStatus.new_
          : _masteryLevel < 70
              ? ElementStatus.learning
              : ElementStatus.reviewing;

      final updatedElement = _originalElement!.copyWith(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        videoSourceType: _videoSourceType,
        videoUri: videoUri,
        trimStart: _trimStart,
        trimEnd: _trimEnd,
        masteryLevel: _masteryLevel,
        status: newStatus,
        updatedAt: now,
      );

      await ref.read(danceElementsNotifierProvider.notifier).updateElement(updatedElement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('元素已更新')),
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
