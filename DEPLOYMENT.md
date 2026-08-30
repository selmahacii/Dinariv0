# Dinari — Guide ultime de déploiement (Android)

> But : livrer l'application à un client sous forme d'APK/AAB, gratuitement,
> proprement, et de façon reproductible.
> Plateforme couverte : **Android** (seule plateforme configurée dans ce repo).

---

## 0. Vue d'ensemble — quelle méthode choisir ?

| Méthode | Coût | Pour qui / quand | Difficulté |
|---|---|---|---|
| **APK en lien direct** (Drive, WhatsApp, WeTransfer, mail) | 0 € | 1–3 personnes, test rapide | ★ |
| **GitHub Releases** | 0 € | lien stable, plusieurs testeurs, historique de versions | ★★ |
| **Firebase App Distribution** | 0 € (plan Spark) | groupe de testeurs, notifications de MAJ, feedback | ★★ |
| **GitHub Actions** (build auto) | 0 € (repo public ; privé = 2000 min/mois) | éviter de builder à la main, publier sur tag | ★★★ |
| **Google Play** (test interne → prod) | 25 $ une fois | vraie distribution grand public, MAJ automatiques | ★★★ |

**Recommandation** : commence par **GitHub Releases** ou **Firebase App Distribution**
(gratuit, lien propre, gère les mises à jour). Passe au **Play Store** quand le client
veut une diffusion publique.

---

## 1. Prérequis (poste de build)

| Outil | Vérifier |
|---|---|
| Flutter SDK (canal stable) | `flutter --version` |
| `flutter doctor` au vert pour Android | `flutter doctor` |
| Android SDK **Platform 36** + Build-Tools + NDK `27.0.12077973` | via Android Studio → SDK Manager |
| JDK 17 | `java -version` |
| Git | `git --version` |
| (option) `gh` CLI GitHub | `gh --version` |
| (option) `firebase-tools` | `npm i -g firebase-tools` puis `firebase --version` |

> Ce repo tourne avec Flutter 3.44.x. Note déjà appliquée : `google_fonts` remonté à
> `^6.3.3` (le `6.2.1` ne compile pas avec ce SDK).

---

## 2. Préparer l'application pour la production

### 2.1 Identité de l'app

Fichier `android/app/build.gradle.kts` :

```kotlin
android {
    namespace = "com.tonentreprise.dinari"   // ← à personnaliser
    compileSdk = 36                            // ← passer de 35 à 36 (plugins l'exigent)

    defaultConfig {
        applicationId = "com.tonentreprise.dinari"   // ← IMMUABLE une fois publié
        minSdk = 23
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

- Nom affiché sous l'icône : `android/app/src/main/AndroidManifest.xml` →
  `android:label="Dinari"`.
- Icône : remplacer les `android/app/src/main/res/mipmap-*/ic_launcher.png`
  (ou utiliser le package `flutter_launcher_icons`).
- Version : `pubspec.yaml` → `version: 1.0.0+1`
  (`1.0.0` = versionName lisible, `+1` = versionCode entier, **à incrémenter à chaque build livré**).

### 2.2 Créer une clé de signature (keystore)

⚠️ Actuellement le build `release` est signé avec la **clé debug**
(`signingConfig = signingConfigs.getByName("debug")`). Il faut une vraie clé,
sinon impossible de publier sur le Play Store et impossible de livrer des mises à
jour installables par-dessus.

```bash
keytool -genkey -v -keystore dinari-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias dinari
```

Réponds aux questions (nom, organisation…). Retiens les **deux mots de passe**
(keystore + alias). **Sauvegarde `dinari-release.jks` hors du repo** — le perdre =
ne plus jamais pouvoir mettre à jour l'app sur le Store.

Crée `android/key.properties` (⚠️ **ne pas committer**) :

```properties
storePassword=TON_MDP_KEYSTORE
keyPassword=TON_MDP_ALIAS
keyAlias=dinari
storeFile=../../dinari-release.jks
```

Dans `android/app/build.gradle.kts`, avant `android { }` :

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

et dans `android { }` :

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")   // ← au lieu de "debug"
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
}
```

### 2.3 `.gitignore` — secrets à exclure

Ajoute :

```gitignore
android/key.properties
*.jks
*.keystore
```

`android/app/google-services.json` est déjà présent dans le repo pour le projet
`chatapp-d6ae5`. Pour un projet client, régénère-le avec `flutterfire configure`.

### 2.4 Règles de sécurité Firestore (important avant prod)

