---
name: sf-audit-copywriting
description: Audit copywriting & marketing — analyse le parcours client depuis le persona jusqu'à la conversion. Évalue la stratégie de persuasion (direct response, Tugan Bara), pas la qualité rédactionnelle.
argument-hint: [file-path | "global"] (omit for full project)
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Content collections: !`find src/content -type f 2>/dev/null | head -20 || echo "no content dir"`
- Pricing/checkout pages: !`find src -path "*pric*" -o -path "*checkout*" -o -path "*offre*" -o -path "*tarif*" 2>/dev/null | head -10 || echo "none found"`
- Email templates: !`find src -path "*email*" -o -path "*newsletter*" -o -path "*sequence*" 2>/dev/null | head -10 || echo "none found"`

## Distinction avec sf-audit-copy

| | audit-copy (rédactionnel) | audit-copywriting (ce skill) |
|---|---|---|
| Question | "Est-ce bien écrit ?" | "Est-ce que ça vend ?" |
| Focus | Voix, ton, grammaire, clarté | Persona, parcours, objections, conversion |
| Point de départ | Le texte | Le client cible |
| Mesure | Qualité linguistique | Efficacité persuasive |

Ne PAS refaire le travail de audit-copy. Ce skill suppose que le texte est correct. Il évalue la **stratégie**.

## Doctrine Direct Response

Ce skill évalue le copywriting à travers le prisme du **direct response marketing** (école Tugan Bara / Gary Halbert / Dan Kennedy). Principes fondamentaux :

1. **Le message est plus important que l'offre.** Le bon message devant la bonne personne = vente. Le mauvais message devant le bon persona = silence.
2. **Agressif ≠ manipulateur.** Agressif = direct, sans filtre, orienté action. Manipulateur = tromper pour vendre un truc qui ne sert à rien. Si le produit aide vraiment et que le copy ne convainc pas, c'est le copy qui est en tort — pas le prospect.
3. **Polariser pour filtrer.** Un copy qui plaît à tout le monde ne vend à personne. Repousser les mauvais prospects est aussi important qu'attirer les bons.
4. **Déconstruire avant de construire.** Le prospect a des croyances existantes qui le maintiennent dans l'inaction. Il faut les identifier et les démonter AVANT de présenter la solution.
5. **L'offre bat le produit.** Un produit seul est comparable. Une offre (produit + bonuses + garantie + framing) est incomparable.

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit tous les projets.
- **`$ARGUMENTS` is a file path** → PAGE MODE: audit une page.
- **`$ARGUMENTS` is empty** → PROJECT MODE: audit complet du projet.

---

## PAGE MODE

### Step 1: Comprendre la page dans le parcours

1. Lire la page cible.
2. Lire les pages qui **pointent vers** cette page (navigation, CTAs entrants).
3. Lire les pages vers lesquelles cette page **envoie** (CTAs sortants, liens).
4. Identifier le rôle dans le funnel : **Découverte** (TOFU) / **Considération** (MOFU) / **Décision** (BOFU) / **Rétention**.

### Step 2: Audit copywriting

Score chaque catégorie **A/B/C/D**. Standard : copywriter direct response senior spécialisé conversion.

#### 1. Alignement Persona
- [ ] Le persona cible est identifiable dès les 3 premières phrases
- [ ] Le vocabulaire est celui du persona (pas le jargon interne du produit)
- [ ] Le problème adressé est un vrai pain point du persona (pas une feature déguisée)
- [ ] Le niveau d'awareness est adapté : Unaware → Problem-aware → Solution-aware → Product-aware → Most aware (Schwartz)
- [ ] Le "tu" / "vous" est cohérent avec la relation souhaitée

#### 2. Big Idea & Mécanisme Unique
- [ ] Il y a une **Big Idea** — un concept central mémorable qui porte toute la page (pas juste un titre accrocheur)
- [ ] Le **mécanisme unique** est explicite : POURQUOI cette solution marche là où les autres échouent (le "comment" propriétaire)
- [ ] Le mécanisme unique donne de l'espoir — il explique pourquoi les échecs passés du prospect n'étaient pas de sa faute
- [ ] La Big Idea est assez forte pour tenir en une phrase et être répétable (test du "tu connais X ? c'est le truc qui...")
- [ ] Le mécanisme est crédible (expliqué, pas juste affirmé)

