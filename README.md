# Flutter-AI

A lightweight AI chat app built with Flutter and Dart. Type a message, press Enter, and receive a response from Google's Gemini API in a teal-themed chat interface.

## Features

- Text prompts and AI replies displayed in chat bubbles.
- Direct HTTP integration with Gemini's `generateContent` endpoint.
- Random welcome text when the chat is empty.
- Custom Federo and Monoton fonts bundled with the app.
- API errors displayed in the conversation.
- Platform folders for Android, iOS, web, Windows, macOS, and Linux; these targets have not all been verified.

## Getting started

### Requirements

- Flutter SDK with Dart compatible with `^3.10.4`, as specified in `pubspec.yaml`.
- A Flutter-supported device, emulator, or browser and its platform tooling.
- Internet access and a Gemini API key with access to the configured model.

### Install and run

```sh
git clone https://github.com/abdullahAtassi42/Flutter-AI.git
cd Flutter-AI
flutter pub get
```

In `lib/main.dart`, replace the placeholder value of `geminiApiKey` with your own key for local development:

```dart
const String geminiApiKey = 'example_api_key';
const String geminiModel = 'gemini-2.5-flash';
```

Do not commit a real API key. This prototype calls Gemini directly from the client, so a key included in a distributed app can be extracted. Use a backend that keeps credentials server-side before distributing a production app.

Then launch on an available device:

```sh
flutter devices
flutter run
```

For a Chrome development session:

```sh
flutter run -d chrome
```

Enter a nonempty message in the bottom text field and press Enter (or submit on the keyboard). The app clears the input, adds your message, and appends the model's reply when it arrives.

## How it works

All application logic is in `lib/main.dart`:

1. `main()` launches the stateful `MainApp` widget.
2. The text field trims submitted input and calls `_handleSend()`.
3. `_handleSend()` appends the user's message to the in-memory `chat` list.
4. `sendToGemini()` sends an HTTP POST to `https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent`, with the API key in the `x-goog-api-key` header and the message in a JSON `contents` array.
5. The app extracts `candidates[0].content.parts[0].text` from the response and adds it to the list. Errors are added as text messages.
6. `setState()` rebuilds the list of bubbles, alternating alignment and color by list index.

Each request contains only the latest user message. Earlier messages remain visible but are **not sent as conversation context** to Gemini.

## Project layout

```text
Flutter-AI/
├── lib/main.dart          # Interface, chat state, and Gemini API request
├── assets/fonts/         # Federo and Monoton font files
├── pubspec.yaml          # Dependencies, assets, and Dart version constraint
├── pubspec.lock          # Resolved dependency versions
├── android/              # Android app configuration
├── ios/                  # iOS app configuration
├── web/                  # Web app shell and icons
├── windows/              # Windows runner
├── macos/                # macOS runner
└── linux/                # Linux runner
```

The app uses Flutter's Material widgets and the Dart `http` package. JSON encoding and decoding use `dart:convert`.

## Current limitations

- Chat history is kept in memory and disappears when the app restarts. The drawer's Home item is a visual placeholder.
- There is no streaming response, loading indicator, request queue, or conversation persistence.
- Bubble roles are inferred from list position. Sending another message before a reply arrives can make that visual ordering inaccurate; wait for each reply before sending the next prompt.
- Response parsing expects a text candidate. Empty or blocked responses can produce an error message.
- The configured model is `gemini-2.5-flash`; availability depends on the Gemini account and service.

## Development

```sh
flutter analyze
flutter build web
```

There are no Dart tests under a `test/` directory in the current snapshot. Live Gemini responses require a valid key and were not verified as part of documenting this project.
