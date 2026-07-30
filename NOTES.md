# Architecture Notes

Source-level teardowns of the 🔬 entries in [README.md](README.md). These come from
reading the code, not from documentation or release notes.

Snapshot: **2026-07-30**. Line references drift; treat them as starting points.

---

## Palmier Pro

The reference implementation for a native macOS NLE. ~97.6k LOC Swift, 12 Metal kernels,
143 test files against 368 source files.

### Boundaries

`Package.swift` is the highest-signal single file in the whole survey:

- Swift 6.2, `platforms: [.macOS(.v26)]`, arm64 only, non-sandboxed Developer ID.
- One executable target, feature-sliced into 25 modules under `Sources/PalmierPro/`
  (`Timeline`, `Compositing`, `Editor`, `Agent`, `Export`, `Inspector`, …). No "Core"
  or "Common" dumping ground — `Utilities` is explicitly reserved for infrastructure
  used by multiple independent features.
- **SwiftPM traits** gate optional weight out of default builds:
  - `BundledSpeech` → MLX + `speech-swift` (SpeechEnhancement, SpeechVAD)
  - `ProductionTelemetry` → Sentry + PostHog
- A build-tool plugin (`MetalCIKernelPlugin`) compiles the Metal kernels at build time.

### Vendor components

MCP `swift-sdk`, Sparkle (updates), Clerk + Convex (auth/backend), `swift-transformers`,
`mlx-swift`, lottie-ios. Telemetry deps are pinned with `exact:` rather than `from:` —
a deliberate choice for things that touch every code path.

Metal kernels: ChromaKey, LUTTetra, GradeCurves, HueCurves, Wheels, Levels,
HighlightsShadows, Glow, Grain, Clarity, Vignette, EdgeRounding.

### Domain model

`Models/Timeline.swift`. `Timeline → [Track] → [Clip]`, all `Codable + Sendable + Equatable`
**value types**.

The decisions worth stealing:

- **Integer frame domain throughout.** `startFrame`, `durationFrames`, `trimStartFrame`,
  `trimEndFrame` are all `Int`. No float drift. `CMTime` and `Double` appear only at UI and
  external-format boundaries.
- **Generic keyframes.** `KeyframeTrack<Value: Codable & Sendable & Equatable>` plus a
  `KeyframeInterpolatable` protocol, with conformances retrofitted onto `Double`, `AnimPair`,
  and `Crop`. A `Clip` carries six optional lanes (opacity, position, scale, rotation, crop,
  volume), each `nil` when unanimated — so the common case costs nothing.
- **Grouping by ID, never by nesting.** `linkGroupId`, `captionGroupId`, `multicamGroupId`.
  Keeps the tree flat and the codable representation stable across edits.
- **Nested sequences.** A `Clip` with `sourceClipType == .sequence` references another
  `Timeline` by `mediaRef`. `reachableTimelines(resolve:maxDepth:include:)` is a BFS with a
  `seen: Set<String>` seeded with `self.id` — cycle-safe by construction, with a depth cap.
- **Forgiving decode.** Hand-written `init(from:)` on `Timeline` and `Track` uses
  `try?` with defaults per field, so project files survive both older and newer writers.
  Note `displayHeight` is clamped on decode, not trusted.
- **Deliberate persistence split.** `TimelineViewState` carries a comment worth quoting:
  *"Written on tab switch and save, not live — playhead mutates every frame."*

### Algorithms

- `Timeline/SnapEngine.swift` — a stateless `enum` namespace. `SnapTarget.Kind` is
  `{playhead, clipEdge, beat}`. Hysteresis lives in a separate `SnapState` holding
  `currentlySnappedTo` and a sticky `currentProbeOffset`, so a drag doesn't chatter between
  two near-equidistant targets. `collectTargets` and `findSnap` are split, which makes the
  target set testable independently of the matching.
- `Track.contiguousClipIds(fromEnd:excludeId:)` — walks a sorted chain and breaks on the
  first gap. This is the primitive ripple edits are built on.
- `Compositing/CustomVideoCompositor.swift` — `AVVideoCompositing` conformance,
  `@unchecked Sendable`, with `cancelAllPendingVideoCompositionRequests` actually implemented.

### Endpoints — the MCP surface

`Agent/Tools/ToolDefinitions.swift` (~1273 LOC). A `ToolName: String, CaseIterable` enum of
**47 tools** with snake_case wire names, served over `MCPHTTPServer` and distributed as an
`.mcpb` bundle (`mcpb/manifest.json`, manifest_version 0.4, a Node ≥18 stdio shim pointing at
the local server).

Tools are grouped by *filmmaker intent*, not by internal API:

```
manage_project  get_timeline  inspect_timeline  create_timeline  set_active_timeline
set_project_settings  export_project  manage_exports
get_media  inspect_media  search_media  import_media  capture_frame  organize_media
manage_tracks  add_clips  insert_clips  move_clips  remove_clips  split_clips
ripple_delete_ranges  set_clip_properties  set_keyframes  apply_layout  sync_clips  undo
manage_multicam  change_cam  get_multicam
get_transcript  remove_words  remove_silence  detect_beats
add_texts  update_text  add_captions
apply_color  apply_effect  inspect_color  denoise_audio
list_models  generate_video  generate_image  generate_audio  upscale_media
send_feedback  read_skill
```

Implementation is one `ToolExecutor+<Domain>.swift` per slice — 30 files, so no single
god-file. There's also a `Skills/` catalog (`Skill.swift`, `SkillCatalog.swift`,
`SkillStore.swift`) exposed through `read_skill`: progressive-disclosure documentation the
agent pulls on demand instead of carrying in its prompt.

