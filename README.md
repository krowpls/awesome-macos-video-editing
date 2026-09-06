# Awesome macOS Video Editing [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

> Curated open-source video editing software, engines, and libraries — with a focus on what is
> genuinely **native** on macOS versus merely **ported** to it.

Most "best open-source Mac video editor" lists are the same handful of cross-platform Qt/GTK
apps that treat macOS as a build target. That distinction matters if you care about system
integration, or if you are building something and want prior art in Swift/AVFoundation/Metal.
So this list makes the native-vs-ported boundary explicit, then covers the wider ecosystem.

Every entry's stars, license, and last-push date were verified against the GitHub API on
**2026-07-30**. Entries marked 🔬 were read at source level, not just cataloged —
see [`NOTES.md`](NOTES.md) for architecture teardowns.

## Contents

- [Native macOS Editors](#native-macos-editors)
  - [Full editors](#full-editors)
  - [Focused tools & FCP companions](#focused-tools--fcp-companions)
- [Cross-Platform Editors](#cross-platform-editors)
- [Editing Engines](#editing-engines)
- [Screen Recorders with Editing](#screen-recorders-with-editing)
- [Browser & Programmatic Editing](#browser--programmatic-editing)
- [CLI & Automation](#cli--automation)
- [Analysis & Detection](#analysis--detection)
- [Transcode, Mux & Inspect](#transcode-mux--inspect)
- [Players & Playback Libraries](#players--playback-libraries)
- [Audio](#audio)
- [Choosing Something](#choosing-something)
- [License Compatibility](#license-compatibility)
- [Contributing](#contributing)

---

## Native macOS Editors

Written against Apple frameworks — AVFoundation, Core Image, Metal, SwiftUI/AppKit.
No Qt, no Electron, no web view.

### Full editors

- [palmier-pro](https://github.com/palmier-io/palmier-pro) 🔬 — Swift 6.2 NLE with a Metal
  effects pipeline and a built-in MCP server, so coding agents can drive the timeline.
  The only production-grade native open-source editor on this list. Apple Silicon + macOS 26
  only. `GPL-3.0` · ★12.8k · Swift
- [localcut-studio](https://github.com/shenghaoc/localcut-studio) 🔬 — Substantial native Swift
  editor under a permissive license. Little-known but ~76k LOC. `MIT` · ★0 · Swift
- [kadr](https://github.com/SteliyanH/kadr) 🔬 — Editor core with a clean separation from its
  UI layer ([kadr-ui](https://github.com/SteliyanH/kadr-ui)). Good boundary example.
  `Apache-2.0` · ★45 · Swift
- [mini-cut](https://github.com/fwcd/mini-cut) 🔬 — The smallest complete AVFoundation
  timeline you will find. WWDC21 Swift Student Challenge winner. Unmaintained since 2022 but
  still the clearest teaching read. `GPL-3.0` · ★91 · Swift
- [clip-forge](https://github.com/namuan/clip-forge) — Small, permissive, approachable.
  `MIT` · ★1 · Swift
- [holovak](https://github.com/barseghyanartur/holovak) — Minimal native editor. `MIT` · ★0 · Swift
- [Vulcan](https://github.com/hadiidbouk/Vulcan) — SwiftUI + The Composable Architecture.
  ⚠️ **No license file** — all rights reserved; read-only reference. Stale since 2022.
  `no license` · ★7 · Swift

### Focused tools & FCP companions

- [redact](https://github.com/madebysan/redact) 🔬 — Edit video by editing its transcript.
  WhisperKit + DSWaveformImage. `MIT` · ★11 · Swift
- [MarkerData](https://github.com/TheAcharya/MarkerData) 🔬 — Marker extraction for Final Cut
  Pro; a solid FCPXML interop reference. `MIT` · ★67 · Swift
- [Silenci](https://github.com/leeyc09/Silence-Cutter) 🔬 — Silence removal and subtitles,
  fully on-device via Qwen3-ASR on MLX. `Apache-2.0` · ★19 · Swift

## Cross-Platform Editors

Mature and capable. All are Qt/GTK ports rather than native Mac apps.

- [Shotcut](https://github.com/mltframework/shotcut) 🔬 — The most consistently released
  open-source NLE. Ships universal macOS binaries. QML-heavy front end over MLT.
  `GPL-3.0` · ★14.7k · C++
- [Kdenlive](https://github.com/KDE/kdenlive) 🔬 — The most feature-complete: multi-track,
  proxy editing, color grading, keyframes. Native Apple Silicon builds since 25.12.
  `GPL-3.0` · ★5.4k · C++
- [OpenShot](https://github.com/OpenShot/openshot-qt) 🔬 — Gentlest learning curve; weakest
  performance under load. `GPL-3.0` · ★6.1k · Python
- [Flowblade](https://github.com/jliljebl/flowblade) — Film-style multitrack editor.
  Linux-oriented; listed for engine and model comparison. `GPL-3.0` · ★3.1k · Python
- [Olive](https://github.com/olive-editor/olive) — Promising node-based non-linear editor.
  ⚠️ No pushes since Dec 2024. `GPL-3.0` · ★9.1k · C++
- [Blender](https://github.com/blender/blender) — Its Video Sequence Editor is awkward as a
  pure NLE, but unmatched if the work involves VFX, compositing, or 3D. Fully native Metal on
  Apple Silicon. `GPL-2.0-or-later` · ★19.4k · C++

## Editing Engines

The layer under the editors — where the interesting data models live.

- [MLT](https://github.com/mltframework/mlt) 🔬 — The framework behind both Shotcut and
  Kdenlive. Its producer/filter/transition/consumer graph is a decades-refined NLE model and
  arguably the best architectural read here. `LGPL-2.1` · ★1.8k · C
- [libopenshot](https://github.com/OpenShot/libopenshot) 🔬 — OpenShot's engine, usable
  standalone with Python and Ruby bindings. `LGPL-3.0` · ★1.5k · C++
- [FFmpeg](https://github.com/FFmpeg/FFmpeg) — The substrate nearly everything else calls.
  License depends on build flags: `LGPL-2.1+` by default, `GPL-2+` with certain components.
  ★62.5k · C

## Screen Recorders with Editing

Recording-first, but with real editing attached.

- [Cap](https://github.com/CapSoftware/Cap) 🔬 — Rust + Tauri 2, native on macOS and Windows.
  Studio Mode has zoom/pan, backgrounds, auto-captions. Uses `cidre` for Swift/ObjC bridging
  and `wgpu` for rendering. ⚠️ **AGPLv3** for the app (the `cap-camera*` / `scap-*` crates are
  MIT). ★20.4k · TypeScript/Rust
- [OBS Studio](https://github.com/obsproject/obs-studio) — Live production and capture rather
  than editing, but the reference implementation for macOS capture pipelines.
  `GPL-2.0` · ★74.2k · C
- [Kap](https://github.com/wulkano/Kap) — Well-liked Electron screen recorder. ⚠️ Effectively
  unmaintained (last push Nov 2024). `MIT` · ★19.3k · TypeScript

## Browser & Programmatic Editing

Not native, but relevant if you want a timeline model you can read quickly, or
editing-as-code.

- [OpenCut](https://github.com/OpenCut-app/OpenCut) 🔬 — Browser-based editor, no install.
  Enormous traction. `MIT` · ★79.8k · TypeScript
- [Remotion](https://github.com/remotion-dev/remotion) — Compose video in React and render it.
  ⚠️ Source-available with a **commercial license for companies**, not conventional OSS.
  ★54.8k · TypeScript
- [MoviePy](https://github.com/Zulko/moviepy) — The go-to Python video editing library.
  `MIT` · ★14.8k · Python
- [Editly](https://github.com/mifi/editly) — Declarative JSON/JS video assembly.
  `MIT` · ★5.5k · TypeScript
- [etro](https://github.com/etro-js/etro) — Typescript video-editing framework for the
  browser. `GPL-3.0` · ★1.1k · TypeScript
- [Diffusion Studio Core](https://github.com/diffusionstudio/core) — In-browser compositing
  and rendering engine. `MPL-2.0` · ★1.2k · TypeScript

## CLI & Automation

- [OrkasVideoStudio](https://github.com/Orkas-AI/Orkas-VideoStudio) — Local CLI and MCP toolkit for agent-driven composition and editing from editable `plan.json` timelines; optional BYO-provider generation. `MIT` · ★491 · TypeScript
- [LosslessCut](https://github.com/mifi/lossless-cut) 🔬 — Stream-copy trimming without
  re-encoding; the fastest way to cut large files. Electron, bundles FFmpeg per-arch.
  `GPL-2.0` · ★42.5k · TypeScript
- [auto-editor](https://github.com/WyattBlue/auto-editor) — Automatically cuts silence and
  dead air. `Unlicense` · ★4.6k · Nim
- [smartcut](https://github.com/skeskinen/smartcut) 🔬 — Frame-accurate cuts that re-encode
  only the boundary GOPs. Neat, focused algorithm. `MIT` · ★276 · Python
- [ffmpeg-python](https://github.com/kkroening/ffmpeg-python) — Filter-graph bindings.
  ⚠️ Unmaintained since Aug 2024. `Apache-2.0` · ★11k · Python
- [video-splitter](https://github.com/c0decracker/video-splitter) — Split by size or duration.
  `Apache-2.0` · ★492 · Python
- [suckless-cut](https://github.com/couleur-tweak-tips/suckless-cut) — Minimal mpv-driven
  cutting workflow. `GPL-3.0` · ★50 · Lua
- [trim.lua](https://github.com/aerobounce/trim.lua) — mpv trimming script. ⚠️ `AGPL-3.0`,
  and stale. ★102 · Lua

## Analysis & Detection

- [PySceneDetect](https://github.com/Breakthrough/PySceneDetect) — The standard for shot-change
  and scene-boundary detection. `BSD-3-Clause` · ★5.1k · Python
- [audiowaveform](https://github.com/bbc/audiowaveform) — BBC's waveform data generator; what
  you want behind a timeline audio display. `GPL-3.0` · ★2.2k · C++
- [MediaInfo](https://github.com/MediaArea/MediaInfo) — Authoritative container and codec
  metadata. `BSD-2-Clause` · ★2k · C++

## Transcode, Mux & Inspect

- [HandBrake](https://github.com/HandBrake/HandBrake) — The transcoding workhorse, with a real
  Mac app. `GPL-2.0` · ★23.9k · C
- [frame](https://github.com/66HEX/frame) 🔬 — Rust transcoder GUI on GPUi (Zed's UI
  framework) + wgpu. Shells out to FFmpeg; a transcoder, not an NLE — but a great read on
  modern Rust GPU UI. `GPL-3.0` · ★1.8k · Rust
- [Bento4](https://github.com/axiomatic-systems/Bento4) — MP4/DASH/CMAF muxing and parsing.
  ⚠️ No license file detected via API; check before reuse. ★2.5k · C++

## Players & Playback Libraries

Useful when you need scrubbing and frame-accurate seek.

- [mpv](https://github.com/mpv-player/mpv) — Scriptable player; the base for several cutting
  workflows above. `LGPL-2.1+` (GPL parts) · ★36.2k · C
- [VLC](https://github.com/videolan/vlc) — Plays anything. `GPL-2.0` · ★19.2k · C
- [hls.js](https://github.com/video-dev/hls.js) — HLS playback in the browser.
  `Apache-2.0` · ★16.8k · TypeScript
- [Jellyfin](https://github.com/jellyfin/jellyfin) — Media server with transcoding; relevant
  for library and streaming pipelines. `GPL-2.0` · ★55.1k · C#

## Audio

- [Audacity](https://github.com/audacity/audacity) — The default audio editor.
  `GPL-2.0-or-later` · ★17.5k · C++
- [Tenacity](https://github.com/tenacityteam/tenacity) — Community Audacity fork, started over
  telemetry concerns. `GPL-2.0-or-later` · ★792 · C++

---

## Choosing Something

**I want to edit video on my Mac today.** Kdenlive for features, Shotcut for stability and a
universal binary. Neither feels like a Mac app; both work.

**I want something that feels native.** Palmier Pro — if you are on Apple Silicon and macOS 26.
Accept that it is young.

**I just need to trim clips.** LosslessCut. No re-encode, no quality loss.

**I need it scripted or in CI.** auto-editor for silence, smartcut for frame-accurate cuts,
MoviePy or FFmpeg directly for everything else.

**I'm building an editor.** Read `AGENTS.md` and `Package.swift` in Palmier Pro first, then
MLT's engine model, then mini-cut as a small complete example. Borrow actual code from the
MIT/Apache tier — `localcut-studio` and `kadr` are the realistic donors.
[`NOTES.md`](NOTES.md) has the teardowns.

## License Compatibility

Read this before copying anything. Nearly everything architecturally interesting here is
copyleft.

| Tier | Projects | What it means |
|---|---|---|
| **AGPL-3.0** | Cap (app), trim.lua | Strictest. Network use can trigger source disclosure. |
| **GPL-2.0 / 3.0** | Palmier Pro, mini-cut, Shotcut, Kdenlive, OpenShot, Olive, Flowblade, Blender, LosslessCut, OBS, frame, etro, audiowaveform, HandBrake, VLC, Jellyfin, Audacity, Tenacity, suckless-cut | Read freely; copying code makes your work GPL. |
| **LGPL** | MLT, libopenshot, FFmpeg (default), mpv | Linking is generally fine; modifications to the library itself must be shared. |
| **MIT / Apache-2.0 / BSD / MPL / Unlicense** | localcut-studio, kadr, redact, MarkerData, Silenci, clip-forge, holovak, OpenCut, MoviePy, Editly, smartcut, Kap, PySceneDetect, auto-editor, MediaInfo, hls.js, Diffusion Studio, video-splitter, ffmpeg-python, OrkasVideoStudio | Safe to borrow with attribution. |
| **Non-standard** | Remotion (commercial license for companies), Bento4 (none detected), Vulcan (**none — all rights reserved**) | Check terms before any reuse. |

FFmpeg's effective license depends on the flags it was built with. A `--enable-gpl` build is
GPL, and that propagates to anything distributing it.

This table is a reading aid, not legal advice. Verify against each project's own `LICENSE`.

## Contributing

PRs welcome. Please:

1. Keep one entry per line in the established format:
   `[name](url) — description. \`LICENSE\` · ★stars · Language`
2. Say what makes it worth someone's time, not just what it is.
3. Flag staleness (no pushes in ~12 months), platform limits, and non-standard licenses with ⚠️.
4. Only use 🔬 if you actually read the source and can point at specifics.
5. No affiliate links, no closed-source apps whose repo is just docs and screenshots.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[CC0-1.0](LICENSE) — the list content is public domain. Linked projects keep their own licenses.
