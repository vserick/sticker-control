# Sticker Control

App Flutter (Android) para uma pequena empresa de adesivos calcular orçamentos
no celular: material, comprimento, largura e percentual de acréscimo. Os dados
ficam só no aparelho, sem login nem servidor.

## Estrutura

- `lib/ui` — telas e widgets
- `lib/logic` — regras e cálculo de preço (funções puras)
- `lib/data` — persistência local (Drift/SQLite)

## Rodando

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

## Licença

[MIT](LICENSE)
