# StickerControl

App Flutter (Android) para uma pequena empresa de adesivos calcular orçamentos
no celular: material, comprimento, largura e percentual de acréscimo. Os dados
ficam só no aparelho, sem login nem servidor.

## Estrutura

- `lib/ui` — telas e widgets
- `lib/logic` — regras e cálculo de preço (funções puras)
- `lib/data` — persistência local (Drift/SQLite)

## Rodando

O código gerado pelo Drift (`lib/data/app_database.g.dart`) não é versionado.
Gere-o depois de clonar e sempre que mudar as tabelas:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Depois:

```bash
flutter run
flutter test
flutter analyze
```

## Licença

[MIT](LICENSE)
