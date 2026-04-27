# 🖥️ FalconGym Admin Dashboard — Flutter Web

A production-ready Flutter **Web** admin dashboard for managing FalconGym. Shares the exact same design system (colors, typography, components) as the user mobile app.

---

## 📐 Architecture

```
lib/
├── core/
│   ├── constants/       ← API endpoints, layout constants
│   ├── data/            ← Shared data layer barrel (feature_data_layers.dart)
│   ├── di/              ← GetIt dependency injection
│   ├── entities/        ← Shared domain entities
│   ├── errors/          ← Failures & Exceptions (identical to user app)
│   ├── layout/          ← AdminShell (sidebar + topbar), ThemeCubit
│   ├── network/         ← Dio client with JWT interceptor, TokenStorage
│   ├── router/          ← GoRouter with shell route & auth redirect
│   ├── screens/         ← Feature screen barrel (feature_screens.dart)
│   ├── theme/           ← AppTheme (light/dark), AppColors — identical to user app
│   └── widgets/         ← KpiCard, AdminDataTable, StatusBadge, SectionHeader…
│
└── features/
    ├── auth/            ← Login, JWT, AuthCubit
    ├── users/           ← CRUD: data table + edit dialog
    ├── plans/           ← CRUD: create/edit/delete plans
    ├── subscriptions/   ← Assign & manage subscriptions
    ├── workouts/        ← Plans, exercises, assignments (tabbed)
    ├── messaging/       ← Inbox, sent, compose, broadcast
    ├── analytics/       ← KPI cards + bar chart + trainer stats
    └── attendance/      ← Filtered attendance table
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0 with web support enabled
- Chrome or any modern browser

### Run for Web
```bash
cd gym_admin

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on web server (any browser)
flutter run -d web-server --web-port=8080

# Build for production
flutter build web --release
```

### Font Setup (Optional — same as user app)
Download [Cairo from Google Fonts](https://fonts.google.com/specimen/Cairo) and place in `assets/fonts/`:
- `Cairo-Regular.ttf`
- `Cairo-SemiBold.ttf`
- `Cairo-Bold.ttf`

---

## 🎨 Design System Consistency

This admin app uses **identical design tokens** to the user mobile app:

| Token | Value |
|---|---|
| Primary color | `#00C896` |
| Accent color | `#FF6B35` |
| Dark background | `#0D1117` |
| Dark surface | `#161B22` |
| Dark card | `#21262D` |
| Font family | Cairo (same) |
| Border radius | 10–14px (same) |
| Button style | Same ElevatedButton theme |
| Input style | Same InputDecoration theme |

---

## 🔐 Authentication

Same JWT flow as user app:
1. `POST /api/token/` → stores tokens in `SharedPreferences`
2. Dio interceptor attaches `Authorization: Bearer <access>` to every request
3. 401 → automatic refresh via `POST /api/token/refresh/`
4. Logout → `POST /api/token/blacklist/` + clear tokens
5. GoRouter `redirect` guards all admin routes automatically

---

## 🧱 Layout

```
┌─────────────┬────────────────────────────────────┐
│             │  TopBar (title + theme + admin)    │
│   Sidebar   ├────────────────────────────────────┤
│   (260px)   │                                    │
│             │        Main Content Area           │
│  Collapsible│        (scrollable)                │
│  to 72px    │                                    │
└─────────────┴────────────────────────────────────┘
```

- **Sidebar**: Collapsible, icon-only mode, active route highlighted
- **Topbar**: Page title, theme toggle, admin user dropdown
- **Mobile**: Drawer + AppBar (breakpoint < 768px)
- **Responsive**: `ResponsiveGrid` adapts KPI cards 4→2→1 columns

---

## 📦 Modules

| Module | Endpoint | Features |
|---|---|---|
| **Dashboard** | `GET /api/analytics/dashboard/` | KPI cards, attendance chart, quick stats |
| **Users** | `GET/PUT/DELETE /api/users/` | Data table, search, edit dialog, delete |
| **Plans** | `GET/POST/PUT/DELETE /api/plans/` | Create/edit/delete plan dialog |
| **Subscriptions** | `GET/POST/PUT/DELETE /api/subscriptions/` | Assign plans, renew, expiry tracking |
| **Workouts** | `/api/workouts/plans/`, `/exercises/`, `/assignments/` | Tabbed: plans, exercises, assignments |
| **Messages** | `GET/POST /api/messages/` | Inbox, sent, compose, broadcast |
| **Attendance** | `GET /api/attendance/` | Filterable table, active session badge |
| **Analytics** | `GET /api/analytics/dashboard/` + `trainer-stats/` | Charts, trainer performance |

---

## ⚙️ Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | Cubit state management |
| `get_it` | Service locator DI |
| `dio` | HTTP client with interceptors |
| `go_router` | Declarative routing with shell routes |
| `data_table_2` | Responsive data tables |
| `fl_chart` | Bar charts for analytics |
| `shared_preferences` | JWT token persistence |
| `dartz` | Functional `Either` error handling |
| `shimmer` | Loading skeleton animations |
| `intl` | Date/number formatting |

---

## 🔒 Security Notes

- Admin tokens stored separately (`admin_access_token` key) from user app tokens
- All routes protected by GoRouter redirect guard
- Token blacklisted on logout
- No credentials stored — only JWT tokens

---

*FalconGym Admin Dashboard — built with Flutter Web + Clean Architecture*