Le code écrit dans `categories`, `products`, `users`, `operations`,
`recharge_codes`, `app_meta`… Vérifie/ajuste les règles dans la console Firebase
(Firestore → Règles). Exemple minimal « utilisateur connecté » :

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }
    match /products/{id}   { allow read: if true; allow write: if request.auth != null; }
    match /categories/{id} { allow read: if true; allow write: if request.auth != null; }
    match /{document=**}   { allow read, write: if request.auth != null; }
  }
}
```

> Le seeder `MarketplaceImageSeeder` (mise à jour des images/téléphones) tourne au
> premier lancement du Marketplace, une seule fois (drapeau `app_meta/marketplace_images`).
> Une fois exécuté chez toi, il ne re-tournera pas côté client.

### 2.5 Vérifications finales

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

---

## 3. Générer les binaires

```bash
# APK universel (le plus simple à partager)
flutter build apk --release
#   → build/app/outputs/flutter-apk/app-release.apk

# APK séparés par architecture (plus légers ; le client prend arm64 en général)
flutter build apk --release --split-per-abi
#   → app-armeabi-v7a-release.apk / app-arm64-v8a-release.apk / app-x86_64-release.apk

# App Bundle (obligatoire pour Google Play)
flutter build appbundle --release
#   → build/app/outputs/bundle/release/app-release.aab
```

Test rapide de l'APK release sur un appareil branché :

```bash
flutter install --release
```

---

## 4. Méthode A — APK en lien direct

1. `flutter build apk --release`
2. Envoie `app-release.apk` par Drive / WeTransfer / e-mail / WhatsApp.
3. Le client, sur son Android :
   - ouvre le lien, télécharge le `.apk` ;
   - au moment d'installer : **Paramètres → Applis → Accès spécial → Installer des applis inconnues** → autorise le navigateur / gestionnaire de fichiers ;
   - installe.

Limites : pas de suivi de version, pas de notif de MAJ, le fichier peut être bloqué par Gmail (le zipper ou passer par Drive).

---

## 5. Méthode B — GitHub Releases

### 5.1 Mettre le code sur GitHub (une fois)

Ce dossier **n'est pas encore un dépôt git**. Initialise-le :

```bash
cd "C:/Users/ZBOOK/Downloads/Dinari-Appv1.0.0-main/Dinari-Appv1.0.0-main"
git init
git add .
git commit -m "Initial commit: Dinari v1.0.0"
gh repo create dinari --private --source=. --push
#   (ou : créer le repo sur github.com puis)
#   git remote add origin https://github.com/<user>/dinari.git
#   git branch -M main && git push -u origin main
```

Vérifie que `build/`, `key.properties`, `*.jks` ne sont PAS poussés
(`git status` avant le premier commit).

### 5.2 Publier une release avec l'APK

```bash
flutter build apk --release
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "Dinari v1.0.0" \
  --notes "Première livraison. Installer en autorisant les sources inconnues."
```

Tu obtiens une URL type
`https://github.com/<user>/dinari/releases/tag/v1.0.0` → à envoyer au client.
Le lien direct de l'APK est `.../releases/download/v1.0.0/app-release.apk`.

### 5.3 Version suivante

```bash
# 1. incrémenter pubspec.yaml : version: 1.0.1+2
# 2. commit + tag
git commit -am "v1.0.1"
git tag v1.0.1 && git push --tags
# 3. build + release
flutter build apk --release
gh release create v1.0.1 build/app/outputs/flutter-apk/app-release.apk --title "Dinari v1.0.1" --notes "Corrections…"
```

---

## 6. Méthode C — Firebase App Distribution

Idéal : le client reçoit un e-mail, installe via l'appli **App Tester**, et est
notifié à chaque nouvelle version.

### 6.1 Préparer (une fois)

```bash
npm i -g firebase-tools
firebase login
```

Récupère l'**App ID Android** dans la console Firebase
(Paramètres du projet → Tes applications → App ID, format
`1:943125011642:android:xxxx…`). Dans ce repo il est déjà visible dans
`firebase.json` : `1:943125011642:android:8b78ad7e76265f74443683`.

Dans la console Firebase → **App Distribution** → onglet Testeurs → crée un groupe,
p. ex. `clients`, et ajoute l'e-mail du client.

### 6.2 Distribuer une version

```bash
flutter build apk --release

firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:943125011642:android:8b78ad7e76265f74443683 \
  --groups "clients" \
  --release-notes "Dinari v1.0.0 — première livraison"
```

Le client reçoit un mail → installe **Firebase App Tester** → accepte l'invitation →
télécharge. Les MAJ suivantes : relance la même commande, il est notifié.

---

## 7. Méthode D — GitHub Actions (build & publication automatiques)

Publie automatiquement un APK dans les Releases à chaque tag `v*`.

### 7.1 Secrets du dépôt

GitHub → repo → **Settings → Secrets and variables → Actions** → *New repository secret* :

