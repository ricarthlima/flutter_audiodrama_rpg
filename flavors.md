## Configurando ambientes firebase
### Produção:
```
flutterfire configure
```

### Dev:
```
flutterfire configure --project=adrpg-dev --android-package-name com.adrpg.dev --ios-bundle-id com.adrpg.dev --out lib/firebase_options_dev.dart
```

## Rodar e buildar:
```
# Dev
flutter run  --flavor dev  --dart-define=FLAVOR=dev
flutter build apk  --flavor dev  --dart-define=FLAVOR=dev
flutter build ios  --flavor dev  --dart-define=FLAVOR=dev

# Prod (o que você já usa)
flutter run  --flavor prod --dart-define=FLAVOR=prod
flutter build apk  --flavor prod --dart-define=FLAVOR=prod
flutter build ios  --flavor prod --dart-define=FLAVOR=prod
```