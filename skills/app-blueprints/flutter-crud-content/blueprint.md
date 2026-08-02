---
id: flutter-crud-content
name: Flutter CRUD Content App
version: 1.2.0
app_type: flutter-mobile-web

match_keywords:
  - content
  - crud
  - carnet
  - health
  - gestion
  - flutter
  - mobile
  - entité
  - liste
  - édition

stack:
  framework: flutter
  sdk: ">=3.11.0"
  state_management: riverpod
  routing: go_router
  http: dio
  auth: clerk-native-android-bridge-plus-clerkjs-web
  storage: shared_preferences
  architecture: layer-first
  codegen: false

source_repo: https://github.com/dianedefores/shipglows-blueprint-flutter-crud-content

sources:
  - contentglowz_app
  - path: /home/claude/contentglowz/contentglowz_app
---

# Flutter CRUD Content App

## App Anatomy

Application mobile/web de gestion de contenu avec :
- Authentification (Clerk, avec démo offline possible)
- Liste + détail + édition d'entités (CRUD)
- Offline queue (file de synchronisation)
- Shell adaptatif desktop/mobile
- Tour guidé in-app

Acteurs typiques : utilisateur connecté, administrateur.

Screens identifiés :
- Entry (splash + auth)
- Feed (liste, swipeable cards)
- Editor (détail + édition d'une entité)
- Calendar, Activity, History (vues secondaires)
- Onboarding (première visite)
- Settings, Integrations

## Stack

| Couche | Choix |
|---|---|
| Framework | Flutter 3.41+, Dart SDK ^3.11 |
| State management | Riverpod 3.x (`Provider`, `StateNotifierProvider`, `AsyncNotifierProvider`, `FutureProvider`) |
| Routing | GoRouter (shell route + auth guard redirect + `ChangeNotifier` refresh) |
| HTTP | Dio (raw, pas de retrofit) |
| Auth | ClerkJS bridge on web; pinned Clerk Android API SDK in Kotlin behind a typed Flutter MethodChannel on Android |
| Storage | SharedPreferences (pas de Hive/Isar/SQLite) |
| Architecture | Layer-first (`core/`, `data/`, `presentation/`, `providers/`) |
| Codegen | Aucun (pas de freezed, json_serializable, riverpod_generator) |
| Error monitoring | Sentry (optionnel, via DSN) |

## Models

Tous les modèles sont écrits à la main (pas de codegen). Pattern :

```dart
class ContentItem {
  final String id;
  final String title;
  final String? description;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentItem({...});

  // copyWith avec flag clear pour les champs optionnels nullable
  ContentItem copyWith({..., bool clearDescription = false}) { ... }

  factory ContentItem.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

Types d'entités typiques du blueprint :
- Entité principale (celle qu'on CRUD)
- Énumérations de statut
- Modèle d'état d'accès (machine à états pour auth/boot)
- Modèle de session
- Modèle de cache offline

## Routes

Structure GoRouter :

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AppRouterRefreshListenable(ref);
  return GoRouter(
    refreshListenable: refreshListenable,
    redirect: (context, state) => _resolveRedirect(state, ref.read(appAccessStateProvider)),
    routes: [
      GoRoute(path: '/entry', builder: (_, __) => const EntryScreen()),
      GoRoute(path: '/editor/:id', builder: (_, state) => EditorScreen(id: state.pathParameters['id']!)),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: ...),
          GoRoute(path: '/calendar', builder: ...),
          // autres screens protégés
        ],
      ),
    ],
  );
});
```

Guards :
- `redirect` global : mapping `AppAccessStage` -> target path
- ShellRoute wrapper pour nav rail (desktop) + bottom nav (mobile)
- Screens standalone : entry, auth, editor, onboarding

## Conventions

### Folder structure

```
lib/
  main.dart
  router.dart
  core/               # Infrastructure transverse
  data/
    models/            # 1 fichier par modèle
    services/          # API service (monolithique ou découpé)
    demo/              # Seed data
  l10n/                # Internationalisation
  presentation/
    screens/
      feed/            # 1 dossier par feature
      editor/
      ...
    theme/             # Theme system
    widgets/           # Shared widgets
  providers/           # Riverpod (monofile providers.dart ou découpé)
```

### Naming

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers | snake_case | `feed_screen.dart` |
| Classes | PascalCase | `FeedScreen` |
| Providers | camelCase + `Provider` suffix | `authSessionProvider` |
| Notifiers | `*Notifier` or `*Controller` | `AuthSessionNotifier` |
| Routes | kebab-case, params avec `:` | `/editor/:id` |
| Modèles | 1 file = 1 class, snake_case file | `content_item.dart` |

### Screen pattern

```dart
class FeedScreen extends ConsumerStatefulWidget { ... }
class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider);
    return items.when(
      data: (data) => ...,
      loading: () => const SkeletonLoader(),
      error: (e, _) => AppErrorView(error: e),
    );
  }
}
```

### Provider organization

Un seul fichier `providers.dart` pour tous les providers (monolithique ~6000 lignes). Les StateNotifier complexes peuvent être extraits dans leur propre fichier si nécessaire.

Patterns utilisés :
- `StateProvider` pour état simple (ex: offline queue revision)
- `StateNotifierProvider` pour état complexe avec méthodes
- `AsyncNotifierProvider` pour état async avec lifecycle
- `FutureProvider` / `FutureProvider.family` pour data read-once
- `ChangeNotifier` comme refresh listenable pour le router (pas de `ref.watch` dans redirect)

### Model pattern

- `const` constructors
- `copyWith()` manuel avec booléens `clear*` pour les champs nullable
- `fromJson()` / `toJson()` manuels
- Enums pour status/type

## Theme

- Material 3 (`useMaterial3: true`)
- `ColorScheme.fromSeed()` avec couleurs depuis tokens
- `ThemeExtension<CustomPalette>` pour couleurs custom (canvas, surface, muted, border, heroGradient)
- Tokens générés depuis un fichier JSON (`app_theme_tokens.dart`)
- Breakpoints responsive : mobile 600, tablet 900, desktop 1200
- Police : Inter via Google Fonts
- 3 modes : system, light, dark + mode "app" (palette violette)

## States

Chaque screen gère systématiquement :
- **Loading** : `SkeletonLoader` (shimmer)
- **Empty** : message + CTA
- **Error** : `AppErrorView` (message + copie diagnostics)
- **Data** : contenu normal
- **Offline** : bannerie dans le shell (via `OfflineSyncBridge`)
- **Tour in-app** : overlay par-dessus le shell

### Auth state machine

```
signedOut → restoringSession → checkingBackend → checkingWorkspace
  → needsOnboarding | ready | apiUnavailable | bootstrapFailed | bootstrapUnauthorized
```

### Native Android Clerk contract (default: validated browser OAuth)

Use this contract for new Flutter Android apps derived from this blueprint:

- Do not make the beta `clerk_flutter` / `clerk_auth` packages the production
  Android auth owner unless the project explicitly accepts that risk.
- Pin `com.clerk:clerk-android-api` and expose only typed bridge operations:
  `initialize`, `signInWithGoogle`, `restoreSession`, `getFreshToken`, and
  `signOut`.
- Let the pinned SDK's manifest-registered callback component own OAuth return;
  do not add a competing `MainActivity` deep-link handler.
- Derive the Clerk mobile redirect from the pinned SDK manifest/source. With
  `clerk-android-api:1.0.36`, it is
  `clerk://<Clerk application id>.callback` (ContentGlowz:
  `clerk://com.contentglowz.app.callback`).
- Configure Clerk Native API, the exact Android application id, the CI release
  SHA-256 fingerprint, the derived redirect allowlist entry, and Google enabled
  for sign-in/sign-up before device testing. This is Clerk configuration; it is
  distinct from the SHA-1 Google requires only if an explicitly approved
  departure adopts its separate Credential Manager ID-token flow.
- Show progress and disable duplicate actions for initialize, restore, browser
  launch, callback completion, token retrieval, and sign-out. Never leave the
  entry screen with an unexplained pending state.
- Required device smoke: cold restore, one Google tap, browser/provider return,
  session activation, protected API call, restart restore, and sign-out. Record
  the APK commit and signing identity with the result.
- Record once per app: `auth_profile: browser-oauth (ShipGlows default)`, Gradle
  application id, pinned SDK version, SDK callback owner/URI, Clerk SHA-256,
  and tested release APK commit. Do not start implementation until this record
  is complete. Add Google SHA-1 only for an explicitly approved departure.

## États d'implémentation manquants

Ce blueprint ne couvre pas encore :
- [ ] Tests (pattern: 1:1 avec source, `flutter_test`, pas de mock framework dédié)
- [ ] CI/CD (Blacksmith pour APK, Vercel/Netlify pour web)
- [ ] Localisation avancée (actuel: custom template en/fr, pas ARB/slang)
- [ ] Upload de fichiers
- [ ] Notifications push
