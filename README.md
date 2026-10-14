<p align="center">
  <img src="./resources/yume.iconset/icon_128x128@2x.png" width="128" alt="yv icon" />
</p>

<h1 align="center">yv</h1>

<p align="center">
  <strong>A lightweight C-based WebView runtime for macOS.</strong>
  <br>
  Build desktop applications with C, HTML, CSS, and JavaScript.
</p>

<br>

## 1. What is this?
`yv` is a small desktop application runtime written in C.

The name comes from: `yume + view`.
<br>
`yume` comes from the author's name, and `view` refers to the WebView at the core of the runtime.

The basic idea is simple:
- **C** for the native runtime
- **HTML / CSS / JavaScript** for the application UI
- **WebView** for rendering
- **HTTP** for serving local application assets

The goal is to provide a lightweight foundation for building desktop applications without requiring a large application runtime.

<br>

## 2. Features
- macOS Only
- WebView-based desktop applications
- Local static asset serving
- HTML / CSS / JavaScript
- Basic macOS application menu
- Custom application icon

<br>

## 3. Roadmaps
- [ ] TypeScript with esbuild
- [ ] Tailwind CSS
- [ ] HTMX
- [ ] LLM
  - [ ] Ollama (API)
  - [ ] llama.cpp (Built-in, for Local Model)
  - [ ] OpenAI, Anthropic, Google, xAI, ...
- [ ] Windows and Linux support
- [ ] Python
- [ ] WASM (To help with high-performance operations in the frontend)
- [ ] WebSocket for serving local application assets

<br>

## 4. How It Works
At a high level, `yv` combines a few small components:

```text
┌───────────────────────────────┐
│        HTML / CSS / JS        │
├───────────────────────────────┤
│            WebView            │
├───────────────────────────────┤
│              yv               │
│     native application layer  │
├───────────────────────────────┤
│      Local HTTP server        │
├───────────────────────────────┤
│             macOS             │
└───────────────────────────────┘
```

`yv` does not implement the platform WebView itself.

Instead, it uses the existing [`webview/webview`](https://github.com/webview/webview) project as the WebView abstraction layer and [`CivetWeb`](https://github.com/civetweb/civetweb) for serving local application assets.

This keeps the runtime focused on the application layer rather than reimplementing platform-specific WebView functionality.

<br>

## 5. Build

### Requirements
- macOS
- CMake
- Ninja
- C compiler with C17 support

### Build
```bash
git clone https://github.com/kuchinashi4yume/yv.git
cd yv

make
```

The generated application bundle will be placed under:

```text
build/yv.app
```

A release build can be created with:

```bash
make build
```

which installs the application into:

```text
dist/yv.app
```
