# 2026-11-06 · Spanish is the development language

- **Decision:** Both apps are written in Spanish. The text in code and the String Catalogs' source language are Spanish (`es`), written in Argentine Spanish, and English (`en`) is the one translation. The UI tests launch the apps in each language, and the schemes have launch arguments, off by default, that run them in either one.
- **Why:** Spanish is the launch language, so the copy should be written and reviewed in Spanish first, with English as an adaptation in the same voice rather than the other way round. `es` rather than `es-AR` means a phone set to any Spanish, like Mexico's or Spain's, gets the Spanish text, and a device with none of Clinkr's languages in its list falls back to Spanish.
- **Instead of:** English as the source with Spanish as a translation, which made Spanish the copy that's always catching up, or a test plan that runs every test in both languages, which would double the slow Watch UI tests on CI.
- **PR:** [#87](https://github.com/pablocolaiacovo/clinkr/pull/87)
