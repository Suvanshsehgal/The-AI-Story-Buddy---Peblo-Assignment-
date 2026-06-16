# Peblo Story Buddy

An interactive children's story app built with Flutter. Narrates bedtime stories aloud using text-to-speech, tracks progress sentence-by-sentence, and quizzes the child after each story. Designed for children ages 4-8.

---

## Framework Choice

### Why Flutter

Flutter was chosen for three primary reasons:

1. **Single codebase for Android and iOS** — Peblo targets Android (especially mid-range and low-end devices), but a single Dart codebase means iOS support is trivially available.
2. **Declarative, reactive UI** — State-driven widgets map naturally to the reading flow (idle → loading → playing → quiz → celebration). Riverpod integrates natively with this model.
3. **Rich animation primitives** — `AnimationController`, `AnimatedBuilder`, and `Animation` classes require zero native platform code for floating buddy animations, quiz slide-ins, shake effects, and confetti particles.

### Benefits for this Use Case

| Concern | How Flutter Addresses It |
|---|---|
| Low-end Android performance | Skia/Impeller renderer, `cacheWidth`/`cacheHeight` for image decoding, `FilterQuality.low` |
| TTS integration | `flutter_tts` plugin provides native TTS bridge |
| Quick iteration | Hot reload for visual tuning of kid-friendly UI |

---

## Features

- **AI Buddy character** — Animated mascot with 5 emotional states (idle, thinking, reading, celebrating, sad), each with distinct glow color and visual indicators
- **Story card** — Displays all sentences of the active story; current sentence is highlighted with animated background and bold text; completed sentences dim
- **Read Me A Story CTA** — Prominent yellow button that triggers narration
- **Text-to-speech narration** — Sentence-by-sentence spoken reading with word-level progress tracking
- **Audio player controls** — Play/pause, replay, and navigation buttons with progress bar
- **Loading overlay** — Semi-transparent overlay with animated dots shown during audio preparation (2-second simulated delay)
- **Error overlay** — Full-screen error state with "Try Again" button and sad buddy
- **Retry functionality** — Error state and retry button allow restarting narration
- **Quiz after narration** — 3 multiple-choice questions appear automatically when the story ends
- **Dynamic quiz options** — Rendered from JSON; supports 2, 3, 4, 5+ options with zero code changes
- **Wrong answer feedback** — Red highlight on incorrect option, shake animation overlay, haptic vibration
- **Correct answer celebration** — Confetti particle animation, star badge, "+1 Star" reward, bounce-in card, haptic feedback
- **Haptic feedback** — `HapticFeedback.heavyImpact()` on correct answers, `HapticFeedback.mediumImpact()` on incorrect
- **Buddy state changes** — Buddy shows thought bubble (thinking), book emoji (reading), sparkle (celebrating), sweat drop (sad)
- **Onboarding callout bubble** — Typewriter-animated greeting bubble: "Hi explorer! Ready for today's magical story?"

### Not Yet Implemented

- Multiple story selection (always loads the first story)
- Persistent star/score tracking
- Audio download/offline caching

---

## Architecture

```
lib/
├── core/              # Utilities and constants
│   ├── constants.dart
│   ├── responsive.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_text_styles.dart
├── models/            # Data classes
│   ├── story_model.dart
│   └── quiz_model.dart
├── services/          # Business logic
│   └── tts_service.dart
├── providers/         # Riverpod state
│   ├── story_provider.dart
│   ├── story_state_provider.dart
│   ├── quiz_provider.dart
│   ├── buddy_provider.dart
│   └── tts_provider.dart
├── screens/           # Full-page views
│   └── home_screen.dart
└── widgets/           # Reusable components
    ├── top_section.dart
    ├── story_card.dart
    ├── ai_buddy_section.dart
    ├── callout_bubble.dart
    ├── primary_cta.dart
    ├── audio_player.dart
    ├── quiz_section.dart
    ├── loading_state.dart
    ├── error_state.dart
    ├── wrong_answer_overlay.dart
    └── celebration_overlay.dart
```

### Layer Responsibilities

- **`models/`** — Plain Dart classes with `fromJson` factories. No dependencies on Flutter or Riverpod.
- **`services/`** — `TtsService` wraps `flutter_tts` and exposes callbacks (`onSpeakStart`, `onSpeakComplete`, `onProgress`, `onError`). Stateless — no provider dependency.
- **`providers/`** — Riverpod notifiers that hold mutable state and orchestrate interactions between models, services, and UI. `StoryNotifier` coordinates TTS playback, quiz reveal, and buddy state changes.
- **`screens/`** — `HomeScreen` is a `ConsumerStatefulWidget` that reads providers via `ref.watch` and passes data down to widgets. Contains zero business logic.
- **`widgets/`** — Pure presentation components. Receive data through constructors and emit events through callbacks.

