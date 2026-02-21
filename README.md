# Wooho 舞乎

<p align="center">
  <b>街舞学习应用</b><br>
  结合间隔重复系统 (SRS) 与随机串联训练
</p>

---

## 简介

**Wooho** 是一款专为街舞舞者设计的智能练习应用，解决舞者在自主练习时"缺乏计划"和"只会做单动作、不会连接"的痛点。

### 核心价值

- **智能排序** - 基于遗忘曲线和熟练度，每次训练自动选择最需要练习的动作
- **强制连接** - 在复习完单动作后，进入随机串联模式进行肌肉记忆训练
- **轻量化** - 视频引用本地相册，不占用 App 存储空间

---

## 功能特性

### 动作库管理
- 官方动作库：按舞种分类的预设动作
- 自定义动作：从相册导入视频，支持裁剪起止时间
- 熟练度标记：设置动作的初始掌握程度

### 智能训练
- **优先级算法**：结合遗忘曲线 + 熟练度计算练习优先级
- **单动作复习**：逐个播放动作视频，练习后打分更新熟练度
- **串联训练**：随机播放动作列表，配合节拍器进行连接练习

### 音频引擎
- 节拍器：支持 60-130 BPM 调节
- 多音频选择：可切换不同的鼓点音频
- 后台播放：支持锁屏/后台运行

---

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.10+ |
| 状态管理 | Riverpod |
| 本地存储 | SQLite (sqflite) |
| 视频播放 | video_player |
| 音频引擎 | just_audio |
| 路由 | go_router |
| UI 动画 | flutter_animate |

---

## 项目结构

```
lib/
├── core/
│   ├── constants/          # 常量定义
│   ├── router/             # 路由配置
│   └── services/           # 核心服务
├── data/
│   ├── datasources/        # 数据源
│   ├── models/             # 数据模型
│   └── repositories/       # 数据仓库
├── domain/
│   └── services/           # 业务逻辑服务
├── presentation/
│   ├── pages/
│   │   ├── drill/          # 串联训练页
│   │   ├── home/           # 首页
│   │   ├── library/        # 动作库
│   │   ├── onboarding/     # 引导页
│   │   ├── review/         # 复习页
│   │   └── settings/       # 设置页
│   ├── providers/          # 状态管理
│   └── widgets/            # 通用组件
├── services/
│   └── audio/              # 音频引擎
└── main.dart
```

---

## 快速开始

### 环境要求

- Flutter SDK 3.10.7 或更高版本
- Dart SDK 3.10.7 或更高版本

### 安装

```bash
# 克隆项目
git clone https://github.com/ckd0817/wooho.git
cd wooho

# 安装依赖
flutter pub get

# 运行项目
flutter run
```

### 构建发布版

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 用户流程

1. **初始化** - 首次使用时选择舞蹈风格
2. **添加动作** - 从官方库添加或导入自定义视频
3. **开始训练** - 系统自动选择最需要练习的动作
4. **单动作复习** - 观看视频、练习、打分
5. **串联训练** - 跟随节拍进行连接练习
6. **完成打卡** - 查看训练统计

---

## 许可证

MIT License
