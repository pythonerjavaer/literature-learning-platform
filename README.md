# Literature Learning Platform

## 在线交互演示

[**打开知识理解与证据问答网页**](https://pythonerjavaer.github.io/interview-portfolio/projects/reading.html)

示例阅读、预设回答、证据定位与笔记。无需安装，不调用真实大模型。


A cross-platform reading and discussion application for exploring English classics. The Flutter client combines focused reading, personal notes, professional analysis and community discussion with an optional AI study assistant. A lightweight Dart Shelf service provides the API and local JSON persistence.

## Product features

- Browse and search a curated classic-literature catalogue.
- Read with adjustable typography, theme and progress state.
- Create, update and search reading notes.
- Start discussions, reply to other readers and like useful topics.
- View literary analysis and personal favourites.
- Summarise passages or ask context-aware questions through Ollama or OpenAI.
- Use Android-native file, camera and notification integrations through a Flutter method channel.

## Architecture

```text
Flutter client
  |-- reading, notes, analysis, discussion and profile screens
  |-- Hive + SharedPreferences for local preferences
  |-- Dio API client
  `-- Android method channel for native capabilities

Dart Shelf backend
  |-- authentication and profile API
  |-- books, notes and discussion API
  |-- Ollama/OpenAI adapter
  `-- human-readable JSON persistence for local deployments
```

## Quick start

Flutter and Dart stable releases are required.

Start the backend:

```bash
cd backend
dart pub get
dart run bin/server.dart
```

The service listens on `http://localhost:8090`; its health endpoint is `/health`. Data is written to `backend/data` when the server is launched from the backend directory. Override the location with `DATA_DIR`.

In another terminal, launch the app:

```bash
flutter pub get
flutter run
```

Android emulators automatically connect to the host through `http://10.0.2.2:8090`. Other targets use `http://localhost:8090`. A custom endpoint can be supplied at build time:

```bash
flutter run --dart-define BASE_URL=http://192.168.1.20:8090
```

## Optional AI configuration

The backend defaults to a local Ollama service:

```bash
export AI_PROVIDER=ollama
export OLLAMA_HOST=http://localhost:11434
export OLLAMA_MODEL=qwen2:1.5b
ollama pull qwen2:1.5b
```

To use OpenAI instead:

```bash
export AI_PROVIDER=openai
export OPENAI_API_KEY=your-key
export OPENAI_MODEL=gpt-4o-mini
```

API keys are read only from environment variables and are never committed.

## Main API routes

- `POST /auth/register`, `POST /auth/login`, `GET /profile/me`
- `GET /books`, `GET /books/:id`
- `GET /notes`, `POST /notes`, `PUT /notes/:id`, `DELETE /notes/:id`
- `GET /discussions`, `POST /discussions`
- `GET /discussions/:id/replies`, `POST /discussions/:id/replies`
- `POST /ai/analyze`, `POST /ai/chat`

## Development

```bash
flutter analyze
flutter test

cd backend
dart analyze
dart test
```

Continuous integration runs the client and backend checks independently. The bundled JSON backend is designed for local and small self-hosted deployments; a production rollout should replace it with a transactional database and managed identity provider.

