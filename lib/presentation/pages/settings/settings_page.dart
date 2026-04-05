import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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
          // 训练设置
          _buildSectionHeader('训练设置'),
          _buildSettingsCard([
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
