# Product Catalog

Flutter app that browses products from [DummyJSON](https://dummyjson.com). Supports search with recent-search history, infinite scroll pagination, pull-to-refresh, favourites that persist across restarts, and a product detail page with an image gallery.

## Features

- Product list with pagination (`limit` / `skip`), showing image, name, rating, and price
- Infinite scroll (loads 20 at a time, fetches more near the bottom of the list)
- Search by name with debounce (avoids calling the API on every keystroke)
- Recent searches shown under the search bar when it is focused
  - Last 5, most recent on top
  - No duplicates (searching the same term again moves it to the top)
  - Tap a recent search to run it again
  - Clear all recent searches
  - Persisted across app restarts
- Favourites
  - Toggle from the list or the detail page, kept in sync everywhere
  - Persisted across app restarts
- Product detail with image gallery, description, price, rating, and stock
- Loading, empty, and error (with retry) UI states; pull-to-refresh
- Tapping outside the search field dismisses the keyboard and recent-search panel

## Tech stack

| Package | Role |
|---------|------|
| [GetX](https://pub.dev/packages/get) | Navigation, bindings, reactive UI state |
| [Dio](https://pub.dev/packages/dio) | HTTP client |
| [get_it](https://pub.dev/packages/get_it) | Dependency injection for shared services |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Local persistence for favourites and recent searches |
| [cached_network_image](https://pub.dev/packages/cached_network_image) | Image caching |

## Architecture

The app follows a simple layered (clean architecture) structure:

```
Screen / Controller  →  Domain  →  Data  →  DummyJSON API / local storage
```

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **UI** | `lib/screen/` | Screens, GetX controllers, route bindings |
| **Domain** | `lib/domain/` | Entities and repository *interfaces* (no Dio / JSON) |
| **Data** | `lib/data/` | Remote datasource, local storage, JSON models, repository implementations |
| **Core** | `lib/core/` | DI, Dio client, constants, shared widgets, errors |

**Domain vs data (short):**

- **Domain** = what the app understands (`Product`, `ProductPage`, repository contracts)
- **Data** = how data is fetched (Dio calls, `fromJson`, model ↔ entity, error mapping, SharedPreferences)

**Repository vs datasource:**

- **Datasource** talks to the API (`ProductRemoteDataSource`) or local storage (`LocalStorage`)
- **Repository** uses the datasource, converts models to entities, and maps network errors to `Failure` for the UI

## Project structure

```
lib/
├── main.dart                 # await setupDependencies() + runApp
├── app.dart                  # GetMaterialApp, theme, routes
├── core/
│   ├── di/                   # get_it registration
│   ├── network/              # Dio client + error mapper
│   ├── constants/            # API base URL, page size, debounce
│   ├── state/                # ViewStatus (loading / success / empty / error)
│   ├── utils/                # Debouncer
│   └── widgets/              # Shared loading / error / empty / image / favourite widgets
├── domain/
│   ├── entities/             # Product, ProductPage
│   └── repositories/         # ProductRepository, PreferencesRepository (abstract)
├── data/
│   ├── datasources/          # ProductRemoteDataSource (Dio), LocalStorage (SharedPreferences)
│   ├── models/               # ProductModel, ProductPageModel + fromJson / toJson
│   └── repositories/         # ProductRepositoryImpl, PreferencesRepositoryImpl
└── screen/
    ├── routes/               # AppRoutes, AppPages
    ├── theme/
    ├── favorites/            # Shared favourites controller + binding
    ├── product/              # List screen + controller + binding
    └── product_detail/       # Detail screen + controller + binding
```

## API

Base URL: `https://dummyjson.com`

| Action | Method | Path | Query |
|--------|--------|------|-------|
| List products | `GET` | `/products` | `limit`, `skip` |
| Search | `GET` | `/products/search` | `q`, `limit`, `skip` |
| Product detail | `GET` | `/products/{id}` | — |

Page size is `20` (`ApiConstants.pageSize`).  
`hasMore` is derived from: `skip + products.length < total`.

## How infinite scroll works

1. `ProductController` attaches a listener to `ScrollController`.
2. When the user scrolls within ~240px of the bottom, `loadMore()` runs.
3. `loadMore()` is skipped if already loading, there is no more data, or the first load failed.
4. The next page uses the current `_skip`, then appends results and updates `hasMore`.
5. The list shows a bottom spinner while loading more, or “You’re all caught up” when finished.

Search and refresh reset `_skip` to `0` and reload from the first page.

## How persistence works

`PreferencesRepository` (implemented by `PreferencesRepositoryImpl` over `LocalStorage` /
SharedPreferences) stores two things so they survive app restarts:

- **Favourites** — full products are serialized to JSON. `FavoritesController` is a shared,
  permanent controller so the list tile and detail page stay in sync.
- **Recent searches** — stored as a string list, de-duplicated case-insensitively, newest first,
  capped at 5.

## Dependency injection

Two tools are used for different scopes:

1. **get_it** (`lib/core/di/injection.dart`) — app-wide services registered once at startup
   (`setupDependencies()` is `async` because SharedPreferences initializes asynchronously):
   - `Dio`
   - `LocalStorage`
   - `ProductRemoteDataSource`
   - `ProductRepository`
   - `PreferencesRepository`
2. **GetX bindings** — create controllers when a route opens, and inject repositories from get_it:

```dart
Get.lazyPut(() => ProductController(
  getIt<ProductRepository>(),
  getIt<PreferencesRepository>(),
));
```

The product list route also registers `FavoritesBinding`, which puts a `permanent`
`FavoritesController` shared across the list and detail screens. Controllers depend on the
repository *interfaces*, not Dio or DummyJSON directly.

## Getting started

### Requirements

- Flutter SDK (compatible with `sdk: ^3.13.1` in `pubspec.yaml`)
- Network access (DummyJSON is a remote API)

### Run

```bash
flutter pub get
flutter run
```

### Test

```bash
flutter test
```

`test/preferences_repository_test.dart` covers the favourites and recent-search persistence rules
(ordering, de-duplication, the 5-item cap, clearing, and survival across a new repository instance).

### Platforms

Configured for Android, iOS, and web.