---

## State Management

**Riverpod 3.x** with `flutter_riverpod` is used exclusively.

### Provider Inventory

| Provider | Type | Purpose |
|---|---|---|
| `ttsServiceProvider` | `Provider<TtsService>` | Singleton TTS engine instance. Disposed via `ref.onDispose`. |
| `storyListProvider` | `FutureProvider<List<StoryModel>>` | Loads and parses `stories.json` from assets. |
| `storyStateProvider` | `NotifierProvider<StoryNotifier, StoryState>` | Drives narration: idle → loading → playing → paused → completed → error. Holds current sentence index, progress (0.0–1.0), sentence count, and narration start time. |
| `quizProvider` | `NotifierProvider<QuizNotifier, QuizState>` | Controls quiz visibility (hidden, visible, correct, wrong), tracks current question index. Handles correct/wrong transitions with haptic feedback. |
| `buddyProvider` | `NotifierProvider<BuddyNotifier, BuddyState>` | Simple enum holder for the AI buddy's emotional state. |

### State Flow

```
User taps "Read Me A Story"
        │
        ▼
storyStateProvider.readStory()
  ── sets StoryStatus.loading, BuddyState.thinking
  ── awaits 2-second loading delay
  ── sets StoryStatus.playing, BuddyState.reading
  ── calls ttsService.speak(sentence[0])
        │
        ▼
On sentence completion (TTS callback)
  ── advances to next sentence
  ── or, if last sentence:
      ── sets StoryStatus.completed, BuddyState.idle
      ── calls quizProvider.show()
```

The UI never directly mutates state. All transitions go through provider notifiers.

---

## Audio Narration Flow

```
                          ┌─────────────────┐
                          │  "Read Me A     │
                          │   Story" Tapped  │
                          └────────┬────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │  readStory() called          │
                    │  State → StoryStatus.loading  │
                    │  Buddy → BuddyState.thinking  │
                    │  Show LoadingOverlay          │
                    └────────────┬────────────────┘
                                 │
                     ┌───────────▼───────────┐
                     │  Future.delayed(2s)   │
                     │  (simulated audio      │
                     │   preparation)         │
                     └───────────┬───────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │  State → StoryStatus.playing │
                    │  Buddy → BuddyState.reading  │
                    │  _speakSentence(0)           │
                    │  ttsService.speak(sentence)  │
                    └────────────┬────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │  TTS completes sentence N  │
                    │  onSpeakComplete fires      │
                    │  → _onSentenceComplete()   │
                    └────────────┬────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │  More sentences?            │
                    │  Yes → _speakSentence(N+1)  │
                    │  No  → StoryStatus.completed │
                    │       → quizProvider.show() │
                    └─────────────────────────────┘
```

### Technical Details

- `TtsService` uses `flutter_tts` with language `en-US`, speech rate `0.45`, pitch `1.1`, volume `1.0`.
- Word-level progress is computed as `endOffset / text.length` and exposed via `onProgress`.
- The completion callback (`_onCompletion` at `tts_service.dart:48`) fires after each sentence; `StoryNotifier._onSentenceComplete` decides whether to play the next sentence or transition to completed.
- Pause calls `flutter_tts.pause()`; resume re-calls `flutter_tts.speak()` from the same sentence index.
- The loading delay is a hardcoded `Duration(seconds: 2)` in `AppConstants.loadingDelay`. In production this would be replaced with actual audio download/decoding time.

---

## Data Driven Quiz

### JSON Structure

```json
{
  "stories": [
    {
      "id": "the-lost-gear",
      "title": "The Lost Gear",
      "sentences": ["...", "..."],
      "quiz": {
        "questions": [
          {
            "question": "What colour was Pip the Robot's lost gear?",
            "options": [
              { "text": "Blue", "isCorrect": true },
              { "text": "Red", "isCorrect": false },
              { "text": "Green", "isCorrect": false },
              { "text": "Yellow", "isCorrect": false }
            ]
          }
        ]
      }
    }
  ]
}
```

Each story can optionally include a `quiz` object containing an array of `questions`. Each question has a `text` string and an array of `options`, where each option has a `text` and an `isCorrect` boolean.

