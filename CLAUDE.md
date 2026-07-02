# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

Drifter is a not-yet-scaffolded Flutter app (Android target). This directory currently contains no Flutter project — no `pubspec.yaml`, no `lib/`, no `android/`. Before running any `flutter` commands here, the project needs to be created first (`flutter create .`).

The full design — data model, screens, file structure, dependencies, and build order — is written up at [`~/.claude/plans/deep-squishing-rocket.md`](file:///Users/swastikdash/.claude/plans/deep-squishing-rocket.md). Read that plan before making changes; it is the source of truth for intended architecture until the code exists and this file can be regenerated from the real codebase.

Once the project is scaffolded, re-run `/init` to replace this file with one grounded in actual build commands (`flutter run`, `flutter analyze`, `flutter test`) and real source structure under `lib/`.
