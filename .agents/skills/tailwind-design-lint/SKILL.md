---
name: tailwind-design-lint
description: Applique le lint design system Tailwind de ShipGlows quand on édite des classes Vue, JSX ou TS. À utiliser pour les classes Tailwind, les composants et les tokens des sites et extensions.
---

# Lint Tailwind

Les fronts web et les extensions ShipGlows sont en Tailwind 4. `@shadcn/lint` vérifie le design system via ESLint. Oxlint ne lit pas les templates Vue. Le markup `.astro` n'est pas couvert.

Règles en erreur :

- `shadcn/no-arbitrary-values`
- `shadcn/no-raw-colors`
- `shadcn/no-inline-styles`
- `shadcn/no-unknown-classes`

`no-restyle` n'est pas activé.

Écrire les classes avec les tokens du thème et les variants déjà prévus. Ne pas ajouter de couleur de palette brute, de valeur arbitraire ou de style inline pour dépanner une mise en page. Sans `components.json`, le thème est la feuille qui importe `tailwindcss`.

Lancer ESLint depuis le package qui possède `eslint.config.*`. Ne pas lancer un lint de tout le repo sauf demande explicite.
