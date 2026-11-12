# AI Action Engine (ReelCraft) — Flutter Mobile App & FastAPI AI Server

[![Flutter](https://img.shields.io/badge/Mobile-Flutter_%26_Dart-02569B?style=flat-square&logo=flutter&logoColor=white)](https://github.com/VaibhavBajpaij/AI-Action-Engine)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI_%26_Python-009688?style=flat-square&logo=fastapi&logoColor=white)](https://github.com/VaibhavBajpaij/AI-Action-Engine)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

**AI Action Engine (ReelCraft)** is a cross-platform **Flutter/Dart** mobile client (`my_flutter_app/`) paired with an asynchronous **Python FastAPI + SQLAlchemy** backend (`reelcraft-server/`) for media/transcript extraction, Whisper transcription, text summarization, and semantic action generation.

---

## Architecture

```mermaid
flowchart LR
    App["Flutter App (my_flutter_app)"] -->|REST API| Backend["FastAPI Server (reelcraft-server)"]
    Backend --> Media["yt-dlp / YouTube Transcript API"]
    Backend --> AI["faster-whisper + Sentence-Transformers + Sumy + Scikit-learn"]
    Backend --> DB[(SQLAlchemy SQLite DB)]
```

---

## Tech Stack

- **Mobile Client (`my_flutter_app/`):** Flutter, Dart, Provider state management, REST network client, modular screens & services.
- **AI Backend (`reelcraft-server/`):** FastAPI, Uvicorn, SQLAlchemy, `faster-whisper`, `sentence-transformers`, `scikit-learn`, `sumy`, `yt-dlp`, `youtube-transcript-api`, `pytest`.

---

## Quick Start

### Backend Server
```bash
cd reelcraft-server
pip install -r requirements.txt
uvicorn app.main:app --reload
pytest
```

### Flutter App
```bash
cd my_flutter_app
flutter pub get
flutter run
```