### Dynamic Rendering

The `QuizSection` widget uses `ListView.builder` with `itemCount: widget.options.length`. The number of options is determined entirely by the JSON data:

```dart
// quiz_section.dart:140-145
ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: widget.options.length,  // driven by JSON
  itemBuilder: (context, index) => _buildOption(index),
)
```

### Varying Option Counts

The system supports 2, 3, 4, 5, or more options per question with **zero code changes**. Adding options to a JSON question is sufficient:

```json
{
  "question": "Who helped Pip?",
  "options": [
    { "text": "A firefly", "isCorrect": true },
    { "text": "An owl", "isCorrect": false },
    { "text": "A rabbit", "isCorrect": false },
    { "text": "A fairy", "isCorrect": false },
    { "text": "A squirrel", "isCorrect": false }
  ]
}
```

This would automatically render 5 options without any code modification. Option colors cycle through an 8-color palette using modulus: `_optionColors[index % _optionColors.length]`.

### Why No Hardcoding Is Needed

The full quiz data pipeline is data-driven:

| Layer | File | What happens |
|---|---|---|
| JSON file | `assets/json/stories.json` | Contains stories and nested quizzes |
| Deserialization | `story_model.dart` | `StoryModel.fromJson` calls `QuizModel.fromJson` |
| Model | `quiz_model.dart` | `QuizModel` → `List<QuizQuestionModel>` → `List<QuizOptionModel>` |
| Provider | `story_provider.dart` | `FutureProvider` loads and parses JSON, caches result |
| UI | `quiz_section.dart` | `widget.options.length` determines rendered option count |

---

## Audio Loading & Failure Handling

### Loading State

When the user taps "Read Me A Story":
1. `StoryNotifier.readStory()` sets `state.status = StoryStatus.loading`
2. `LoadingOverlay` is rendered over the entire screen (semi-transparent black overlay)
3. The overlay shows a purple gradient circle with sparkle icon, "Getting your story ready..." text, and three animated bouncing dots
4. A 2-second delay (`Future.delayed(AppConstants.loadingDelay)`) simulates audio preparation time
5. The buddy switches to `BuddyState.thinking` (yellow question mark badge)

### Error State

Two paths can trigger the error state:

- **TTS initialization failure**: `TtsService._init()` catches exceptions and calls `onError`, which sets `StoryStatus.error` and `BuddyState.sad`
- **TTS runtime error**: `flutter_tts` error handler calls `_onTtsError`, which sets the same error state

The `ErrorOverlay` renders with:
- Wi-Fi off icon in a pink circle
- "Oops!" heading
- "Let's try that again." subtext
- A purple "Try Again" button

### Retry Flow

Tapping "Try Again" calls `storyNotifier.readStory()`, restarting the full pipeline:
1. TTS engine is re-initialized
2. Story is reloaded from the provider cache
3. Loading overlay is shown again
4. Narration begins from sentence 0

There is also a developer-only "Simulate Error (dev)" button at the bottom of the home screen (visible only in idle state) that triggers `StoryNotifier.simulateError()` for testing the error UI.

---

## Caching Strategy

### Current Approach

- **Asset bundle**: `stories.json` is bundled in the APK/IPA via `pubspec.yaml` assets declaration. No network requests are needed for story loading.
- **GIF image**: The AI buddy GIF is precached at app startup via `precacheImage()` in `main.dart:24-28`. This ensures the GIF is decoded into the image cache before the first frame renders.
- **GIF decoding**: `cacheWidth: 300` and `cacheHeight: 300` parameters on `Image.asset` tell Flutter to decode the GIF at a fixed resolution of 300×300 rather than its full native size, reducing memory footprint.

### Future Improvements

- **Remote audio caching**: For production with remotely-hosted audio, use `flutter_cache_manager` or `cached_network_file` to store TTS audio files on device, keyed by story ID.
- **Asset bundle caching**: `stories.json` could be cached with `shared_preferences` for offline-first behavior if fetched from a remote API.
- **Pre-decode GIF frames**: Extract and cache individual frames as `ui.Image` objects to avoid repeated GIF decoding on each frame render.

---

## Performance Profiling

### What Was Measured

- APK size contribution from the GIF asset
- Widget rebuild frequency during narration playback
- Animation controller lifecycle

### Optimizations Made

