# AGENTS.md

A concise guide for AI agents contributing to this Flutter project.

## 0) Conventions at a glance (read first)
- Naming
  - Files/dirs: lower_snake_case (e.g., chart_card.dart)
  - Classes: PascalCase; methods/fields: lowerCamelCase; private: leading underscore
- Widgets
  - Public StatelessWidget/StatefulWidget classes (not builder functions)
  - Keep small and composable; parameter-driven, side‑effect free
- Imports
  - Prefer `package:` imports for cross-module references; relative allowed for nearby siblings (be consistent within a file)
- Theming & design
  - Never hardcode colors/typography; use `context.theme` (Forui) or `Theme.of(context)`
  - Use breakpoints from `lib/theme.dart` and spacing from `DashboardConstants`
  - Buttons/icons must have explicit, high-contrast colors from the theme
- Responsiveness
  - Use `LayoutBuilder` + centralized breakpoints; avoid magic numbers
  - Prevent overflow with `Expanded/Flexible`, `maxLines`, and `TextOverflow.ellipsis`
- Animations
  - Prefer implicit transitions: `AnimatedSwitcher`, `AnimatedContainer`, `SizeTransition`
- Charts (fl_chart)
  - Maintain parity between Line and Bar modes; swap via `AnimatedSwitcher`
  - Theme-aligned colors, consistent grid/borders; safe min/max; trim edge labels
- State
  - Provider for ThemeMode; local state for view-only UI (e.g., chart period/type)
- Error logging
  - Log issues with `debugPrint()`; keep UI error messages helpful but concise

## 1) Project overview and purpose
- A responsive dashboard template built with Flutter (Material 3) and Forui (design system/components).
- Demonstrates a modern layout: sidebar navigation, header actions (theme toggle), KPI metric cards, interactive charts, progress cards, and lists.
- Data is currently mock/sample-only via service classes. No backend is connected yet.
- Goals: keep UI polished, theme-consistent, and responsive; keep logic modular and easy to refactor when real data sources are added.

Key libraries
- forui (UI kit, theming extensions, icons via FIcons)
- provider (ThemeMode management)
- fl_chart (Line/Bar charts)

## 2) Architectural patterns and conventions
- Layered structure
  - models: small immutable data holders used by widgets/services
  - services: data producers/adapters (currently mock data). Replace here when wiring APIs/DB
  - widgets: reusable view components (cards, lists, sidebar). Composition-first
  - pages: route-level layout and orchestration
  - theme: app theme, forui bridging, and sidebar styling
  - core: cross-cutting constants
- Theming
  - Primary source of truth: lib/theme.dart (Material 3 ThemeData). Forui themes chosen in main.dart via selected preset
  - Use context.theme (Forui extension) for colors, typography, spacing; use Theme.of(context) only when needed
  - Avoid hardcoding colors/typography in widgets; prefer theme values and DashboardConstants for layout
- State management
  - Provider for ThemeMode (ThemeProvider). Local widget state for view-only interactions (e.g., chart period and type)
- Responsiveness
  - Breakpoints centralized in theme.dart (Breakpoints + context.theme.breakpoints)
  - Use LayoutBuilder + breakpoints to adapt grids/padding/controls
- Animations
  - Prefer implicit animations and lightweight transitions (AnimatedSwitcher, SizeTransition, AnimatedRotation)

## 3) Important directories and their purposes
- lib/main.dart: App entry, MaterialApp + Forui theme wiring, ThemeMode switching
- lib/theme.dart: Material 3 color/typography palettes, Breakpoints, theme helpers, Forui preset config
- lib/theme/theme_provider.dart: ThemeMode cycling (system → light → dark)
- lib/theme/sidebar_style.dart: Forui sidebar style tokens (spacing, colors, interactions)
- lib/core/constants.dart: Layout/time constants for consistent spacing/timing
- lib/pages/dashboard_page.dart: Main screen assembly (sidebar + header + grids + lists + chart)
- lib/widgets/: Reusable UI components
  - chart_card.dart: Line/Bar chart with time-period selector and chart-type toggle (AnimatedSwitcher)
  - metric_card.dart, simple_progress_card.dart: KPI/Progress cards
  - simple_performers_list.dart, simple_activity_feed.dart: Sample lists
  - sidebar.dart + patched_sidebar.dart: Patched Forui sidebar and items with hover/expand behavior
  - dashboard_header.dart: Header with sidebar + theme actions
