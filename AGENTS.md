# Wooho 项目说明

## 开发规范

### 代码修改后自动运行
每次修改完代码后，需要在用户的 Android 手机（设备ID: 547a84d6）上重新运行应用：

```bash
flutter run -d 547a84d6
```

### 项目结构
- `lib/core/router/` - 路由配置
- `lib/presentation/pages/` - UI 页面
- `lib/data/` - 数据层（models, repositories, datasources）
- `lib/core/theme/` - 主题和样式

### 底部导航栏结构
Tab 0: 首页 - 训练入口
Tab 1: 元素库 - LibraryPage
Tab 2: 舞段库 - RoutinePage
Tab 3: 队列 - QueuePage
