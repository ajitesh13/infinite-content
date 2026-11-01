# Geeta reels Flutter design system

## Status and visual reference

This is the v1 implementation specification for the Android Flutter app. The supplied Astrotalk screenshot is a **visual reference** for its near-black, warm gold, luminous yellow, and restrained celestial atmosphere. Use original app branding, illustrations, icons, and motifs. Do not copy its logo, copy, people, navigation, or astrology-specific symbols. The app remains about the Bhagavad Gita.

The product has one dark visual theme across the feed, sheets, onboarding, and settings. Devotional and explanatory reels share the same interface; only their content treatment differs. The preferred content style remains a product decision.

## Design principles

1. **Scripture first.** Verified Sanskrit and Hindi meaning are text layers, never baked into generated video. Chapter and verse are visible; full text is one tap away.
2. **Calm motion.** Animation serves reflection. No flashing CTA, confetti, autoplay sound surprise, or animated star field behind readable text.
3. **Consistent warmth.** Near-black surfaces, amber glow, and yellow actions appear throughout the app. Avoid the earlier blue feed and light comment sheet.
4. **Readable over imagery.** Use a controlled dark scrim and test every asset against caption safe areas. Move or crop an image when text readability fails.
5. **Accessible by default.** Large touch targets, scalable Devanagari, TalkBack labels, captions, visible focus, and reduced-motion behavior are part of each component contract.

## Foundation tokens

All dimensions are Flutter logical pixels (dp). Color values are fixed brand tokens; Flutter theme roles should reference them rather than spreading hex literals through widgets. These are proposed values sampled by eye from the visual direction, not an attempt to reproduce the screenshot exactly.

### Color

| Token | Hex | Use |
|---|---|---|
| `canvas` | `#0E0905` | Main background and video fallback |
| `surface` | `#1A1410` | Bottom sheets, cards, inputs |
| `surfaceRaised` | `#241B15` | Menus, elevated controls |
| `surfacePressed` | `#3B281A` | Pressed state and selected background |
| `textPrimary` | `#F8F3E9` | Main UI text and shlok text |
| `textSecondary` | `#B8ADA0` | Secondary labels and metadata |
| `gold` | `#FFD96A` | Verse reference, selected outline, key emphasis |
| `amber` | `#F6A042` | Limited gradient stop and warm illustration accent |
| `actionYellow` | `#FFF47D` | Primary buttons and selected action fills |
| `onAction` | `#241500` | Text and icons on action yellow |
| `divider` | `#40352A` | Hairlines and subtle boundaries |
| `error` | `#FF8A80` | Error text/icon on dark surfaces |
| `success` | `#A6D9A5` | Success text/icon on dark surfaces |

Contrast of proposed opaque pairs: primary on canvas **17.9:1**, secondary on surface **8.3:1**, gold on canvas **14.5:1**, and onAction on actionYellow **15.6:1**. These ratios do not validate text over video; that must be measured on final media frames and scrims. Do not use amber for small body text without a contrast check.

### Semantic Flutter color mapping

| Flutter role | Design token |
|---|---|
| `ColorScheme.brightness` | `Brightness.dark` |
| `primary` / `onPrimary` | `actionYellow` / `onAction` |
| `secondary` / `onSecondary` | `gold` / `onAction` |
| `surface` / `onSurface` | `surface` / `textPrimary` |
| `error` / `onError` | `error` / `canvas` |
| `scaffoldBackgroundColor` | `canvas` |

Use a Flutter `ThemeExtension` for roles Material's `ColorScheme` does not express cleanly: `surfaceRaised`, `surfacePressed`, `textSecondary`, `amber`, `divider`, `videoScrim`, and semantic reel colors. Set component themes for buttons, sheets, inputs, chips, icons, and snackbars from these tokens. Disable unintended dynamic color replacement for v1 so the brand stays consistent across Android devices.

### Gradients, scrims, and celestial detail

- Brand glow: amber `#F6A042` into gold `#FFD96A`; use on a short heading or a small illustration, not on long scripture text.
- Feed top scrim: transparent black at top to approximately 45% black behind header text where needed.
- Feed bottom scrim: transparent near mid-screen to approximately 90% `canvas` at the bottom. Validate with bright and detailed videos.
- Decorative stars: tiny warm dots at low opacity, sparse and static. Never put them inside text glyph areas or make them interactive.
- Circular linework: thin gold lines at very low opacity in onboarding/settings backgrounds only. Avoid astrology-specific wheels and keep it out of the reel caption zone.
- Card treatment: `surface` fill, 1 dp `divider` border only when grouping is needed, 16 dp radius. Reserve glow/shadow for the main CTA and keep it subtle.

