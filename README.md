# Hello Flutter

一个使用 Flutter 开发的跨平台应用示例，展示了 Flutter 的基本功能和最佳实践。

## 项目描述

这个项目是一个单词配对应用，具有以下特性：
- 随机生成单词配对
- 支持收藏喜欢的单词配对
- 简洁美观的用户界面
- 支持多平台（Android、Web、Windows）

## 技术栈

- Flutter 3.24.4
- Dart SDK >=2.19.4 <4.0.0
- Material Design 3

## 开发环境要求

- Flutter SDK
- Android Studio / VS Code
- Android SDK（用于 Android 开发）
- Git

## 快速开始

1. 克隆项目
```bash
git clone https://github.com/ohxiaoguang/hello_flutter.git
cd hello_flutter
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 项目结构

```
lib/
  ├── main.dart          # 应用入口点
  └── ...               # 其他源代码文件

android/                # Android 平台相关代码
ios/                   # iOS 平台相关代码
web/                   # Web 平台相关代码
windows/               # Windows 平台相关代码
```

## 功能特性

- [x] 基础单词生成
- [x] 收藏功能
- [ ] 数据持久化
- [ ] 主题切换
- [ ] 多语言支持

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目。

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 相关资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Dart 官方文档](https://dart.dev/guides)
- [Material Design](https://material.io/design)

## 联系方式

如有任何问题或建议，欢迎通过以下方式联系：
- GitHub Issues
- Email: 975129758@qq.com

## 更新日志

### 2024-11-18
- 配置 macOS 开发环境
- 设置 GitHub Actions 自动构建流程
- 添加多平台（macOS/Windows/Linux/iOS/Android）构建支持
- 实现 DMG 打包功能

### 构建历史
| 版本     | 日期       | 更新内容                    | 构建平台                    |
|---------|------------|---------------------------|----------------------------|
| v0.1.10 | 2024-11-18 | 完善发布工作流              | macOS, Windows, Linux, iOS |
| v0.1.9  | 2024-11-18 | 修复 iOS 构建问题           | iOS                        |
| v0.1.8  | 2024-11-18 | 初始版本                   | Android                    |
