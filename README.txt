# Dark Fantasy RPG — DFR Native Core 6.0.0

This build replaces the previous monolithic/rule-heavy story implementation with a modular DFR Native Core.

## Replacement files

- `index.html` — complete application UI and Native engine integration.
- `dfr-native/index.js` — Native engine public module.
- `dfr-native/state.js` — campaign state, memory, relationships, save/load and import/export.
- `dfr-native/engine.js` — turn processing, intent parsing, NPC selection, autonomy and response generation.
- `dfr-native/narrative.js` — narrative formatting/validation; actions use `*asterisks*`.
- `dfr-native/relationship.js` — affection/trust/respect/fear/familiarity logic.
- `dfr-native/storage.js` — browser/mobile save and campaign file handling.
- `.github/workflows/build-apk.yml` — packages all Native modules into the Android APK and runs tests first.
- `manifest.webmanifest` — PWA metadata.
- `sw.js` — versioned offline cache.
- `tests/dfr-native.test.mjs` — automated Native Core regression tests.

## Important

This is a native rules/planning/narrative engine. It does **not** pretend to be a neural language model. It removes the external Qwen/Gemma/LiteRT dependency and gives the game its own persistent campaign brain: state, memory, relationships, NPC autonomy, world facts, response selection and narrative validation.

A future local language model can be attached behind the engine without changing campaign state, relationship or narrative rules.

## Android

The workflow creates the Android WebView project on the runner and copies the entire `dfr-native` module directory into the APK assets. It also runs the Node regression suite before compiling.
