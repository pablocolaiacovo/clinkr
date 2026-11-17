# 2026-11-16 · Privacy: data stays on the devices

- **Decision:** Nothing is collected by the developer. Drinks and nights stay on the user's Watch and iPhone, with no account, backend, network requests, analytics, ads or third-party SDKs. The privacy policy (`docs/PRIVACY.md`) and support page (`docs/SUPPORT.md`) live in the repo in Spanish and English, and their GitHub URLs are the Privacy Policy and Support URLs in App Store Connect. Contact is the repo's GitHub issues, with no personal email.
- **Why:** It's how the app already works, and it gives the App Store answer "Data Not Collected" (#29). The repo is public, so the pages need no hosting.
- **Also:** The iPhone's data is in the user's normal device backup, which Apple controls. Adding iCloud (#34), Apple Health (#35), analytics or crash reporting means updating the policy and the App Store answers first.