#### 3. Proposition de valeur & Offre
- [ ] Le bénéfice principal est exprimé en résultat pour le client, pas en features
- [ ] La promesse est crédible (ni exagérée, ni timorée)
- [ ] Le différenciateur vs alternatives est clair (pourquoi ici et pas ailleurs ?)
- [ ] La transformation promise (avant → après) est concrète et visuelle
- [ ] La preuve de la promesse est présente (data, témoignage, mécanisme expliqué)
- [ ] **C'est une OFFRE, pas juste un produit** — bonuses, packaging, naming qui rend l'offre incomparable
- [ ] **Value stacking** : chaque composant de l'offre a une valeur perçue individuelle, le total écrase le prix demandé
- [ ] Le prix est framé en valeur (ce que ça rapporte), pas en coût (ce que ça coûte)

#### 4. Structure de persuasion
- [ ] Le hook (titre + sous-titre) crée une tension ou une curiosité impossible à ignorer
- [ ] Le body suit un framework reconnaissable (PAS, AIDA, P.A.S.T.O.R., BAB, 4P, StoryBrand)
- [ ] Chaque section a un rôle clair dans la séquence de persuasion
- [ ] La montée en engagement est progressive (pas de "achète" dès le premier scroll)
- [ ] La longueur est adaptée au niveau d'awareness (plus unaware = plus long)
- [ ] Il y a de la **déconstruction de croyances** — les croyances qui maintiennent le prospect dans l'inaction sont identifiées et démontées
- [ ] La déconstruction vient AVANT la présentation de la solution (on casse l'ancien véhicule avant de proposer le nouveau)

#### 5. Agitation & Story Selling
- [ ] L'agitation va assez loin — le prospect RESSENT la douleur, pas juste il la lit
- [ ] L'agitation est spécifique au persona (scénarios concrets, pas des généralités)
- [ ] Il y a du **story selling** — la vente est enrobée dans un récit (pas un pitch sec)
- [ ] L'histoire est celle du persona ou d'un personnage dans lequel il se reconnaît (pas l'histoire du fondateur qui se regarde le nombril)
- [ ] La séquence émotionnelle est : douleur → compréhension → espoir → preuve → confiance → action
- [ ] L'empathie précède la solution (le persona se sent compris AVANT d'entendre la solution)

#### 6. Fascinations & Open Loops
- [ ] Il y a des **fascinations** — des bullet points qui créent une curiosité irrésistible sans révéler la réponse
- [ ] Format fascination respecté : "[chose spécifique inattendue] qui [résultat désirable]" (pas des bullets descriptives plates)
- [ ] Il y a des **open loops** — des tensions narratives ouvertes qui poussent à continuer la lecture
- [ ] Les pattern interrupts sont utilisés — ruptures de rythme, formats inattendus, affirmations contre-intuitives
- [ ] Les curiosity gaps fonctionnent : le lecteur sait que quelque chose existe mais ne sait pas QUOI → il doit continuer

#### 7. Traitement des objections
- [ ] Les 3-5 objections principales du persona sont adressées
- [ ] Les objections sont traitées AVANT le CTA principal (pas après)
- [ ] Le traitement est empathique ("on comprend que...") pas défensif ("mais non...")
- [ ] La preuve sociale répond aux objections spécifiques (pas juste "5000 clients")
- [ ] La réversibilité du risque est explicite (garantie, essai gratuit, pas d'engagement)
- [ ] La **garantie protège le statut**, pas juste l'argent — le prospect a peur de passer pour un idiot, pas juste de perdre 50 euros

#### 8. Polarisation & Identité tribale
- [ ] Le copy **prend position** — il y a un point de vue clair, pas un discours aseptisé corporate
- [ ] Il y a un **ennemi commun** identifié (pas un concurrent nommé — une catégorie, une approche, un statu quo)
- [ ] Le lecteur est invité à rejoindre un **groupe** (pas juste à acheter un produit) — identité tribale
- [ ] Le copy **repousse activement** les mauvais prospects (les gens pour qui ce n'est pas fait)
- [ ] Le positionnement est **contrarian** — il va à contre-courant de ce que tout le monde dit dans le marché

#### 9. Appels à l'action (stratégie, pas rédaction)
- [ ] Le CTA principal est aligné avec le niveau d'awareness de la page
- [ ] Le CTA propose la bonne prochaine étape (pas un saut trop grand)
- [ ] Il y a un CTA alternatif plus léger pour les indécis
- [ ] La friction perçue autour du CTA est minimisée (pas de formulaire monstre)
- [ ] Le CTA est positionné après la preuve, pas avant
- [ ] Il y a du **"Always Be Leaving"** — le prospect sent que l'offre pourrait disparaître (rareté, temps limité)
- [ ] Le scarcity/urgency est **authentique** — pas des fake timers, mais des raisons réelles de limiter

#### 10. Cohérence du parcours
- [ ] La promesse faite en amont (SEO, pub, nav) est tenue sur la page
- [ ] La transition vers la page suivante est fluide (pas de rupture de ton ou de promesse)
- [ ] Le message se renforce au fil du parcours (pas de contradiction entre pages)
- [ ] Les micro-engagements sont valorisés (newsletter, quiz, téléchargement)

### Step 3: Recommandations

Pour chaque catégorie notée B ou moins :
1. Diagnostic précis du problème
2. Recommandation stratégique (pas une réécriture — c'est le job de audit-copy)
3. Exemple de direction à prendre
4. Impact estimé sur la conversion : 🔴 fort / 🟠 moyen / 🟡 faible

### Step 4: Report

```
AUDIT COPYWRITING: [page]
─────────────────────────────────────
Persona cible identifié : [persona]
Position funnel : [TOFU/MOFU/BOFU/Rétention]
Niveau awareness : [Schwartz level]
─────────────────────────────────────
Alignement Persona       [A/B/C/D]
Big Idea & Mécanisme     [A/B/C/D]
Proposition & Offre      [A/B/C/D]
Structure persuasion     [A/B/C/D]
Agitation & Story        [A/B/C/D]
Fascinations & Loops     [A/B/C/D]
Objections               [A/B/C/D]
Polarisation & Tribu     [A/B/C/D]
Appels à l'action        [A/B/C/D]
Cohérence parcours       [A/B/C/D]
─────────────────────────────────────
OVERALL                  [A/B/C/D]

Recommandations stratégiques : X
Impact conversion estimé : [fort/moyen/faible]
```

---

## PROJECT MODE

### Workspace root detection

Si le répertoire courant n'a pas de marqueurs projet mais contient des sous-répertoires — on est au **workspace root**.

Utiliser **AskUserQuestion** :
- Question : "Quel(s) projet(s) auditer en copywriting ?"
- `multiSelect: true`
- Options depuis `/home/claude/shipglows_data/PROJECTS.md`

Puis passer en **GLOBAL MODE**.

### Phase 1 : Définir le Persona

Avant toute analyse, extraire ou construire le persona depuis le projet :

1. Chercher des docs existants : `docs/copywriting/persona.md`, ou `persona*`, `avatar*`, `icp*`, `target*`
2. Si un persona existe déjà, le présenter à l'utilisateur pour validation — ne pas repartir de zéro
3. Sinon, analyser CLAUDE.md et la homepage pour déduire le persona
4. Documenter :
   - **Qui** : démographie, situation, identité
   - **Douleur** : le problème #1 qui l'amène ici
   - **Désir** : ce qu'il veut vraiment (pas le produit — le résultat)
   - **Objections** : ses 3-5 raisons de ne pas agir
   - **Déclencheur** : qu'est-ce qui l'amène aujourd'hui (pas hier, pas demain)
   - **Alternatives** : que fait-il s'il ne choisit pas ce produit ?
   - **Croyances à déconstruire** : quelles croyances le maintiennent dans l'inaction ou attaché à une solution concurrente ? Quel "véhicule" utilise-t-il actuellement pour résoudre son problème ?
   - **Identité tribale** : à quel groupe veut-il appartenir ? Contre quoi/qui se définit-il ?

Utiliser **AskUserQuestion** pour valider le persona avec l'utilisateur avant de continuer.

### Phase 2 : Cartographier le parcours client

Mapper TOUTES les pages du site sur le parcours client :

```
DÉCOUVERTE (TOFU)         CONSIDÉRATION (MOFU)      DÉCISION (BOFU)         RÉTENTION
─────────────────         ────────────────────      ─────────────           ─────────
[pages SEO/blog]    →     [pages features]     →   [pricing/offre]    →   [dashboard]
[landing pages]     →     [témoignages]        →   [checkout]         →   [emails]
[homepage]          →     [comparatifs]        →   [inscription]      →   [communauté]
```

Identifier :
- **Trous dans le funnel** : étapes sans page dédiée
- **Culs-de-sac** : pages sans CTA vers l'étape suivante
- **Sauts** : pages qui passent de TOFU à BOFU sans MOFU
- **Pages orphelines** : du contenu sans lien dans le parcours

### Phase 3 : Analyse par étape du funnel

Pour chaque étape du parcours, évaluer les pages regroupées :

**TOFU — Découverte** :
- Le contenu attire les bonnes personnes ? (pas juste du trafic)
- Le pain point est-il validé dès l'arrivée ?
- Y a-t-il un hook vers l'étape suivante ?
- Y a-t-il des **pattern interrupts** qui cassent le scroll autopilote ?
- Le contenu **polarise** — il prend position et filtre les bons prospects ?

**MOFU — Considération** :
- La solution est-elle présentée comme LA réponse au pain point ?
- La preuve sociale est-elle adaptée au persona ?
- Les objections sont-elles traitées ici ?
- Y a-t-il de la **déconstruction de croyances** — les alternatives du prospect sont-elles démontées ?
- Le **mécanisme unique** est-il révélé ici (pourquoi CETTE solution) ?
- Y a-t-il du **story selling** (cas clients narratifs, pas juste des bullet points) ?

**BOFU — Décision** :
- Le pricing est-il framé en valeur (pas en coût) ?
- L'offre a-t-elle du **value stacking** (bonuses, composants détaillés avec valeurs individuelles) ?
- La friction du checkout est-elle minimale ?
- L'urgence est-elle authentique (pas des fake timers) ?
- La **garantie protège le statut** du prospect, pas juste son portefeuille ?
- Y a-t-il des **fascinations** dans la description de l'offre (curiosité sur ce qui est inclus) ?

**Rétention** :
- Le onboarding tient-il la promesse marketing ?
- Le persona retrouve-t-il le vocabulaire qu'il a vu avant l'inscription ?

### Phase 4 : Stratégie de conversion globale

Évaluer la stratégie d'ensemble :

1. **Big Idea & Mécanisme Unique** : y a-t-il UN concept central qui porte tout le site ? Le mécanisme unique est-il clair et propriétaire ?
2. **Cohérence promesse ↔ produit** : le marketing promet-il ce que le produit délivre ?
3. **Positionnement contrarian** : le produit est-il clairement différencié ? Prend-il une position à contre-courant du marché ? Ou dit-il la même chose que tout le monde ?
4. **Architecture de l'offre** : est-ce un produit nu ou une offre structurée (produit + bonuses + garantie + naming) ? Y a-t-il un **value ladder** (offre d'entrée → montée en gamme) ?
5. **Pricing psychology** : ancrage, decoy, framing, value stacking — utilisés correctement ?
6. **Trust signals** : suffisants à chaque point de friction ?
7. **Content-market fit** : le contenu attire-t-il le persona ou des curieux sans intention ?
8. **Polarisation & tribu** : le site crée-t-il une identité de groupe ? Y a-t-il un ennemi commun ? Le mauvais prospect est-il repoussé ?
9. **Déconstruction des croyances** : le parcours attaque-t-il les croyances qui empêchent l'action avant de vendre ?

### Phase 5 : Audit Email & Séquences

Si le projet a des emails marketing, des séquences automatisées, ou une newsletter :

1. **Capture d'email** : y a-t-il un lead magnet ? Attire-t-il des prospects qualifiés (pas juste des chasseurs de gratuit) ?
2. **Séquence de préchauffage** : les premiers emails construisent-ils la relation et l'autorité avant de vendre ?
3. **Séquence de vente** : y a-t-il une montée en pression avec urgence/rareté authentique ?
4. **Séquence de relance** : les non-acheteurs sont-ils relancés avec un angle différent ?
5. **Fréquence d'envoi** : suffisante pour rester top-of-mind ? (sous-envoyer est pire que sur-envoyer)
6. **Un email = une idée** : chaque email a un seul objectif clair ?
7. **Open loops entre emails** : les emails créent-ils des cliffhangers qui donnent envie d'ouvrir le suivant ?
8. **Subjects lines** : utilisent-ils des curiosity gaps ? Sont-ils testés et variés ?

Si pas d'emails : **recommander en priorité** la mise en place d'une capture email + séquence. Le trafic qu'on ne capture pas est du trafic perdu.

### Phase 6 : Recommandations prioritisées

Produire un plan d'action par impact sur la conversion :

| Pri | Recommandation | Pages impactées | Impact estimé |
|-----|---------------|-----------------|---------------|
| 🔴 | [action stratégique] | [pages] | Fort — [raison] |
| 🟠 | [action] | [pages] | Moyen — [raison] |
| 🟡 | [action] | [pages] | Faible — [raison] |

Règle : les recommandations sont **stratégiques** (quoi changer et pourquoi), pas **rédactionnelles** (comment réécrire). La réécriture est le job de l'utilisateur ou de audit-copy.

### Phase 7 : Report

```
AUDIT COPYWRITING: [project name]
═══════════════════════════════════════

PERSONA
  Qui : [description courte]
  Douleur : [pain point #1]
  Désir : [résultat souhaité]
  Objections : [top 3]
  Croyances à casser : [croyances qui bloquent l'action]
  Tribu : [identité de groupe visée]

BIG IDEA & MÉCANISME UNIQUE
  Big Idea : [concept central — ou ABSENT]
  Mécanisme : [ce qui rend la solution unique — ou ABSENT]
  Déconstruction : [croyances attaquées — ou ABSENTE]

PARCOURS CLIENT
  Découverte   [X pages]  [A/B/C/D]
  Considération [X pages]  [A/B/C/D]
  Décision     [X pages]  [A/B/C/D]
  Rétention    [X pages]  [A/B/C/D]

  Trous funnel : [X]
  Culs-de-sac : [X]
  Pages orphelines : [X]

STRATÉGIE DE CONVERSION
  Big Idea & Mécanisme         [A/B/C/D]
  Cohérence promesse/produit   [A/B/C/D]
  Positionnement contrarian    [A/B/C/D]
  Architecture de l'offre      [A/B/C/D]
  Pricing psychology           [A/B/C/D]
  Trust signals                [A/B/C/D]
  Content-market fit           [A/B/C/D]
  Polarisation & tribu         [A/B/C/D]
  Déconstruction croyances     [A/B/C/D]

EMAIL & SÉQUENCES
  Capture email      [A/B/C/D ou N/A]
  Séquences          [A/B/C/D ou N/A]
  Fréquence & loops  [A/B/C/D ou N/A]

═══════════════════════════════════════
OVERALL                       [A/B/C/D]

Recommandations : X (🔴 Y critical, 🟠 Z high, 🟡 W medium)
Top 3 quick wins conversion :
  1. [action] → [impact]
  2. [action] → [impact]
  3. [action] → [impact]
```

### Phase 8 : Persister les livrables

Sauvegarder les analyses dans `docs/copywriting/` à la racine du projet. Ces fichiers servent de **référence partagée** pour les autres skills (audit-copy, audit-seo, enrich, market-study, etc.).

Créer le dossier si absent : `mkdir -p docs/copywriting`

#### `docs/copywriting/persona.md`

```markdown
# Persona — [Nom du persona]

> Dernière mise à jour : [date]
> Généré par : /sg-audit-copywriting

## Identité
- **Qui** : [démographie, situation, identité]
- **Contexte** : [ce qui se passe dans sa vie]

## Psychologie
- **Douleur #1** : [le problème qui l'amène]
- **Désir profond** : [ce qu'il veut vraiment — pas le produit]
- **Déclencheur** : [pourquoi aujourd'hui et pas hier]

## Objections
1. [objection principale]
2. [objection #2]
3. [objection #3]
4. [objection #4 si pertinent]
5. [objection #5 si pertinent]

## Croyances à déconstruire
- **Croyance actuelle** : [ce que le prospect croit aujourd'hui]
- **Véhicule actuel** : [la solution qu'il utilise à cause de cette croyance]
- **Déconstruction** : [pourquoi cette croyance est fausse ou incomplète]
- **Nouveau véhicule** : [pourquoi notre solution est le bon véhicule]

## Identité tribale
- **Groupe d'appartenance** : [à quelle tribu le persona veut appartenir]
- **Ennemi commun** : [contre quoi/qui se définit cette tribu — pas un concurrent, une catégorie ou un statu quo]
- **Vocabulaire tribal** : [mots et expressions qui signalent l'appartenance]

## Alternatives
- [ce qu'il fait s'il ne choisit pas ce produit]

## Niveau d'awareness (Schwartz)
- **Entrée typique** : [Unaware / Problem-aware / Solution-aware / Product-aware]
- **Cible sortie** : [Most aware → conversion]

## Vocabulaire du persona
- [mots et expressions qu'il utilise pour parler de son problème]
- [termes à utiliser dans le copy — pas notre jargon]
```

#### `docs/copywriting/parcours-client.md`

```markdown
# Parcours Client — [Projet]

> Dernière mise à jour : [date]

## Funnel

| Étape | Pages | Score | Diagnostic |
|-------|-------|-------|------------|
| Découverte (TOFU) | [liste pages] | [A/B/C/D] | [résumé] |
| Considération (MOFU) | [liste pages] | [A/B/C/D] | [résumé] |
| Décision (BOFU) | [liste pages] | [A/B/C/D] | [résumé] |
| Rétention | [liste pages] | [A/B/C/D] | [résumé] |

## Problèmes de parcours
- **Trous** : [étapes sans page]
- **Culs-de-sac** : [pages sans CTA sortant]
- **Sauts** : [TOFU → BOFU sans MOFU]
- **Orphelines** : [pages hors parcours]

## Flux de conversion principal
[page entrée] → [page 2] → [page 3] → [conversion]
```

#### `docs/copywriting/strategie.md`

```markdown
# Stratégie Copywriting — [Projet]

> Dernière mise à jour : [date]

## Big Idea & Mécanisme Unique
- **Big Idea** : [le concept central en une phrase — ou ABSENT]
- **Mécanisme unique** : [ce qui rend la solution propriétaire — ou ABSENT]
- **Croyance déconstruite** : [la croyance cassée pour légitimer le mécanisme]

## Positionnement
- **Promesse principale** : [en une phrase]
- **Différenciateur** : [pourquoi ici et pas ailleurs]
- **Transformation** : [avant → après]
- **Position contrarian** : [en quoi on va à contre-courant du marché]
- **Ennemi commun** : [le statu quo ou l'approche que la tribu rejette]

## Architecture de l'offre
- **Type** : [produit nu / offre structurée / value ladder]
- **Composants** : [produit + bonuses + garantie — ou juste un prix]
- **Value stacking** : [présent / absent — détail si présent]
- **Upsells / OTO** : [présent / absent]

## Scores

| Dimension | Score | Diagnostic |
|-----------|-------|------------|
| Big Idea & Mécanisme | [A/B/C/D] | [résumé] |
| Cohérence promesse/produit | [A/B/C/D] | [résumé] |
| Positionnement contrarian | [A/B/C/D] | [résumé] |
| Architecture de l'offre | [A/B/C/D] | [résumé] |
| Pricing psychology | [A/B/C/D] | [résumé] |
| Trust signals | [A/B/C/D] | [résumé] |
| Content-market fit | [A/B/C/D] | [résumé] |
| Polarisation & tribu | [A/B/C/D] | [résumé] |
| Déconstruction croyances | [A/B/C/D] | [résumé] |

## Recommandations prioritisées

| Pri | Action | Pages | Impact |
|-----|--------|-------|--------|
| 🔴 | [action] | [pages] | [impact] |
| 🟠 | [action] | [pages] | [impact] |
| 🟡 | [action] | [pages] | [impact] |

## Quick wins
1. [action] → [impact attendu]
2. [action] → [impact attendu]
3. [action] → [impact attendu]
```

**Règles de persistance :**
- Si les fichiers existent déjà, les **mettre à jour** (pas les écraser complètement — garder l'historique avec la date)
- Les autres skills doivent lire ces fichiers quand ils existent : `docs/copywriting/persona.md` est la source de vérité persona pour tout le projet
- Ne pas dupliquer le contenu du report dans ces fichiers — le report va dans AUDIT_LOG.md, les fichiers sont la **référence vivante**

---

## GLOBAL MODE

1. Lire `/home/claude/shipglows_data/PROJECTS.md`. Identifier les projets avec site web.

2. **AskUserQuestion** : "Quels projets auditer en copywriting ?" — `multiSelect: true`.

3. Lancer un agent par projet sélectionné (en parallèle). Chaque agent exécute le PROJECT MODE complet.

4. Compiler un rapport cross-projet :
   ```
   GLOBAL COPYWRITING AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project]  [A/B/C/D] — [persona] — [top issue]
     ...
   CROSS-PROJECT PATTERNS
     [Patterns communs entre projets]
   TOP 5 ACTIONS CONVERSION
     1. 🔴 [project] — [action] → [impact]
     ...
   ═══════════════════════════════════════
   ```

5. Mettre à jour AUDIT_LOG.md et TASKS.md.

---

## Tracking (all modes)

### Log the audit

Append à :
1. **Global `/home/claude/shipglows_data/AUDIT_LOG.md`** : remplir la colonne Copywriting.
2. **Local `./AUDIT_LOG.md`** : idem sans la colonne Project.

### Update TASKS.md

1. **Local TASKS.md** : ajouter `### Audit: Copywriting` avec les recommandations comme tâches.
2. **Master `/home/claude/shipglows_data/TASKS.md`** : même chose dans la section du projet.

---

## Important (all modes)

- **Partir du persona, pas du produit.** Toujours. Le persona d'abord, le produit ensuite.
- **Agressif = bien. Manipulateur = F.** Être direct, polarisant, provocateur, prendre position = encouragé. Mentir, inventer des faux témoignages, des fake timers, des dark patterns = note F automatique. La ligne est claire : le produit doit délivrer ce que le copy promet.
- **Population vulnérable = éthique renforcée.** Si le produit s'adresse à des personnes en souffrance (santé, addiction, deuil), le copywriting doit être empathique et honnête. On peut agiter la douleur, mais jamais exploiter la détresse. Jamais de promesses irréalistes sur des sujets de santé.
- Les recommandations sont stratégiques, pas rédactionnelles. Dire "il faut déconstruire la croyance que [X] avant de présenter le mécanisme unique", pas "réécrivez ce paragraphe comme ça".
- Détecter la langue automatiquement. Auditer dans cette langue.
- **Accents français obligatoires.** Lors de toute création ou modification de contenu en français, vérifier systématiquement que TOUS les accents sont présents et corrects (é, è, ê, à, â, ù, û, ô, î, ï, ç, œ, æ). Les accents manquants sont une faute d'orthographe.