### Spacing, radius, and elevation

| Token | Value | Typical use |
|---|---:|---|
| `space1` / `space2` / `space3` | 4 / 8 / 12 | Icon and label gaps |
| `space4` / `space5` / `space6` | 16 / 20 / 24 | Screen padding and groups |
| `space8` / `space10` | 32 / 40 | Section breaks |
| `radiusSm` / `radiusMd` / `radiusLg` | 8 / 16 / 24 | Fields, cards, sheets |
| `radiusPill` | 999 | Primary CTA and chips |
| `stroke` | 1 | Dividers and outlines |
| `icon` | 24 | Default action glyph |
| `touchTarget` | 48 × 48 minimum | All tap actions |

Use elevation sparingly: flat feed chrome, a subtle raised menu, and one visible sheet edge. Avoid stacking shadows on dark cards.

## Typography and text behavior

Use a bundled, licensed Devanagari family with correct Sanskrit conjuncts, matras, punctuation, and numeral shaping; **Noto Sans Devanagari** is the provisional choice. Use a bundled Latin sans family such as **Inter** for English UI text. Verify font licenses and weights before packaging. Do not use a decorative display font for the scripture. Prefer tabular numerals only for timers and counts.

| Role | Size / line height | Weight | Use |
|---|---|---:|---|
| Display | 32 / 40 | 700 | Welcome headline only |
| Screen title | 24 / 32 | 600 | Settings, full verse |
| Section title | 20 / 28 | 600 | Sheet headings |
| Shlok on feed | 21 / 34 | 600 | Sanskrit over reel |
| Shlok in reader | 24 / 40 | 600 | Full verse screen |
| Meaning on feed | 16 / 26 | 400 | Hindi meaning preview |
| Body | 16 / 26 | 400 | Comments and meanings |
| Label | 14 / 20 | 600 | Buttons and chips |
| Metadata | 12 / 18 | 500 | Verse reference, credit, counts |

Never shrink shlok text to fit. At larger system text scales or on compact screens, show fewer preview lines and a clear “पूरा श्लोक पढ़ें” action; the reader screen must show the entire verse and meaning with natural scrolling. Avoid fixed-height containers around Devanagari. Keep source verse, meaning, and optional editorial takeaway visually distinct and explicitly labeled. Use locale-aware punctuation and numerals consistently.

## Icons and imagery

Use one rounded icon family at 24 dp with consistent stroke/weight: heart, comment, share, more, volume, pause/play, report, back, close. Selected like uses a filled icon plus a semantic state label; color is not its only cue. Do not substitute zodiac, horoscope, or astrological icons from the reference. Generated reel visuals use a separate asset style guide: warm cinematic lighting, restrained movement, no embedded text, no misleading “historical photograph” appearance, and a reserved lower caption zone.

## Component contracts

| Component | Geometry and appearance | Interaction and states |
|---|---|---|
| Primary CTA | 52 dp high, pill, `actionYellow` fill, `onAction` label, 16 dp horizontal inset | Default, pressed (`surfacePressed` overlay), disabled, loading. One primary action per view. |
| Secondary button | 48 dp high, transparent or `surfaceRaised`, gold outline when selected | Focus, pressed, disabled; no glow. |
| Icon action | 48 × 48 target, 24 dp glyph, optional small label below in feed rail | Tap, selected, loading, disabled. TalkBack announces action and state. |
| Interest chip | 40 dp minimum high, 12 dp radius, 12 dp horizontal padding | Selected uses `gold` stroke and readable fill; multi-select announced. |
| Input / comment composer | 48 dp minimum, `surfaceRaised`, 12 dp radius, `textPrimary` input, `textSecondary` hint | Focus border gold; error text below; grows for multi-line comments and keyboard inset. |
| Bottom sheet | Dark `surface`, top 24 dp radius, 24 dp internal padding, drag handle | Preserves reel position; scrim behind; dismiss by close/back/swipe where safe. |
| Reel reference pill | Compact dark translucent surface, gold text, 8–12 dp insets | Opens full verse; always displays chapter and verse. |
| Snackbar / status | Dark raised surface with clear text and optional action | Feedback for like failure, report success, offline state; no auto-dismiss for critical errors. |
| Progress | 2 dp neutral track and gold active line at bottom safe area | Playback position; hide when full verse/sheet takes focus. |

