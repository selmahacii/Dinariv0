# Dinari — Documentation complète

> Application mobile Flutter (marché algérien) combinant un **portefeuille / paiement mobile (« WELIT »)**
> et une **marketplace de petites annonces**.

---

## 1. Vue d'ensemble

**Dinari** est une application Flutter (`name: dinari`, `version: 1.0.0+1`) écrite en Dart.
Elle se compose de deux univers fonctionnels accessibles depuis l'écran de connexion :

| Univers | Description |
|---------|-------------|
| **WELIT** (`/home-welit`) | Portefeuille électronique : solde, recharge (codes de recharge), transfert d'argent entre utilisateurs, contacts, historique des opérations, options de paiement, espace vendeur + sélection d'un transporteur. |
| **Marketplace** (`/home-marketplace`) | Petites annonces : accueil avec pub/carrousel, catégories & sous-catégories, fiche produit, publication d'annonce multi-étapes avec photos, mes annonces, messagerie (chat temps réel), sélection d'un pack boutique. |

Fonctions transverses : onboarding, authentification (email/mot de passe), profil & édition de profil,
notifications, scan de QR code, génération de QR code utilisateur, partage, contact vendeur via WhatsApp.

Langue de l'interface : **français** (les libellés dans le code sont en français).
`app_strings.dart` ne contient que le nom de l'app ; il n'y a **pas** de système i18n/l10n en place
(les clés d'erreur type `invalid_credential` sont retournées telles quelles).

---

## 2. Stack technique

### 2.1 Cœur

| Élément | Version / détail |
|---------|------------------|
| Langage | Dart, SDK `^3.7.0` |
| Framework | Flutter (canal **stable**, révision `68415ad1…` — Flutter 3.29.x) |
| Architecture | Découpage en couches `core / data (database) / presentation`, singletons `Instance` faits main, routage centralisé |
| State management | Aucune lib dédiée — `StatefulWidget` + `setState`, `IndexedStack`. `equatable` pour l'égalité des modèles. |
| Navigation | `go_router` ^14.8.0 (routes déclarées dans `lib/src/core/config/router/app_router.dart`) |
| DI | `DiService` (placeholder vide, prêt à être étendu) |
| Responsive | `flutter_screenutil` ^5.9.3 (`designSize: 412 x 917`) |
| Thème | Material 3, `ColorScheme.fromSeed` (primaire `#007373`, secondaire `#FDCE26`), police **Kumbh Sans** via `google_fonts` |

### 2.2 Back-end & services

| Service | Usage dans le code |
|---------|--------------------|
| **Firebase Core** ^3.12.0 | Initialisé au démarrage (`AppSetting.init`). Projet : `chatapp-d6ae5`. |
| **Firebase Auth** ^5.5.0 | Inscription / connexion email + mot de passe (`connect_screen.dart`, `register_screen.dart`). |
| **Cloud Firestore** ^5.6.4 | Base de données principale. Collections utilisées : `users`, `categories`, `products`, `advertisements`, `chats`, `messages`, `contacts`, `operations`, `presence`, `recharge_codes`. |
| **Firebase Storage** ^12.4.5 | Upload des photos d'annonces (`multi_stage_screen.dart`, `my_ads_screen.dart`). |
| **Supabase** (`supabase_flutter` ^2.8.4) | Initialisé au démarrage (URL + clé anon **en dur** dans `app_setting.dart`). Aucune requête `.from()` / storage repérée dans `lib/` → intégration amorcée mais pas encore exploitée. |
| **Resend** (`resend` ^4.1.2, dans `package.json` npm) | Dépendance Node hors Flutter — sans doute prévue pour l'envoi d'emails côté fonctions/serveur ; pas de code JS présent dans le repo. |

### 2.3 Principaux packages Flutter (pubspec.yaml)

- UI / nav : `go_router`, `flutter_screenutil`, `google_fonts`, `smooth_page_indicator`,
  `curved_labeled_navigation_bar`, `circle_nav_bar`, `carousel_slider`, `lottie`,
  `flutter_svg_provider`, `cupertino_icons`
- Fonctionnel : `qr_flutter` (génération QR), `mobile_scanner` ^6.0.7 (scan QR/caméra),
  `image_picker`, `permission_handler` ^12, `share_plus`, `url_launcher` (WhatsApp `wa.me`),
  `country_picker`, `intl` ^0.20.2, `uuid`
- Données : `cloud_firestore`, `firebase_auth`, `firebase_core`, `firebase_storage`,
  `supabase_flutter`, `shared_preferences` ^2.5.2, `equatable`
- Dev : `flutter_test`, `flutter_lints` ^5.0.0 (config `analysis_options.yaml` = `package:flutter_lints/flutter.yaml`)

### 2.4 Plateformes cibles

Dossiers générés présents : **android, ios, web, windows, linux, macos**.
Configuration réellement faite : **Android** (google-services.json, plugin FlutterFire).
`firebase.json` ne déclare que la plateforme Android + `lib/firebase_options.dart`.

---

## 3. Structure du projet

```
Dinari-Appv1.0.0-main/
├── pubspec.yaml / pubspec.lock      # dépendances Flutter
├── package.json / package-lock.json # dépendance npm "resend" (hors app Flutter)
├── firebase.json                    # config FlutterFire (Android)
├── analysis_options.yaml            # lints
├── android/ ios/ web/ windows/ linux/ macos/
├── assets/
│   ├── images/   (logos, onboarding, cartes, sim, recharge…)
│   ├── icons/    (drapeau algérie)
│   └── svg/      (icônes nav : accueil, catégories, message, mon marché, transfert…)
└── lib/
    ├── main.dart                    # entrée + scripts de seed Firestore (commentés)
    └── src/
        ├── app/
        │   ├── my_app.dart          # MaterialApp.router
        │   └── error_app.dart       # UI de secours si l'init échoue
        ├── core/
        │   ├── config/
        │   │   ├── DI/di_service.dart
        │   │   ├── firebase/firebase_options.dart
        │   │   ├── router/app_router.dart
        │   │   └── theme/theme_config.dart
        │   ├── setting/app_setting.dart   # init Firebase + Supabase + prefs + orientation
        │   └── utils/constants/           # app_colors, app_images, app_svg, app_strings, algeria_cites
        ├── database/
        │   ├── local/shared_preferences_service.dart  # settings_* et user_* (JSON)
        │   └── models/user_model.dart                 # id, fullName, email, phoneNumber
        └── presentation/
            ├── screens/
            │   ├── auth/            # connect, register, forgotten_password, link_sent
            │   ├── WELIT/           # home + pages (accueil, notification, profile) + charge,
            │   │                    #   contacts, money_transfer, operations, payment_options,
            │   │                    #   vendor_space, delivery_company_selection
            │   ├── Marketplace/home/ # marketplace_home + pages (catégories, produits, chat,
            │   │                     #   fiche produit…) + multi_stage_screen (publier annonce)
            │   │                     #   + store_package_selection_screen
            │   ├── onboarding_screen.dart / spalsh_screen.dart (splash)
            │   ├── profile_screen.dart / edit_profile_screen.dart / my_ads_screen.dart
            │   ├── notification_screen.dart / scan_screen.dart
            └── widgets/             # ~30 widgets réutilisables (cartes, bottom sheets, QR…)
```

**Flux de navigation** (voir `app_router.dart`) :
`/` (Splash) → `/onboarding` → `/connect` (`/register`, `/forgotten-password`, `/link-sent`)
→ `/home-welit` (sous-routes paiement, recharge, contacts, transfert, opérations, espace vendeur)
ou `/home-marketplace` (sous-route pack boutique) ; routes globales `/notification`, `/profile/my-ads`,
`/edit-profile`, `/scan`.

**Démarrage applicatif** (`main.dart`) :
`WidgetsFlutterBinding.ensureInitialized()` → `AppSetting.instance.init()` → `runApp(MyApp())` ;
en cas d'exception → `runApp(ErrorApp())`. Les fonctions `addCategoriesWithPicsumImages()`,
`addProductsToFirestore()`, etc. sont des **scripts de peuplement Firestore** à activer manuellement
(actuellement commentés).

---

## 4. Modèle de données (Firestore)

Collections référencées dans le code :

| Collection | Rôle |
|------------|------|
| `users` | Profil utilisateur (`fullName`, `email`, `phoneNumber`), doc id = UID Firebase Auth |
| `categories` | Catégories marketplace (`name`, `imageUrl`, `count`, `subcategories[]`) |
| `products` | Annonces (`title`, `price`, `rating`, `imagesUrl[]`, `description`, `category`, `subcategory`, `userID`, `visible`, `isAdvertising`, `isBestSeller`, `createdAt`) |
| `advertisements` | Bannières / pub carrousel |
| `chats` / `messages` | Messagerie marketplace |
| `contacts` | Contacts d'un utilisateur (transferts WELIT) |
| `operations` | Historique des opérations du portefeuille |
| `presence` | Statut en ligne / hors ligne |
| `recharge_codes` | Codes de recharge du solde |

Stockage local (`shared_preferences`) :
- `settings_intro`, `settings_darkMode`, `settings_locale` (défauts : `false`, `false`, `en`)
- `user_user` : `UserModel` sérialisé en JSON

Images : **Firebase Storage** pour les photos d'annonces uploadées ; `picsum.photos` pour les données de démo.

---

## 5. Outils nécessaires

### 5.1 Indispensables

| Outil | Version conseillée | Pourquoi |
|-------|--------------------|----------|
| **Flutter SDK** | 3.29.x (canal stable) — inclut Dart `>=3.7.0` | Compilation / exécution |
| **Git** | récente | Cloner le dépôt |
| **Android Studio** ou **VS Code** | dernière | IDE + plugins Flutter/Dart |
| **Android SDK** | Platform 35, Build-Tools, `minSdk 23` | Build Android |
| **Android NDK** | `27.0.12077973` | Requis par le build (défini dans `android/app/build.gradle.kts`) |
| **JDK** | 17 (compatibilité Java 11 configurée) | Gradle / plugin Android 8.7.0 |
| **Gradle** | fourni par le wrapper ; AGP 8.7.0, Kotlin 1.8.22, plugin `google-services` 4.3.15 | Build Android |
| Un **appareil Android** ou un **émulateur** (AVD) | API ≥ 23 | Exécuter l'app |

### 5.2 Selon la plateforme visée

- **iOS / macOS** : macOS + **Xcode**, **CocoaPods** (`sudo gem install cocoapods`). ⚠️ `firebase.json`
  et les fichiers de config iOS Firebase ne sont pas fournis → à générer via FlutterFire.
- **Web** : Chrome (`flutter run -d chrome`). Config Firebase Web non fournie.
- **Windows** : Visual Studio 2022 + « Desktop development with C++ ».
- **Linux** : `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.

### 5.3 Services / comptes

- **Compte Firebase** avec un projet (ici `chatapp-d6ae5`) : Authentication (Email/Password activé),
  Cloud Firestore, Storage. `android/app/google-services.json` est présent dans le repo pour ce projet.
- **CLI** utiles : `npm i -g firebase-tools`, `dart pub global activate flutterfire_cli`
  (pour régénérer `lib/src/core/config/firebase/firebase_options.dart` et les configs iOS/web).
- **Compte Supabase** (projet `jtdnrzlljqritpbwwyjp`) — clés actuellement en dur dans
  `lib/src/core/setting/app_setting.dart`.
- (Optionnel) **Node.js** si l'on veut utiliser la dépendance `resend` (`npm install` à la racine).

### 5.4 Permissions runtime déjà déclarées (Android)

`CAMERA` (scan QR), `READ_EXTERNAL_STORAGE` (maxSdk 32), `READ_MEDIA_IMAGES` (sélecteur de photos).

---

## 6. Démarrage — pas à pas

### 6.1 Prérequis

```bash
flutter --version      # doit afficher un canal stable, Dart >= 3.7.0
flutter doctor         # tout doit être vert pour la ou les plateformes visées
```

### 6.2 Installation

```bash
# 1. Se placer dans le dossier du projet
cd Dinari-Appv1.0.0-main

# 2. Récupérer les dépendances Dart/Flutter
flutter pub get
```

### 6.3 Configuration Android locale

Créer `android/local.properties` s'il n'existe pas (généralement généré automatiquement par l'IDE) :

```properties
flutter.sdk=C:\\chemin\\vers\\flutter
sdk.dir=C:\\Users\\<vous>\\AppData\\Local\\Android\\sdk
```

`android/app/google-services.json` est déjà fourni (projet `chatapp-d6ae5`).
Pour utiliser **votre propre** projet Firebase :

```bash
dart pub global activate flutterfire_cli
flutterfire configure        # régénère firebase_options.dart + google-services.json
```

### 6.4 (Optionnel) Configurer Supabase

Éditer `lib/src/core/setting/app_setting.dart` et remplacer `url` / `anonKey`
par les valeurs de votre projet (idéalement via `--dart-define` plutôt qu'en dur).

### 6.5 Lancer l'application

```bash
# Lister les appareils disponibles
flutter devices

# Exécuter en debug sur l'appareil/émulateur par défaut
flutter run

# Cibler explicitement une plateforme
flutter run -d emulator-5554      # Android
flutter run -d chrome            # Web
flutter run -d windows           # Windows desktop
```

### 6.6 (Optionnel) Peupler Firestore avec des données de démo

Dans `lib/main.dart`, décommenter temporairement les appels souhaités
(`addCategoriesWithPicsumImages()`, `addProductsToFirestore()`, `addAdvertisementsToFirestore()`, …)
dans `main()`, lancer l'app **une fois**, puis les recommenter.

### 6.7 Builds de production

```bash
flutter build apk --release            # APK Android
flutter build appbundle --release      # AAB pour le Play Store
flutter build ios --release            # iOS (macOS + Xcode requis)
flutter build web --release            # Web
```

> ⚠️ Le build `release` Android est actuellement signé avec la **clé debug**
> (`signingConfig = signingConfigs.getByName("debug")` dans `android/app/build.gradle.kts`).
> Configurer une vraie clé de signature (`key.properties` + `keystore`) avant publication.
> Penser aussi à changer l'`applicationId` `com.example.dinari`.

### 6.8 Qualité & tests

```bash
flutter analyze                        # analyse statique (flutter_lints)
dart format .                          # formatage
flutter test                           # tests (aucun test personnalisé présent pour l'instant)
```

---

## 7. Points d'attention / dette technique

- **Secrets en dur** : clé anon Supabase dans `app_setting.dart`, `google-services.json` versionné.
  Migrer vers `--dart-define` / variables d'environnement pour un vrai déploiement.
- **Supabase initialisé mais non utilisé** dans `lib/` — soit finaliser l'intégration, soit retirer.
- **`resend` (npm)** sans code associé — dépendance orpheline dans `package.json`.
- **Pas d'i18n** malgré une UI en français et une clé `settings_locale`.
- **Pas de state management** structuré : logique métier directement dans les `State` des écrans
  (appels Firestore/Auth dans les widgets).
- **Signature release = debug**, `applicationId` encore `com.example.*`.
- Fautes de frappe dans des noms de fichiers (`spalsh_screen.dart`, `chat_creen.dart`,
  `money_transfes_screen.dart`) — sans impact fonctionnel mais à corriger idéalement.
- Configs Firebase iOS / Web absentes : seul Android est prêt à l'emploi.
- `flutter_svg_provider` utilisé pour les SVG (et non `flutter_svg` directement).
