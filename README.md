# Product Catalog

Flutter app that browses products from [DummyJSON](https://dummyjson.com). Supports search, infinite scroll pagination, pull-to-refresh, and a product detail page with an image gallery.

## Features

- Product list with pagination (`limit` / `skip`)
- Infinite scroll (loads more near the bottom of the list)
- Search with debounce (avoids calling the API on every keystroke)
- Pull-to-refresh
- Product detail with image gallery
- Loading, empty, and error UI states

## Tech stack

| Package | Role |
|---------|------|
| [GetX](https://pub.dev/packages/get) | Navigation, bindings, reactive UI state |
| [Dio](https://pub.dev/packages/dio) | HTTP client |
| [get_it](https://pub.dev/packages/get_it) | Dependency injection for shared services |
| [cached_network_image](https://pub.dev/packages/cached_network_image) | Image caching |

## Architecture

The app follows a simple layered (clean architecture) structure:

```
Screen / Controller  →  Domain  →  Data  →  DummyJSON API
```

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **UI** | `lib/screen/` | Screens, GetX controllers, route bindings |
| **Domain** | `lib/domain/` | Entities and repository *interfaces* (no Dio / JSON) |
| **Data** | `lib/data/` | Remote datasource, JSON models, repository implementation |
| **Core** | `lib/core/` | DI, Dio client, constants, shared widgets, errors |

**Domain vs data (short):**

- **Domain** = what the app understands (`Product`, `ProductPage`, repository contract)
- **Data** = how data is fetched (Dio calls, `fromJson`, model → entity, error mapping)

**Repository vs datasource:**

- **Datasource** talks to the API and returns JSON models
- **Repository** uses the datasource, converts models to entities, and maps network errors to `Failure` for the UI

## Project structure

```
lib/
├── main.dart                 # setupDependencies() + runApp
├── app.dart                  # GetMaterialApp, theme, routes
├── core/
│   ├── di/                   # get_it registration
│   ├── network/              # Dio client + error mapper
│   ├── constants/            # API base URL, page size, debounce
│   ├── state/                # ViewStatus (loading / success / empty / error)
│   ├── utils/                # Debouncer
│   └── widgets/              # Shared loading / error / empty / image widgets
├── domain/
│   ├── entities/             # Product, ProductPage
│   └── repositories/         # ProductRepository (abstract)
├── data/
│   ├── datasources/          # ProductRemoteDataSource (Dio)
│   ├── models/               # ProductModel, ProductPageModel + fromJson
│   └── repositories/         # ProductRepositoryImpl
└── screen/
    ├── routes/               # AppRoutes, AppPages
    ├── theme/
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

## Dependency injection

Two tools are used for different scopes:

1. **get_it** (`lib/core/di/injection.dart`) — app-wide services registered once at startup:
   - `Dio`
   - `ProductRemoteDataSource`
   - `ProductRepository`
2. **GetX bindings** — create controllers when a route opens, and inject the repository from get_it:

```dart
Get.lazyPut(() => ProductController(getIt<ProductRepository>()));
```

Controllers depend on the repository *interface*, not Dio or DummyJSON directly.

## Getting started

### Requirements

- Flutter SDK (compatible with `sdk: ^3.13.1` in `pubspec.yaml`)
- Network access (DummyJSON is a remote API)

### Run

```bash
flutter pub get
flutter run
```

### Platforms

Configured for Android, iOS, and web.

## AI assistance

This project was **not** built entirely with AI. I developed and reviewed the app myself. AI (Cursor) was used only as a helper for specific parts:

- Guidance on clean architecture folder layout (domain / data / screen)
- get_it + GetX binding wiring pattern
- Infinite scroll / pagination approach with DummyJSON `limit` / `skip`
- Clarifying domain vs data and repository vs datasource while learning
- Help writing this README

I still decided the features, read and adjusted the code, and take responsibility for how the app works.
