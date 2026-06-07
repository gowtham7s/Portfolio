# Gowtham Selvaraj – Portfolio

A world-class personal portfolio website built with **Flutter Web**, Clean Architecture, and Riverpod.

## Live Site
[https://gowthamselvaraj.github.io/portfolio](https://gowthamselvaraj.github.io/portfolio)

---

## Stack

| Layer | Technology |
|---|---|
| Framework | Flutter Web 3.41+ |
| State Management | Riverpod |
| Routing | go_router |
| Animations | flutter_animate, animated_text_kit |
| UI | Material 3, Glassmorphism, Google Fonts (Inter) |
| Blog | flutter_markdown |
| Responsive | responsive_framework |
| Storage | JSON assets (Firebase-ready via repository pattern) |
| CI/CD | GitHub Actions → GitHub Pages |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── theme/            # AppTheme, ThemeProvider (dark/light)
│   ├── router/           # go_router configuration
│   ├── providers/        # Auth provider
│   └── widgets/          # Reusable: GlassCard, GradientButton, AnimatedSection…
├── data/
│   ├── datasources/      # JsonDataSource (swap for Firebase here)
│   └── repositories/     # Riverpod FutureProviders
├── domain/
│   └── entities/         # ProfileEntity, SkillEntity, BlogEntity…
└── features/
    ├── shell/            # AppShell (NavBar + Drawer + Back-to-top)
    ├── home/             # Hero, Stats, Testimonials
    ├── about/            # Summary, Education, Timeline
    ├── skills/           # Animated skill bars by category
    ├── experience/       # Timeline with expandable cards
    ├── projects/         # Filterable project grid
    ├── resume/           # PDF download
    ├── certifications/   # Certification cards
    ├── blog/             # List (search + pagination) + Detail (Markdown)
    ├── contact/          # Contact form + social links
    └── admin/            # Protected admin dashboard

assets/
└── data/
    ├── profile.json      ← Edit YOUR info here
    ├── skills.json
    ├── experience.json
    ├── projects.json
    ├── blogs.json
    ├── certifications.json
    ├── testimonials.json
    └── settings.json
```

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run in browser (development)
flutter run -d chrome

# Production build
flutter build web --release --base-href "/portfolio/"
```

---

## Admin Panel

Navigate to `/admin/login`

| Field | Value |
|---|---|
| Username | `admin` |
| Password | `admin123` |

> ⚠️ Change the password hash in `lib/core/providers/auth_provider.dart` before deploying.

---

## CMS – Edit Content

All content is stored in `assets/data/*.json` — no backend required.

| File | What to edit |
|---|---|
| `profile.json` | Name, bio, social links, stats |
| `skills.json` | Skill categories and percentages |
| `experience.json` | Work history |
| `projects.json` | Portfolio projects |
| `blogs.json` | Blog articles (Markdown content) |
| `certifications.json` | Certificates |
| `testimonials.json` | Testimonial quotes |
| `settings.json` | Theme colors, SEO, navigation |

---

## Deployment – GitHub Pages

1. Push to `main` branch
2. GitHub Actions automatically builds and deploys via `.github/workflows/deploy.yml`
3. Enable GitHub Pages in **Settings → Pages → GitHub Actions source**

---

## Future Enhancements

- [ ] Firebase integration (swap `JsonDataSource` with `FirebaseDataSource`)
- [ ] Admin CRUD forms with real persistence
- [ ] Image upload via Firebase Storage
- [ ] Comment system on blog posts
- [ ] Analytics dashboard

---

© 2025 Gowtham Selvaraj. Built with Flutter Web.
