# <p align="center"> d_testing </p>

## `ProviderContainer`
- An in-memory container that creates, stores, and disposes providers.
- Similar to a headless ProviderScope (no widgets).
- read/watch/override providers outside Flutter widgets (e.g., in tests, background tasks, isolates, scripts).
### Why use it?
1. Testing (most common)
    - Instantiate a clean container per test.
    - Override dependencies (e.g., repositories, API clients) with fakes/mocks.
    - Read provider values synchronously.
    - Dispose at the end to ensure no leaks.
2. Headless logic / background work
    - Run provider based logic in an isolate or CLI like process without a widget tree.
3. Manual lifecycle control
    - Precisely create/refresh/invalidate providers and verify effects.
### When to use it (and when not)
- Use ProviderContainer when:
    - Writing unit tests for providers and notifiers.
    - Doing pure Dart logic (no BuildContext) that still needs providers.
    - Spawning isolates or headless services using Riverpod state.
- Don’t use it when:
    - You’re in a Flutter widget use ProviderScope + ref (watch/read/listen) instead.
    - You want widget rebuilds ProviderContainer doesn’t rebuild UI.
