# 2026-11-06 · Third-party packages are listed in `THIRD-PARTY-NOTICES.md`

- **Decision:** Any third-party open source package the apps ship, such as a Swift package or copied code, fonts or images, gets an entry in `THIRD-PARTY-NOTICES.md` in the same pull request that adds it, with its license text. Build and CI tools don't. The file doesn't exist yet, because the apps use only Apple's frameworks so far.
- **Why:** Most open source licenses, such as MIT and Apache 2.0, require shipping their notice with the app. Adding it with the package means nothing has to be dug up before a release.
- **Instead of:** Collecting notices just before a release, which is easy to forget, or an empty file kept as a placeholder.
- **PR:** [#83](https://github.com/pablocolaiacovo/clinkr/pull/83)
