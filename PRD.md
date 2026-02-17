# Product Requirements Document (PRD): DanceLoop SRS

## 1. 项目概述 (Project Overview)
**DanceLoop SRS** 是一款结合了 **艾宾浩斯遗忘曲线 (Spaced Repetition System)** 与 **随机串联训练 (Random Flow Drill)** 的街舞学习应用。
核心目标是解决舞者在自主练习时“缺乏计划”和“只会做单动作、不会连接”的痛点。

### 1.1 核心价值
1.  **科学复习：** 算法自动安排每日需要复习的基础动作。
2.  **强制连接：** 在复习完单动作后，强制进入随机串联模式，利用语音喊拍进行肌肉记忆训练。
3.  **轻量化：** 视频引用本地相册，不占用 App 存储空间。

---

## 2. 用户流程 (User Flow)

1.  **初始化/录入：** 用户从官方库添加动作，或录入自定义动作（引用本地视频 + 设定起止时间 + 设定初始熟练度）。
2.  **每日首页：** 显示“今日待办 (Due Today)” 数量。点击“开始训练”。
3.  **阶段一：单动作复习 (Review Phase)：**
    *   逐个播放动作视频片段。
    *   用户练习后打分（模糊/认识/熟练）。
    *   算法更新下次复习时间。
4.  **阶段二：串联训练 (Drill Phase) [强制]：**
    *   系统基于今日复习的动作生成随机播放列表。
    *   用户设定 BPM（速度）。
    *   App 播放鼓点 + TTS 语音喊出动作名字。
    *   用户跟随语音进行连接练习（支持息屏/后台运行）。
5.  **完成：** 显示打卡成功及统计数据。

---

## 3. 功能详情 (Functional Requirements)

### 3.1 动作库与数据录入 (Library & Entry)
*   **官方库 (Pre-built Library):**
    *   按层级分类：`Genre` (e.g., Popping) -> `Style/Category` (e.g., Boogaloo) -> `Move` (e.g., Walk Out).
    *   不包含标准演示视频链接（云端或本地资源包）。
*   **自定义动作 (Custom Move):**
    *   **Name:** 文本输入。
    *   **Video Source:** 调用系统相册 API (`UIImagePickerController` / `PhotoPicker`) 获取视频的本地 URI/Path。**注意：不复制文件，仅保存引用。**
    *   **Video Trimming:** 用户需通过滑块设定 `startTime` 和 `endTime` (ms)。
    *   **Initial Mastery:** 用户选择初始等级 (New/Learning/Mastered)，影响首次 `nextReviewDate`。

### 3.2 复习算法逻辑 (SRS Algorithm)
基于用户反馈的 3 个等级更新 `Move` 对象的属性：
*   **Feedback Options:**
    1.  **模糊 (Again/Forgot):** `interval` 重置为 1 天。
    2.  **认识 (Hard/Keep):** `interval` 保持不变（或微增 1.2x）。
    3.  **熟练 (Easy/Good):** `interval` 翻倍（或 2.5x）。
*   **Logic:**
    *   `nextReviewDate = today + interval`

### 3.3 串联训练模式 (Drill Mode - The Core)
*   **队列生成:**
    *   Input: `ReviewSession.items` (今日复习的所有动作)。
    *   Sequence: **Random Shuffle (完全随机)**。
    *   Loop: 队列播放完毕后自动重新洗牌，直到用户点击停止。
*   **音频引擎 (Audio Engine):**
    *   **Background Play:** 必须支持 App 退后台/锁屏后继续运行。
    *   **BGM:** 循环播放内置 Drum Loop (e.g., 4/4拍, Kick-Snare)。
    *   **BPM Control:** 滑块调节速度 (Range: 60 - 130 BPM)。
    *   **TTS (Text-to-Speech):** 使用系统 TTS 引擎朗读 `Move.name`。
    *   **Audio Ducking:** 当 TTS 播放时，BGM 音量自动降低至 20%，TTS 结束后恢复 100%。
    *   **Timing:** 
        *   默认每个动作时长为 8 拍 (基于当前 BPM 计算秒数)。
        *   TTS 触发时间：在当前动作结束前 2 拍预告下一个动作。
*   **UI 交互:**
    *   **Big Text:** 屏幕中央显示当前动作名称 (FontSize: 48pt+)，高对比度。
    *   **Next Preview:** 小字显示下一个动作名字。

---

## 4. 数据模型 (Data Schema)

请在代码中使用类似以下的数据结构（以 TypeScript 接口为例）：

```typescript
// 动作实体
interface DanceMove {
  id: string;
  name: string;
  category: string; // e.g., "Popping"
  
  // 视频源数据
  videoSourceType: 'local_gallery' | 'bundled_asset';
  videoUri: string; // 本地路径或资源ID
  trimStart: number; // 毫秒
  trimEnd: number;   // 毫秒
  
  // SRS 学习数据
  status: 'new' | 'learning' | 'reviewing';
  interval: number; // 当前间隔天数
  nextReviewDate: number; // Timestamp
  masteryLevel: number; // 0-100 (可选，用于统计)
}

// 每日复习会话
interface ReviewSession {
  date: string; // YYYY-MM-DD
  items: DanceMove[]; // 今日需要复习的动作
  completedItems: string[]; // 已打分 ID
  isDrillComplete: boolean; // 是否完成了串联训练
}
```

---

## 5. 技术栈建议 (Tech Stack Recommendation)

*(根据你的偏好选择，推荐 React Native 或 Flutter 以快速实现跨平台)*

*   **Framework:** React Native (Expo) or Flutter.
*   **Local Storage:** SQLite or AsyncStorage/Hive (保存动作数据).
*   **Video Player:** `react-native-video` or `video_player` (Flutter).
*   **Media Picker:** `expo-image-picker` or `image_picker`.
*   **Audio/TTS:** 
    *   Audio: `react-native-track-player` (支持后台播放是关键).
    *   TTS: `expo-speech` or `flutter_tts`.
*   **State Management:** Zustand, Riverpod, or Redux.

---

## 6. 开发注意事项 (Implementation Notes for Agent)

1.  **权限处理 (Permissions):** 必须正确请求 `Photo Library` (Read) 和 `Microphone/Audio` (虽不录音，但音频焦点需要) 权限。
2.  **本地视频失效处理:** 由于只存储引用 URI，如果用户在相册删除了视频，App 尝试加载时需 Catch Error 并提示用户“原视频已丢失”。
3.  **音频焦点 (Audio Focus):**
    *   Android/iOS 必须配置 Background Mode -> Audio。
    *   实现 Audio Ducking (混音) 是体验关键，不要简单地暂停 BGM。
4.  **UI 布局:**
    *   Review 界面：视频在上（循环播放 Trim 区间），三个大按钮在下。
    *   Drill 界面：极简黑色背景，白色超大文字，不仅省电也防误触。

---

## 7. 验收标准 (Acceptance Criteria)

1.  [ ] 能成功从相册选择视频，并裁剪出 5 秒片段进行循环播放。
2.  [ ] 点击“模糊”后，该动作的下次复习时间变为明天。
3.  [ ] 进入 Drill 模式，锁屏后，耳机里依然能听到鼓点和 TTS 喊动作名字。
4.  [ ] TTS 喊话时，鼓点音乐明显变小，喊完自动恢复。
5.  [ ] Drill 模式下，动作列表是完全随机的，不会重复出现固定的 A->B->C 顺序。

