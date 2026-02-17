import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  double _bgmVolume = 0.7;
  double _ttsSpeed = 0.5;
  int _defaultBpm = 100;
  bool _enableTts = true;
  bool _enableBackgroundPlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 音频设置
          _buildSectionHeader('音频设置'),
          _buildSettingsCard([
            _buildSliderSetting(
              icon: Icons.music_note_outlined,
              title: '背景音乐音量',
              value: _bgmVolume,
              onChanged: (value) => setState(() => _bgmVolume = value),
            ),
            _buildDivider(),
            _buildSliderSetting(
              icon: Icons.record_voice_over_outlined,
              title: 'TTS 语速',
              value: _ttsSpeed,
              min: 0.2,
              max: 1.0,
              onChanged: (value) => setState(() => _ttsSpeed = value),
            ),
          ]),

          const SizedBox(height: 24),

          // 训练设置
          _buildSectionHeader('训练设置'),
          _buildSettingsCard([
            _buildSliderSetting(
              icon: Icons.speed_outlined,
              title: '默认 BPM',
              value: (_defaultBpm - AppConstants.minBpm) /
                  (AppConstants.maxBpm - AppConstants.minBpm),
              label: _defaultBpm.round().toString(),
              onChanged: (value) {
                setState(() {
                  _defaultBpm =
                      (value * (AppConstants.maxBpm - AppConstants.minBpm) +
                              AppConstants.minBpm)
                          .round();
                });
              },
            ),
            _buildDivider(),
            _buildSwitchSetting(
              icon: Icons.record_voice_over_outlined,
              title: '启用语音提示',
              subtitle: '训练时朗读动作名称',
              value: _enableTts,
              onChanged: (value) => setState(() => _enableTts = value),
            ),
            _buildDivider(),
            _buildSwitchSetting(
              icon: Icons.music_video_outlined,
              title: '后台播放',
              subtitle: '锁屏后继续播放音频',
              value: _enableBackgroundPlay,
              onChanged: (value) => setState(() => _enableBackgroundPlay = value),
            ),
          ]),

          const SizedBox(height: 24),

          // 关于
          _buildSectionHeader('关于'),
          _buildSettingsCard([
            _buildInfoSetting(
              icon: Icons.info_outline,
              title: '版本',
              value: '1.0.0',
            ),
            _buildDivider(),
            _buildNavigationSetting(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              onTap: () {
                // TODO: 打开隐私政策页面
              },
            ),
            _buildDivider(),
            _buildNavigationSetting(
              icon: Icons.description_outlined,
              title: '使用条款',
              onTap: () {
                // TODO: 打开使用条款页面
              },
            ),
          ]),

          const SizedBox(height: 32),

          // 反馈
          _buildSettingsCard([
            _buildNavigationSetting(
              icon: Icons.feedback_outlined,
              title: '反馈建议',
              onTap: () {
                // TODO: 打开反馈页面
              },
            ),
            _buildDivider(),
            _buildNavigationSetting(
              icon: Icons.star_outline,
              title: '给应用评分',
              onTap: () {
                // TODO: 打开应用商店
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// 构建分类标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textHint,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建设置卡片
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: AppColors.surfaceLight,
    );
  }

  /// 构建滑动设置项
  Widget _buildSliderSetting({
    required IconData icon,
    required String title,
    required double value,
    String? label,
    double min = 0.0,
    double max = 1.0,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    onChanged: onChanged,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceLight,
                  ),
                ),
              ],
            ),
          ),
          if (label != null)
            SizedBox(
              width: 50,
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建开关设置项
  Widget _buildSwitchSetting({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// 构建信息设置项
  Widget _buildInfoSetting({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// 构建导航设置项
  Widget _buildNavigationSetting({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.body)),
            Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