| Secret | Contenu |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 dinari-release.jks` (le fichier encodé) |
| `KEYSTORE_PASSWORD` | mot de passe du keystore |
| `KEY_PASSWORD` | mot de passe de l'alias |
| `KEY_ALIAS` | `dinari` |
| `GOOGLE_SERVICES_JSON` | `base64 -w0 android/app/google-services.json` |

### 7.2 Workflow

`.github/workflows/release.yml` :

```yaml
name: Build & Release APK

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Restore secret files
        run: |
          echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 -d > android/app/google-services.json
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/dinari-release.jks
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=../dinari-release.jks
          EOF

      - run: flutter pub get
      - run: flutter build apk --release

      - name: Publish GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
          generate_release_notes: true
```

### 7.3 Déclencher

```bash
git tag v1.0.2 && git push --tags
```

→ Actions builde et crée la Release avec l'APK. Envoie l'URL au client.

---

## 8. Méthode E — Google Play Store

Nécessaire uniquement pour une diffusion publique / MAJ automatiques via le Store.

1. **Compte développeur** : play.google.com/console → 25 $ (paiement unique).
2. Créer l'application (nom, langue, catégorie).
3. Remplir les obligations : politique de confidentialité (URL), *Data safety*,
   classification du contenu, pays de diffusion, captures d'écran, icône 512×512,
   image de bannière 1024×500.
4. **Build signé** :
   ```bash
   flutter build appbundle --release
   ```
5. **Test interne** (le plus rapide) : Console → *Testing → Internal testing* →
   *Create new release* → upload `app-release.aab` → ajouter les testeurs par e-mail
   → partager le **lien d'opt-in**. Installation en ~minutes, pas de revue longue.
6. **Production** : *Production → Create new release* → upload l'AAB → revue Google
   (quelques heures à quelques jours) → disponible publiquement.
7. **Signature** : laisse activé *Play App Signing* (Google gère la clé finale ;
   ta clé d'upload sert juste à signer les envois).

MAJ : incrémente `version:` dans `pubspec.yaml` (le `+N` **doit** augmenter),
rebuild l'AAB, nouvelle release.

---

## 9. Gestion des versions

| Élément | Où | Règle |
|---|---|---|
| versionName (`1.0.1`) | `pubspec.yaml` avant le `+` | lisible par l'utilisateur |
| versionCode (`+7`) | `pubspec.yaml` après le `+` | **entier strictement croissant** à chaque livraison |
| tag git (`v1.0.1`) | `git tag` | déclenche la CI, sert d'historique |

Un client ne peut installer une MAJ « par-dessus » que si :
- même `applicationId`,
- **même clé de signature**,
- `versionCode` supérieur.

---

## 10. Checklist avant chaque livraison

- [ ] `applicationId` définitif (pas `com.example.*`)
- [ ] `compileSdk = 36`
- [ ] Signature **release** = keystore (pas debug)
- [ ] `key.properties` + `*.jks` **non commités**, keystore **sauvegardé ailleurs**
- [ ] `version:` incrémentée dans `pubspec.yaml`
- [ ] `google-services.json` correspond au bon projet Firebase
- [ ] Règles Firestore/Storage adaptées (pas en mode test ouvert)
- [ ] `flutter analyze` sans erreur, `flutter test` OK
- [ ] APK release testé sur un vrai appareil (`flutter install --release`)
- [ ] Clés Supabase (`lib/src/core/setting/app_setting.dart`) = projet voulu
- [ ] Note de version rédigée

---

## 11. Dépannage

| Symptôme | Cause / solution |
|---|---|
| `google_fonts … FontWeight … operator '=='` | garder `google_fonts: ^6.3.3` dans `pubspec.yaml` |
| `plugin requires Android SDK 36` | mettre `compileSdk = 36` dans `android/app/build.gradle.kts` |
| Build APK OK mais MAJ « paquet non compatible » chez le client | clé de signature différente → toujours signer avec le **même** keystore |
| Gmail bloque l'APK en pièce jointe | passer par Google Drive / WeTransfer / GitHub Releases |
| App ne démarre pas chez le client (`ErrorApp`) | `google-services.json` absent/incorrect, ou pas de réseau au premier lancement (Firebase/Supabase init) |
| `Could not launch phone dialer` sur l'émulateur | normal : l'émulateur n'a pas d'app Téléphone/Play ; tester sur un vrai appareil |
| Firestore `permission-denied` | ajuster les règles de sécurité (section 2.4) |

---

## 12. Résumé express

```bash
# préparer (une fois) : keystore + key.properties + signingConfig release + compileSdk 36

# à chaque livraison :
# 1. pubspec.yaml : version: X.Y.Z+N   (N croissant)
flutter clean && flutter pub get
flutter build apk --release            # build/app/outputs/flutter-apk/app-release.apk

# 2a. GitHub Releases
gh release create vX.Y.Z build/app/outputs/flutter-apk/app-release.apk --generate-notes

# 2b. OU Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:943125011642:android:8b78ad7e76265f74443683 --groups clients \
  --release-notes "vX.Y.Z"

# 3. envoyer l'URL au client
```
