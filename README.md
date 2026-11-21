## 概述

这是 [media-kit](https://github.com/media-kit/media-kit) 的一个分支。

1. Linux 平台捆绑预构建 libmpv2.so 以摆脱对系统 mpv 的依赖。

2. windows 平台原生支持 D3D11 渲染器，支持零拷贝硬件加速渲染，并摆脱对 ANGLE 的依赖。

3. Linux 平台使用模拟 vulkan 交换链的三重缓冲实现以尽量避免 Linux 平台糟糕的 openGL 驱动导致的黑屏或闪烁行为。

4. 合并来自 [avbuild](https://github.com/wang-bin/avbuild) 的 ffmpeg 树外补丁。可以播放原版 [media-kit](https://github.com/media-kit/media-kit) 无法播放, 但 [video_player](https://pub.dev/packages/video_player) 可以播放的非标准视频流。

5. 更新的 mpv 版本并优化二进制大小。

6. 新增 `player.stream.bufferingSpeed` / `player.state.bufferingSpeed`：当前缓冲（下载）速度，单位为字节/秒，没有在读取数据时为 0；视频还在打开阶段时也为 0。

## 使用

需要 Dart 3.10 / Flutter 3.38 或更新版本。仅需核心包和可选的视频渲染包：

```yaml
dependencies:
  media_kit:
    git:
      url: https://github.com/cbet25158/media-kit.git
      ref: main
      path: ./media_kit
  media_kit_video:
    git:
      url: https://github.com/cbet25158/media-kit.git
      ref: main
      path: ./media_kit_video

dependency_overrides:
  media_kit:
    git:
      url: https://github.com/cbet25158/media-kit.git
      ref: main
      path: ./media_kit
```

三处 `ref` 必须相同。`main` 是最新版本；发布应用时建议固定到 tag（例如 `v1.1.0`）或完整的提交号。
`dependency_overrides` 不能省略：`media_kit_video` 通过相对路径依赖 `media_kit`，pub 会把它解析成具体的提交号，
与上面按分支名或 tag 名声明的 `media_kit` 对不上，`pub get` 会报 `version solving failed`。
如果三处 `ref` 都写完整的提交号，可以不写 `dependency_overrides`。

迁移到 native assets 之前的版本（带 `media_kit_libs_*` 包）保留在 `legacy-1.0` 分支。

核心包的 Dart 构建钩子统一下载、校验、缓存和打包当前目标平台的 mpv、FFmpeg 及附属库。
音频应用只需 `media_kit`，默认使用同一套音视频二进制。

参见 [原生构建与迁移说明](media_kit/doc/native_assets.md) 和 [事件循环生命周期](media_kit/doc/native_event_loop.md)。