| Optimization | Location | Description |
|---|---|---|
| GIF decode resolution | `ai_buddy_section.dart:87-88` | `cacheWidth: 300, cacheHeight: 300` caps decode at 300×300 |
| Low filter quality | `ai_buddy_section.dart:89` | `FilterQuality.low` reduces rendering cost |
| Gapless playback | `ai_buddy_section.dart:86` | `gaplessPlayback: true` avoids white flash between frames |
| GIF precaching | `main.dart:24-28` | `precacheImage` called once at startup |
| AnimatedBuilder child optimization | Multiple widgets | Static child subtrees are passed via `child:` parameter to avoid rebuilding on every animation frame |
| Const constructors | All widgets | `const` constructors where fields are final |
| ShrinkWrap + NeverScrollableScrollPhysics | `quiz_section.dart:141-142` | Prevents scroll physics overhead inside nested ListView |

### Asset Optimization

The GIF asset (`peblo2.gif`) is 28.7 MB. This is the largest contributor to APK size and the primary memory concern. The `cacheWidth`/`cacheHeight` parameters reduce its decoded memory footprint, but the binary size remains in the APK.

### Widget Rebuild Optimization

- `StoryCard` uses `AnimatedContainer` for sentence highlighting, which applies transitions at the paint phase without rebuilding the widget tree
- `QuizSection` resets its animation controller only when the question text changes (`didUpdateWidget` check at line 68)
- The 1-second `Timer.periodic` in `HomeScreen` triggers `setState` unconditionally — this is an area for improvement

### Memory Considerations

- All `AnimationController` instances are disposed in their respective `dispose()` methods (verified for all 6 controllers across the codebase)
- TTS service is disposed via `ref.onDispose` in `tts_provider.dart`
- Timer in `HomeScreen` is cancelled in `dispose()`
- The GIF, when decoded at 300×300 with animation frames, consumes approximately 300×300×4 bytes × frame count — for a multi-frame GIF this can be significant

---

## Optimization for Mid-Range Android Devices

The following design decisions target mid-range and low-end Android devices:

### Lightweight Assets

- Single GIF asset (no multiple resolution variants)
- Decode-limited to 300×300 via `cacheWidth`/`cacheHeight`
- No vector-heavy illustrations beyond Material icons

### Efficient State Management

- Riverpod notifiers avoid `ChangeNotifier` overhead; state is immutable and replaced atomically
- Providers are lazily initialized by Riverpod's default behavior
- `FutureProvider` loads JSON once and caches it

### Minimal Rebuilds

- `AnimatedBuilder` passes `child` parameter to preserve static subtrees across animation frames
- `ConsumerStatefulWidget` is used only where needed; `StatelessWidget` is preferred
- Sentence highlighting uses `AnimatedContainer` (painting-only animation, no widget rebuild)

### Animation Considerations

- All animation durations are between 200ms and 600ms for responsive feel without overshooting
- The buddy float animation (3-second sine wave with ±4px offset) is lightweight — only a `Transform.translate` at the paint phase
- Confetti uses 20 particles with simple linear trajectories — no physics simulation
- Loading dots animation reuses a single `AnimationController` with `repeat()` and modulo arithmetic for staggering

---

## AI Usage & Engineering Judgment

### 1. Where AI tools were used

- **README generation**: The structure and sections of this document were suggested by an AI coding assistant.
- **Code scaffolding**: Initial widget templates and provider boilerplate were partially generated and then manually refined.

### 2. One AI suggestion that was rejected

The AI recommended wrapping the entire home screen body in a `ValueListenableBuilder` to eliminate the periodic timer-based `setState` for clock updates.

### 3. Why it was rejected

The clock is used only to show elapsed narration time. The current approach (1-second `Timer` calling `setState`) works correctly and the performance cost on mid-range devices is negligible for this single screen. Replacing it with a `ValueListenableBuilder` would add architectural complexity (a new notifier + stream) without measurable benefit at this scale.

### 4. A challenge that initially failed

Synchronizing the TTS completion callback with the UI state transitions. Early versions had a race condition where the quiz would appear before the final sentence finished displaying, because the TTS completion fired asynchronously but the UI state update was not atomic.

### 5. How it was solved

The fix was to sequence state transitions inside the TTS completion callback (`_onSentenceComplete`) instead of using separate `await` chains:

