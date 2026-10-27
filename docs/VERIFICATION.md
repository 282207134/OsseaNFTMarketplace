# 验证与交付记录

验证日期：2026-10-27。开发环境为 Windows、Flutter 3.47.7、Dart 3.13.5；模拟器为 Android 15 / API 35，设备编号 `emulator-5554`。

## 自动化检查

| 检查 | 范围 | 结果 |
| --- | --- | --- |
| `flutter analyze` | 应用、测试和截图工具 | 无问题 |
| `flutter test` | 9 项测试，包含完整双主题页面遍历 | 通过 |
| Android 模拟器截图测试 | 81 个编号入口 × 两种主题 | 通过，生成 162 张截图 |
| 完整内容长图渲染 | 21 个长页 × 两种主题 | 通过，生成 42 张长图 |
| Android Release 分架构构建 | ARMv7、ARM64、x86_64 | 通过 |
| Release 安装与冷启动 | x86_64 包安装到 Android 模拟器 | 通过，安装成功，启动状态为 `ok` |

9 项测试涵盖本地购买的重复提交保护、余额更新、状态恢复、创建与上架的商品参数传递、162 个主题页面状态的布局、360 × 800 较小屏幕、搜索空结果与匹配、报价校验与签名流程、购买与个人资产更新。

布局遍历使用 428 × 926 的参考逻辑尺寸，并加载真实 Urbanist 字体。模拟器截图为 1126 × 2436 像素；系统状态栏不包含在 Flutter 截图内容中，因此顶部安全区会显示留白。该截图是应用实际渲染结果，不是 Pixso 原图。

长图在测试渲染环境中使用相同的生产组件，将完整滚动内容展开后导出，宽度为 856 像素。它们补充展示详情页、创建表单、个人资料和筛选页的下半部分。

## 复现命令

以下命令按顺序运行，避免 Flutter 测试和 Android 构建同时改写自动生成的插件注册文件。

```sh
flutter pub get
flutter analyze
flutter test
flutter drive --driver=test_driver/screenshots.dart --target=integration_test/screenshots_test.dart -d emulator-5554
flutter test tool/capture_long_screenshots.dart
python tool/build_docs.py
flutter build apk --release --split-per-abi
```

原始执行记录保存在 `analysis-results.txt`、`test-results.txt`、`emulator-results.txt`、`long-screenshot-results.txt` 和 `build-results.txt`。

发布版 APK 位于 `../dist/`，文件 SHA-256 校验值保存在 `../dist/SHA256SUMS.txt`。ARM64 包约 22.3 MB，模拟器 x86_64 包约 23.7 MB。

## 可交互验收路径

1. 首次打开应用，完成引导，选择一个钱包进行演示连接。
2. 首页点击搜索，输入 `Zombie` 查看匹配；输入不存在的名称查看空状态。
3. 打开 NFT 详情，收藏后在 Profile → Favorited 查看。
4. Make Offer 输入正数并经过 Confirm / Sign，在 Offers Made 查看。
5. Buy Now → Complete Purchase → Sign，在 Purchased 与钱包 NFTs 查看购买记录。
6. 底部 + 创建 NFT，使用 sample artwork，填写名称后创建，再从 Sell 进入上架流程。
7. 打开收藏集，点击眼睛按钮，在 More → Watchlist 查看关注记录。
8. Settings 切换 Dark Mode，重启后检查主题和收藏等本地数据。
9. More → Explore All Screens 对照查看 81 个画板状态。

## 已知范围

- Android 在当前模拟器完成构建与运行验证；iOS 工程需要 macOS / Xcode 验证。
- 本次自动化验证覆盖布局、主要本地流程和持久化，不构成对后端、链上交易、多语言翻译或设备认证的测试，这些服务尚未接入。
- `file_picker` 在当前 Flutter 版本构建时会提示 Kotlin 插件未来迁移提醒；当前版本能正常构建。后续升级 Flutter 时需同步检查该依赖。
- 收藏、报价和购买标签的数据取决于本地记录；直接从页面库预览时可能呈现空状态。
- 部分文字、默认数据、图标和表单能力按 Flutter 演示实现调整，未执行逐像素差异度比对。