- lib/services/: Data providers (mock by default)
  - chart_service.dart: Generates ChartDataSet maps for multiple periods
  - navigation_service.dart: Sidebar nav/document structures
  - user_service.dart: Current user sample data
- lib/models/: Small model classes (ChartDataPoint, ChartDataSet, NavigationItem, UserData, DocumentItem)
- pubspec.yaml: Dependencies (forui, provider, fl_chart)

## 4) Code style and naming conventions
- Dart/Flutter idioms
  - Classes: PascalCase; methods/fields: lowerCamelCase; private members: leading underscore
  - Constants: group as static const in a dedicated class (e.g., DashboardConstants)
  - Keep widgets small and composable; extract UI into public widget classes, not private builder functions
- Imports
  - Prefer package imports for cross-module references inside lib (e.g., package:dash/models/...) to minimize path churn
  - Relative imports are acceptable for nearby siblings, but be consistent within a file
- Theming
  - Never hardcode colors/typography; use context.theme (Forui) or Theme.of(context)
  - Use Breakpoints and DashboardConstants instead of literals for layout and spacing
- Charts
  - Use fl_chart. Provide consistent titles/grid/borders and theme-aligned colors
- Null-safety and readability
  - Avoid deeply nested logic in build methods; split into widgets
  - Keep public widgets parameter-driven and side-effect free

## 5) Common patterns for implementing features
- New UI component
  1) Create a parameterized StatelessWidget in lib/widgets
  2) Style via context.theme.colors/typography and DashboardConstants
  3) Add small, tasteful animations (AnimatedSwitcher/Container/Rotation) where appropriate
- Page-level composition
  - Assemble widgets in lib/pages; keep orchestration and responsive grid logic here
- Data access
  - Add/extend a service in lib/services to supply models; keep mock data here until a backend is connected
  - Models in lib/models remain minimal and immutable
- Charts
  - Follow ChartCard structure: time-period selection + AnimatedSwitcher to swap chart visualizations (Line/Bar)
  - Compute min/max safely; hide first/last axis labels to avoid overflow; use theme colors for series and grid
- Sidebar/navigation
  - Build groups/items via NavigationService; use PatchedFSidebar components; keep interactions lightweight
- Theme switching
  - Use ThemeProvider via Provider; wire a toggle in the header when needed

## 6) Project-specific rules or constraints
- No backend connected by default
  - If persistence/Auth is needed, use Dreamflow’s Firebase or Supabase panel to connect. Do not add manual CLI setup in code
- Theming is centralized
  - lib/theme.dart defines Material 3 scheme and Forui preset. Do not hardcode colors in widgets
- Responsive design
  - Use breakpoints from theme.dart and constants from core/constants.dart; avoid magic numbers
- Charts use fl_chart
  - Maintain visual/interaction parity between Line and Bar modes; keep AnimatedSwitcher transitions
- Forui integration
  - Leverage context.theme.* for colors, typography, sidebar styles, and FIcons
  - Use PatchedFSidebar/Group/Item from lib/widgets/patched_sidebar.dart for sidebar lists
- Keep the codebase demo-friendly
  - Services return mock/sample data and should be the only place to swap in real data sources later

Notes for future backend integration
- Replace service implementations (not their public surface) with API/DB calls
- Introduce repositories only if complexity grows; keep models small and serializable

---
This file is intended to help autonomous agents implement features quickly while preserving design consistency, responsiveness, and maintainability.

Backend Info:
No backend connected. To use Firebase or Supabase features, advise the user to open the Firebase (or Supabase) panel in Dreamflow and complete setup.
Do not suggest user connect to backend manually or via CLI tools, because Dreamflow has integrated the backend setup process.