`ripple_delete_ranges` and `remove_silence` as *single* tools is the tell. A naive design
would expose `get_clips` + `split_clip` + `delete_clip` + `shift_clips` and make the model
orchestrate. This does the workflow atomically, in one undo step.

### AGENTS.md

`CLAUDE.md` is a one-line `@AGENTS.md` include. The spec itself is ~200 lines and is the
single cheapest high-value read in this entire corpus. Highlights:

- **Main-actor discipline.** It may own UI state, never file I/O, decoding, inference, or
  large transforms. Three traps named explicitly: `Task {}` *inherits* actor isolation;
  `nonisolated` on a sync function does *not* hop threads; `async` alone is not evidence
  work left the main actor.
- **Revalidate after every `await`.** Identity, generation, selection, and lifecycle state
  may all have changed. Snapshot immutable input before leaving an actor, return a value,
  apply it after checking cancellation.
- **Atomic package writes.** Stage outside the live `.palmier` package, prepare on the
  destination volume, install atomically. All live-package media mutations route through a
  single `ProjectPackageCoordinator` so saves, imports, exports, and closes can't race.
- **Undo grouping.** One user intent = one undo entry. Validate *before* opening the group,
  so failed and no-op operations leave no empty steps.
- **Agent tool design.** Intent-shaped, stable IDs over positional indexes, structured
  receipts that report adjustments rather than returning success-shaped lies, and no
  god-tools with unrelated modes.
- **A hard-won platform bug:** on macOS 26 a parent SwiftUI `.onDrop` silently shadows every
  nested drop target — including AppKit `NSDraggingDestination` children registered directly
  with the window. Inner `.onDrop` modifiers just never fire. Their rule: any drop target
  spanning an area that contains other drop targets must use AppKit
  (`MediaPanel/MediaPanelDropArea`).

Closed-source surface is narrow: generative AI processing only. Editor, MCP server, and agent
chat are all GPL-3.0.

---

## MLT

The engine behind both Shotcut and Kdenlive, ~203k LOC C. Its
**producer / filter / transition / consumer** graph is the most refined NLE data model in
open source, and it predates most of what it competes with.

Read this if you want to understand *why* NLE models look the way they do — the separation
between a thing that yields frames, a thing that transforms them, a thing that combines two
streams, and a thing that terminates the pipeline is the abstraction every editor
rediscovers. Worth reading before designing your own.

`LGPL-2.1`, so linking is viable in ways the GPL editors on top of it are not.

---

## mini-cut

~3.7k LOC — roughly 26× smaller than Palmier Pro, expressing many of the same ideas. The
fastest path to understanding an AVFoundation timeline end to end. Unmaintained since 2022,
so expect API deprecations against current SDKs, and note it is `GPL-3.0`.

---

## Cap

Rust + Tauri 2, and the most interesting *non-Swift* approach to native macOS media work.

- `cidre` (a pinned Git fork) for Swift/Objective-C interop — how you reach ScreenCaptureKit
  and AVFoundation from Rust without writing bridging code by hand.
- `wgpu` 25 for rendering, with a vendored `wgpu-hal` patch.
- `ffmpeg-next` against a Cap-maintained FFmpeg fork.
- `specta` for generating TypeScript types from Rust — the seam that keeps the Tauri
  front end honest.

⚠️ **AGPLv3** for the application. Only the `cap-camera*` and `scap-*` crate families are MIT
(see `licenses/LICENSE-MIT`). The AGPL is load-bearing here — do not copy from this into
anything you intend to ship closed.

---

## frame

Rust editor UI on **GPUi** — the same UI framework Zed uses — with `wgpu`, vendored as
`vendor/gpui-ce`. Notably strict lints: `clippy::all` at `deny`, plus `redundant_clone` and
`clone_on_copy` denied.

One important correction to how it is often described: `frame-core` has **no media bindings**.
Its dependency set is `font-kit`, `regex`, `serde`, `thiserror` — and its modules are
`probe.rs`, `codec.rs`, `filters.rs`, `media_rules.rs`. It **shells out to FFmpeg**. This is a
transcoder GUI, not an NLE. Still an excellent read on modern Rust GPU UI.

---

## Permissively licensed native Swift

If you are building something you don't want to be GPL, these are the realistic donors:

- **localcut-studio** (`MIT`, ~75.6k LOC Swift) — by far the largest permissive native
  codebase found. Underexposed at ★0.
- **kadr** + **kadr-ui** (`Apache-2.0`) — the core/UI split is the useful part: worth reading
  purely as an example of where to draw that line.
- **redact** (`MIT`) — WhisperKit + DSWaveformImage, and a working transcript↔timeline mapping.
- **MarkerData** (`MIT`) — the FCPXML interop reference. Read this before hand-rolling
  Final Cut Pro import/export.
- **Silenci** (`Apache-2.0`) — on-device ASR via MLX, plus a practical silence-detection pass.

## smartcut

Small and worth the read for one idea: cut frame-accurately while re-encoding **only** the
GOPs at the cut boundaries, stream-copying everything between. The middle ground between
LosslessCut's keyframe-only cuts and a full re-encode. `MIT`.

---

## Corrections to commonly repeated claims

Things widely stated that the source or live API contradicts:

- **"Kdenlive doesn't support Apple Silicon."** Outdated. Native arm64 builds since 25.12;
  the official docs list Apple Silicon support.
- **"frame is a Rust video editor."** It's a transcoder front end that shells out to FFmpeg.
  No media bindings in `frame-core`.
- **"Cap is MIT."** The app is AGPLv3. Only specific crate families are MIT.
- **"Remotion is open source."** Source-available; companies need a commercial license.
- **vidcrop** appears in Swift video-editing topic searches, but the repository contains only
  README, changelog, and screenshots — the application itself is closed-source. Excluded.