### Reel chrome layout

Use a full-bleed 9:16 video with `BoxFit.cover`, safe-area aware overlays, and a poster placeholder before playback. On a 360 dp wide phone, use 16 dp horizontal safe inset. Reserve a roughly 64 dp right rail for actions; the scripture block occupies the remaining width and must not run under the rail. Header and bottom control positions follow system insets. The caption block sits above the playback controls and is allowed to grow; on narrow/large-text layouts, offer a shorter preview and the full-verse reader instead of overlap.

The rail order is like, comments, share, more. The bottom row contains sound state, a pause/play affordance, and source credit. Tap on clear video space pauses/resumes. Swipe vertically changes the reel; a sheet takes gesture priority while open. When the viewer opens comments or the full verse, preserve reel and playback state; default to pausing the video under a reading surface.

### Full verse reader

Dark full-screen route or expanded sheet with chapter/verse heading, complete Sanskrit text, labeled Hindi meaning, translation/source credit, and optional clearly marked editorial takeaway. Keep the text selectable where practical. Use vertical scrolling and avoid moving decorative backgrounds. A reader can return to the same reel position.

### Comments sheet

Use the same dark theme, not a light panel. Start near 75–85% of screen height and adapt to the keyboard. Include comment count, list, composer, reporting/blocking menu, empty state, and moderation notices. Comments use `Body` type; display names and timestamps are secondary. Provide enough contrast around the composer, and never hide the send button behind the keyboard. Sign-in is requested when posting, while reading remains available anonymously.

### Onboarding and settings

Use the reference atmosphere most strongly here: black canvas, restrained amber glow, faint circular linework, and a yellow primary CTA. Language and interests are explicit choices. Settings use dark cards or simple dividers, not decorative reels. Include sound default, language, recommendations reset, privacy, account deletion, and support.

## Motion and feedback

| Motion | Timing | Rule |
|---|---:|---|
| Button press | 100–150 ms | Small opacity/scale feedback; no bounce |
| Sheet entrance/exit | 240–300 ms | Ease-out in, ease-in out; retain focus |
| Like state | 160–220 ms | Small fill change; no particles |
| Reel transition | Platform-driven swipe | Keep video start and caption placement stable |
| Poster to video | 150–250 ms | Gentle crossfade only after first frame is ready |

Respect reduced-motion settings: remove decorative transitions and use immediate state changes where practical. Generated imagery must avoid flashes and high-frequency motion. Haptics are light and optional; do not use them on every scroll.

## Accessibility and localization acceptance

- Minimum 48 × 48 dp tap targets and visible keyboard/focus behavior.
- Text contrast target at least 4.5:1 for normal text and 3:1 for large text/icons; test real composited video frames, not just token pairs.
- TalkBack traversal follows header → verse/reference → meaning → actions → playback controls; announce like, mute, loading, and error states without repeating every playback tick.
- Captions and full text remain available when muted. Audio meaning is never the sole source of information.
- Test Android system font scaling, 320 dp width, landscape/letterboxing behavior, screen reader, high contrast, reduced motion, keyboard open, and network errors.
- Hindi and Sanskrit content is versioned by reel and remains separate from user-interface localization. The Sanskrit choice displays Sanskrit shlok with Hindi meaning as agreed.

## Flutter implementation mapping

The design system should be represented by a single `ThemeData` with Material 3, a dark `ColorScheme`, `TextTheme`, and component themes. Put brand-only roles in a `ThemeExtension`. Keep sizes and motion timings in named design-token constants. Build reusable widgets for reel chrome, verse text, action rail, buttons, chips, sheets, comment rows, loading/error states, and attribution. Use `MediaQuery`/safe-area information and scalable text layout; avoid pixel-positioned scripture text. Use semantic labels and focus order in those widgets. The reel renderer chooses devotional or explanatory content data but uses the same shell and tokens.

Reference: [Flutter themes](https://docs.flutter.dev/cookbook/design/themes), [ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html), [ColorScheme](https://api.flutter.dev/flutter/material/ColorScheme-class.html), [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html), and [Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility).

## Design QA gate

Before UI implementation is accepted, review screenshots on 320, 360, and 412 dp widths and a large-text device; compare feed, full verse, comments, onboarding, settings, loading, and error states. Validate colors on actual video frames, check Devanagari shaping and line breaks, run TalkBack through each journey, and verify the dark theme remains consistent when a sheet or keyboard opens. Record any deliberate exception to these tokens in this document.