```dart
// story_state_provider.dart:105-125
void _onSentenceComplete() {
  final current = state;
  final nextIndex = current.currentSentenceIndex + 1;
  if (nextIndex >= current.sentenceCount) {
    // Atomic: stop, mark completed, show quiz, reset buddy — all in one synchronous block
    state = StoryState(status: StoryStatus.completed, ...);
    ref.read(buddyProvider.notifier).state = BuddyState.idle;
    ref.read(quizProvider.notifier).show(totalQuestions);
  } else {
    _speakSentence(nextIndex);  // next sentence via TTS
  }
}
```

By reading the current state at the start of the callback and making all mutations synchronous within it, the race condition was eliminated.

---

## Future Improvements

- **Multiple story selection** — Add a story picker/drawer to select from all 3 JSON stories instead of always playing the first
- **Persistent star tracking** — Save earned stars to disk with `shared_preferences` or `hive`
- **Downloadable audio** — Replace TTS with pre-recorded voice narration; download and cache remotely-hosted audio files
- **Skeleton loading** — Replace the 2-second hardcoded delay with shimmer/skeleton placeholders that respond to actual loading time
- **Story progress persistence** — Remember the last-played story and sentence across app restarts
- **Accessibility improvements** — Add `Semantics` groups, richer `liveRegion` usage, and configurable font sizes
- **Remove unused dependencies** — `confetti`, `flutter_animate`, `flutter_svg`, and `cupertino_icons` are declared in `pubspec.yaml` but not imported in any Dart file
- **Add unit and widget tests** — The project currently has no test directory
- **True responsive layout** — Replace fixed pixel margins/paddings with `Responsive` utility usage across all widgets (currently only `topSectionHeight` uses `Responsive.h()`)

---

## Running the Project

### Prerequisites

- Flutter SDK ^3.11.3
- Dart SDK ^3.11.3

### Setup

```bash
cd peblo_story_buddy
flutter pub get
```

### Run

```bash
flutter run
```

### Build

```bash
flutter build apk          # Android
flutter build ios           # iOS (requires macOS + Xcode)
```

---

## Project Structure

```
peblo_story_buddy/
├── android/                        # Android platform files
├── assets/
│   └── json/
│       └── stories.json            # Story and quiz data (3 stories, 9 questions)
├── ios/                            # iOS platform files
├── lib/
│   ├── main.dart                   # App entry point, theming, GIF precache
│   ├── core/
│   │   ├── constants.dart          # All animation durations, sizing, timing constants
│   │   ├── responsive.dart         # Scale factor helpers (reference: 414×896)
│   │   └── theme/
│   │       ├── app_colors.dart     # Color palette (purple, yellow, teal, pink, etc.)
│   │       └── app_text_styles.dart # Nunito text styles (display, heading, body, button)
│   ├── models/
│   │   ├── story_model.dart        # StoryModel (id, title, sentences, optional quiz)
│   │   └── quiz_model.dart         # QuizModel → QuizQuestionModel → QuizOptionModel
│   ├── services/
│   │   └── tts_service.dart        # FlutterTts wrapper with state machine and callbacks
│   ├── providers/
│   │   ├── story_provider.dart     # FutureProvider that loads stories.json
│   │   ├── story_state_provider.dart # Notifier for narration state machine
│   │   ├── quiz_provider.dart      # Notifier for quiz visibility and correct/wrong flow
│   │   ├── buddy_provider.dart     # Notifier for buddy emotional state
│   │   └── tts_provider.dart       # Provider for singleton TtsService
│   ├── screens/
│   │   └── home_screen.dart        # Main screen: wires state to widgets, no business logic
│   └── widgets/
│       ├── ai_buddy_section.dart    # Animated GIF buddy with state-dependent badges
│       ├── audio_player.dart       # Play/pause, progress bar, replay controls
│       ├── callout_bubble.dart     # Typewriter-animated greeting bubble
│       ├── celebration_overlay.dart # Correct answer: confetti, star, "+1 Star" overlay
│       ├── error_state.dart        # Error overlay with "Try Again" button
│       ├── loading_state.dart      # Loading overlay with animated dots
│       ├── primary_cta.dart        # "Read Me A Story" button
│       ├── quiz_section.dart       # Quiz card with dynamic options, correct/wrong indicators
│       ├── story_card.dart         # Sentence list with animated current-sentence highlight
│       ├── top_section.dart        # Gradient header with buddy, logo, star count
│       └── wrong_answer_overlay.dart # Shake-animated wrong answer overlay
├── pubspec.yaml                    # Dependencies: flutter_riverpod, flutter_tts, google_fonts
└── Readme.md                       # This file
```

---

*Built for the Peblo Flutter Developer Intern Challenge*
