---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-29"
created_at: "2026-08-29 02:23:20 UTC"
updated: "2026-08-29"
updated_at: "2026-08-29 02:26:18 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5
scope: linux-vm-pressure-rescue-public-tutorial
owner: Diane
user_story: "En tant que fondatrice ou développeuse qui héberge ses projets sur une petite VM Linux, je veux comprendre pourquoi la machine rame et comment la récupérer sans tuer mes sessions ou mes services au hasard, afin de reprendre le travail avec une méthode simple et prudente."
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
content_surfaces:
  - indexed_articles
linked_systems:
  - shipglows_data/workflow/specs/linux-cli-resource-pressure-rescue.md
  - shipglows_data/editorial/blog-and-article-surface-policy.md
  - shipglows_data/editorial/claim-register.md
  - site/src/content/articles/en/
  - site/src/content/articles/fr/
  - site/src/content.config.ts
depends_on:
  - artifact: "shipglows_data/workflow/specs/linux-cli-resource-pressure-rescue.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.16.2"
    required_status: draft
  - artifact: "shipglows_data/editorial/blog-and-article-surface-policy.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/editorial/claim-register.md"
    artifact_version: "1.5.2"
    required_status: reviewed
supersedes: []
evidence:
  - "Observed incident on 2026-08-26: a 2 vCPU/4 GB VM became nearly unusable with 2 GB swap at 100%, extreme memory PSI, and two detached Vercel CLI processes consuming about 1.9 GB RAM and 1.2 GB swap."
  - "Verified implementation commit c101bd7 classifies combined RAM/swap/PSI pressure and offers a confirmed, fail-closed rescue for known detached Vercel CLI groups while protecting Codex, SSH, tmux, shells, and application services."
  - "The live post-activation diagnostic reported pressure ok, swap 39%, memory PSI 0.00/0.00, zero eligible orphan groups, and expected runtime ownership."
  - "Linux kernel PSI documentation defines some/full stall ratios and avg10/avg60/avg300 windows; /proc documentation defines process status, PPid, process group, TTY, RSS, and swap fields."
next_step: "/102-sg-start Linux VM pressure rescue public tutorial"
---

# Spec: Linux VM pressure rescue public tutorial

🟢 [ShipGlows] spec: Linux VM pressure rescue public tutorial | status: ready | path: shipglows_data/workflow/specs/linux-vm-pressure-rescue-public-tutorial.md | next: /102-sg-start Linux VM pressure rescue public tutorial

## Title

Linux VM pressure rescue public tutorial

## Status

ready

## User Story

En tant que fondatrice ou développeuse qui héberge ses projets sur une petite VM Linux, je veux comprendre pourquoi la machine rame et comment la récupérer sans tuer mes sessions ou mes services au hasard, afin de reprendre le travail avec une méthode simple et prudente.

## Minimal Behavior Contract

Quand une lectrice ouvre le tutoriel français ou anglais, elle comprend la différence entre RAM disponible, swap utilisé et pression PSI, suit un diagnostic en lecture seule qui ne révèle pas les arguments des processus, reconnaît les situations où elle ne doit rien tuer, puis découvre le parcours guidé `Health -> Emergency rescue` de ShipGlows. Les deux langues doivent transmettre la même promesse, les mêmes limites et les mêmes preuves. Si une affirmation ne repose pas sur le noyau Linux, le comportement vérifié de ShipGlows ou l'incident anonymisé, elle est supprimée ou explicitement qualifiée.

## Success Behavior

- Preconditions: la collection Astro `articles` et ses routes `/blog` et `/fr/blog` existent; la capacité CLI décrite est livrée et vérifiée.
- Trigger: une lectrice cherche pourquoi une petite VM Linux rame ou comment la récupérer sans expertise système.
- User result: elle peut observer les métriques utiles, éviter un arrêt aveugle, et décider si le parcours ShipGlows correspond à son besoin.
- System effect: deux brouillons Markdown liés par un `articleKey` commun sont ajoutés à la collection officielle, sans publication.
- Success proof: parité FR/EN, schéma Astro, liens, build et rubric éditoriale passent; les claims correspondent aux sources.
- Silent success: interdit; le rapport doit nommer les deux brouillons et leur état non publié.

## Error Behavior

- PSI absent: le tutoriel explique que certains noyaux ne l'exposent pas et conserve un diagnostic RAM/swap sans présenter cette absence comme une panne.
- Swap utilisé mais pression active nulle: le tutoriel interdit de conclure à une urgence sur ce seul signal.
- Processus inconnu ou service actif: aucune instruction d'arrêt n'est donnée; la lectrice est invitée à conserver le processus et à approfondir le diagnostic.
- Processus éligible dans ShipGlows: le texte précise qu'il est revalidé, affiché sans arguments complets et arrêté uniquement après confirmation.
- Must never happen: publier une IP, un chemin privé, un token, des arguments de commande sensibles, une promesse de sécurité absolue, une économie garantie, une compatibilité universelle ou un `kill -9` générique.
- Silent failure: interdit; tout échec de parité, métadonnées, build ou claim maintient les articles en brouillon non prêt.

## Problem

Une petite VM peut devenir presque inutilisable alors que la RAM seule n'explique pas clairement la situation. Une utilisatrice non spécialiste peut confondre swap historique et pression active, inspecter des lignes de commande contenant des secrets ou tuer le mauvais processus. La capacité ShipGlows livrée répond à ce problème, mais son intérêt public n'est pas encore expliqué.

## Solution

Créer un tutoriel bilingue, fondé sur l'incident réel anonymisé, qui enseigne un diagnostic prudent avant de montrer comment ShipGlows réduit la charge cognitive avec une alerte et un sauvetage guidé. Le contenu reste pédagogique avant d'être promotionnel et utilise un CTA vers les pages publiques ShipGlows existantes.

## Scope In

- Spec et Claim Impact Plan du tutoriel.
- Brouillon français: `site/src/content/articles/fr/comment-sauver-une-petite-vm-linux-qui-rame.md`.
- Brouillon anglais: `site/src/content/articles/en/how-to-rescue-a-small-linux-vm-that-is-slow.md`.
- Métadonnées partagées: `articleKey: linux-vm-pressure-rescue`, locales, slugs croisés, tags, date, état `draft: true` et temps de lecture cohérent.
- Incident anonymisé, explication RAM/swap/PSI, diagnostic sans arguments de processus, erreurs à éviter, parcours ShipGlows et limites.
- Correction durable du précédent verdict éditorial pour lier la capacité technique à ce tutoriel.
- Worktree isolé de `shipglows_app` depuis `origin/main`, branche locale `codex/linux-vm-rescue-tutorial`.

## Scope Out

- Publication, push, pull request, déploiement ou changement de l'état `draft`.
- Nouveau CMS, RSS, recherche, analytics, newsletter, landing page, FAQ ou page produit.
- Modification de la CLI, de la VM, des seuils de pression ou des signatures de processus.
- Benchmark, comparaison d'hébergeurs, prix Hetzner, dimensionnement universel ou promesse de réduction de coûts.
- Guide exhaustif d'administration Linux ou commandes destructives génériques.

## Constraints

- La surface publique exige une paire FR/EN atomique et source-faithful.
- Le checkout principal `shipglows_app` est sale et sur une autre branche; toutes les écritures site restent dans le worktree isolé.
- Le contenu n'affiche jamais les arguments complets des processus, une IP, un chemin privé ou une donnée d'incident identifiable.
- Les valeurs de l'incident sont présentées comme un cas observé, pas comme des seuils universels.
- `swap used` seul ne prouve pas une pression active; PSI peut être absent.
- La formulation décrit des garde-fous vérifiés sans garantir qu'aucun mauvais processus ne pourra jamais être arrêté.
- Le résultat est committé localement dans ses dépôts respectifs et n'est pas poussé.

## Dependencies

- Runtime: collection Astro `articles`, routes bilingues et dépendances déjà installées dans `shipglows_app`.
- Document contracts: spec technique `1.3.0`, content map `0.16.2`, article policy `1.2.0`, claim register `1.5.2`.
- External truth: documentation officielle actuelle du noyau Linux pour PSI et `/proc`.
- Metadata gaps: aucune; le schéma accepte tous les champs requis.

## Invariants

- Les deux locales partagent une identité et une force de claim équivalentes.
- Le diagnostic manuel reste en lecture seule jusqu'à une décision humaine explicite.
- Le tutoriel ne transforme pas une capacité bornée en promesse de sécurité, disponibilité, économies ou compatibilité universelle.
- Les modifications sans rapport dans les deux dépôts restent intactes et hors commits.
- Un commit ou un build local ne signifie ni publication ni déploiement.

## Links & Consequences

- Upstream: incident et spec `linux-cli-resource-pressure-rescue`, documentation runtime, documentation officielle Linux.
- Downstream: index `/blog`, index `/fr/blog`, routes d'article dynamiques et moteurs de recherche après publication future.
- Cross-cutting checks: i18n, métadonnées, claims sécurité/fiabilité, confidentialité des diagnostics, SEO de base, liens internes et build Astro.

## Documentation Coherence

- Ajouter cette spec comme source de vérité du contenu.
- Ajouter une note de correction à la spec technique: le code était livré, mais la conclusion `editorial not impacted` est remplacée par un suivi public borné.
- Ne pas modifier le claim register si le Claim Impact Plan de cette spec suffit à borner la rédaction; l'étendre seulement si une nouvelle famille de claim durable apparaît.

## Editorial Update Plan

- Surface: paire d'articles indexés FR/EN.
- Audience: fondatrices, développeuses solo et petites équipes exploitant une VM Linux économique sans expertise d'administration système.
- Reader job: retrouver une machine utilisable sans tuer ses sessions ou services au hasard.
- Promise: comprendre la pression réelle puis utiliser un sauvetage guidé et confirmé lorsque ShipGlows reconnaît un outil orphelin.
- Primary CTA: découvrir le workflow ShipGlows ou son installation publique existante.
- Internal links: page docs de la locale et dépôt GitHub public; aucun nouveau parcours commercial.

## Claim Impact Plan

- Claim: ShipGlows combine RAM disponible, swap et PSI pour signaler une pression mémoire et propose un sauvetage manuel de groupes Vercel CLI orphelins strictement reconnus.
- Claim family: security, automation, availability.
- Affected surfaces: deux articles de la collection publique.
- Evidence: commit `c101bd7`, 21 tests ciblés, activation distante avec hash/syntaxe, diagnostic live non destructif, spec technique revue.
- Status: allowed with caveat.
- Allowed wording: décrire les critères, confirmations, protections connues et comportement fail-closed vérifiés; employer `réduit le risque` ou `refuse les groupes inconnus`, jamais `garantit la sécurité`.
- Required action: publier uniquement les capacités livrées; conserver les limites noyau, signature et confirmation.
- Stop condition: claim plus fort que la preuve, détail privé, fausse équivalence swap/pression, ou implication d'arrêt automatique.

## Edge Cases

- PSI non disponible, fichier illisible ou valeur inconnue.
- Swap non configuré, historiquement utilisé, presque plein ou plein.
- RAM saine avec swap utilisé et PSI nul.
- Processus lourd mais interactif, encore parenté, appartenant à un autre utilisateur, inconnu ou mélangé à un service.
- Lectrice qui copie une commande sans comprendre PID/PGID; le texte ne fournit aucune recette de signal large.
- Locale manquante, `articleKey` divergent, `alternateSlug` incorrect ou état draft différent.
- Liens internes localisés erronés ou texte français/anglais littéralement traduit au détriment de la clarté.

## ZOMBIES Coverage

- Z: aucun PSI, aucun swap ou aucun candidat; diagnostic utile et aucune action.
- O: un groupe Vercel CLI détaché confirmé; parcours de récupération expliqué sans automatiser l'arrêt.
- M: plusieurs processus ou groupe mixte; le tutoriel explique pourquoi ShipGlows protège le groupe entier.
- B: swap élevé avec PSI nul versus PSI `full` élevé; ne pas confondre trace historique et thrashing actif.
- I: limites entre noyau Linux, commandes de diagnostic, logique ShipGlows et décision humaine explicites.
- E: métrique absente, identité de processus changée, syntaxe ou parité cassée; aucun verdict prêt.
- S: un seul tutoriel bilingue et un seul parcours lecteur, sans créer une nouvelle surface éditoriale.

## Implementation Tasks

- [ ] Task 1: Créer et valider le contrat éditorial
  - Files: cette spec et la note de correction dans `linux-cli-resource-pressure-rescue.md`.
  - Action: rendre audience, promesse, preuves, claims, locales, fichiers, CTA et limites décision-complets.
  - User story link: empêcher qu'un tutoriel utile devienne une promesse technique exagérée.
  - Depends on: gouvernance éditoriale et spec technique revues.
  - Validate with: metadata lint et revue adversariale de readiness.
  - Constraints: aucun changement runtime ou public pendant cette tâche.

- [ ] Task 2: Préparer une surface d'écriture isolée
  - Files: worktree local `shipglows-app-linux-vm-rescue-tutorial` sur `codex/linux-vm-rescue-tutorial`.
  - Action: partir de `origin/main` à jour sans toucher au checkout principal sale.
  - User story link: produire le contenu sans mélanger d'autres travaux.
  - Depends on: Task 1 ready.
  - Validate with: branche/base, statut propre et chemins absents avant création.
  - Constraints: aucun push, reset, merge, rebase ou suppression de worktree.

- [ ] Task 3: Rédiger la paire FR/EN
  - Files: les deux chemins d'article déclarés dans Scope In.
  - Action: créer les frontmatters liés et les corps locale-native avec le même plan, les mêmes preuves et les mêmes limites.
  - User story link: rendre le diagnostic et la récupération accessibles dans les deux langues publiques.
  - Depends on: Tasks 1-2.
  - Validate with: lint de parité ciblé, revue de fidélité et rubric de contenu.
  - Constraints: `draft: true`, aucun détail privé, aucune commande destructive aveugle.

- [ ] Task 4: Vérifier et persister localement
  - Files: uniquement la spec/correction dans Core et la paire d'articles dans le site.
  - Action: exécuter métadonnées, parité, Astro check/build, revue de claims et liens; créer des commits locaux exacts.
  - User story link: fournir un brouillon relisible et récupérable sans le publier.
  - Depends on: Tasks 1-3.
  - Validate with: commandes du Test Contract et inspection des fichiers indexés.
  - Constraints: aucun push, PR, publication ou déploiement; fichiers sans rapport exclus.

## Acceptance Criteria

- [ ] AC 1: Given la surface publique bilingue, when le tutoriel est créé, then les articles FR et EN partagent `articleKey`, slugs alternatifs et état draft cohérents.
- [ ] AC 2: Given une lectrice non spécialiste, when elle lit l'introduction et le diagnostic, then elle comprend RAM, swap et PSI sans devoir connaître l'administration Linux.
- [ ] AC 3: Given du swap utilisé avec RAM et PSI sains, when le cas est expliqué, then le texte n'affirme pas que la VM est encore en crise.
- [ ] AC 4: Given PSI absent, when le diagnostic est suivi, then la lectrice conserve une méthode RAM/swap et voit la limite explicitement.
- [ ] AC 5: Given un processus inconnu, interactif ou lié à un service, when le sauvetage est expliqué, then aucune instruction d'arrêt générique n'est proposée.
- [ ] AC 6: Given le parcours ShipGlows, when la capacité est décrite, then les critères d'éligibilité, protections, revalidation et confirmations correspondent au comportement vérifié.
- [ ] AC 7: Given les données de l'incident, when elles apparaissent, then elles sont anonymisées et présentées comme un cas observé, pas une garantie ou un dimensionnement universel.
- [ ] AC 8: Given les deux brouillons, when le contrôle de claims s'exécute, then aucune promesse de sécurité absolue, économies, uptime, compatibilité universelle ou arrêt automatique n'existe.
- [ ] AC 9: Given le site Astro, when check et build s'exécutent, then la collection accepte les deux articles et les routes se génèrent sans erreur.
- [ ] AC 10: Given les checkouts préexistants sales, when les commits locaux sont créés, then seuls les fichiers déclarés du chantier sont indexés et aucun push n'a lieu.

## Test Strategy

- Metadata: `python tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/linux-vm-pressure-rescue-public-tutorial.md shipglows_data/workflow/specs/linux-cli-resource-pressure-rescue.md`.
- Locale parity: `python tools/article_locale_parity_lint.py --articles-root <site-worktree>/site/src/content/articles --locales en fr --article-key linux-vm-pressure-rescue`.
- Site contract: `pnpm --dir site check` puis `pnpm --dir site build` dans le worktree isolé.
- Content quality: rubric partagée, fidélité FR/EN, frontmatter, CTA, liens et claims.
- Git: inspection des chemins indexés, scan sensible, commits locaux et absence de push.
- Browser: non requis pour le draft si le build et les routes générées passent; aucune validation hébergée n'est revendiquée.

## Test Contract

### Surface

- Stack/surface: Astro Markdown content collection.
- Primary proof mode: mixed.
- Proof order: claim/source review -> locale parity -> Astro check -> Astro build -> staged-diff review.

### Manual checklist

- Needed: no.
- Checklist path: none.
- Required scenario coverage: lecture FR/EN, limites de claim et métadonnées couvertes par la rubric et les contrôles ciblés.
- Exception with proof: aucun navigateur live, car le résultat reste `draft: true` et n'est ni poussé ni déployé.

### Required evidence stack

- Automated checks: metadata lint, article locale parity, `pnpm --dir site check`, `pnpm --dir site build`.
- Agent-run browser proof: not applicable for the local draft.
- Auth/session proof: not applicable.
- Contract proof: spec technique, runtime docs, source diff and official Linux documentation.
- Provider evidence: not applicable; no publication or deployment.
- Device-native proof: not applicable.

## Risks

- Security/privacy: un diagnostic de processus peut révéler des arguments sensibles; les commandes publiées excluent la colonne `args` et le récit est anonymisé.
- Misleading rescue: des lecteurs pourraient copier une commande de signal; le tutoriel enseigne l'observation et le parcours confirmé, pas un kill générique.
- Claim inflation: l'article peut transformer des garde-fous en garantie; la Claim Impact Plan borne chaque formulation.
- Translation drift: la création atomique et le lint de parité empêchent un peer manquant ou divergent.
- Discoverability: le tutoriel peut rester peu visible tant qu'il est draft; c'est voulu dans ce chantier de relecture.
- Residual risk: le comportement Vercel est une signature fermée actuelle; les outils inconnus restent hors du sauvetage jusqu'à une évolution technique séparée.

## OWASP Security Gate

- Categories considered: A02 Security Misconfiguration, A05 Injection, A06 Insecure Design, A09 Security Logging and Alerting Failures, A10 Mishandling of Exceptional Conditions.
- Trust/data boundaries: contenu Markdown public, détails d'incident privés, arguments de processus potentiellement sensibles, décision humaine de signal.
- ASVS: not applicable; aucun comportement applicatif ou contrôle d'accès n'est modifié.
- Proof: redaction, commandes sans `args`, claim review, schema/build, contenu draft et exact staged diff.
- Residual gap: une publication future exige une relecture finale et une validation des liens/preview sur la version réellement déployée.

## Execution Notes

- Read first: spec technique, runtime CLI docs, content map, article policy, claim register, schema Astro et paire d'articles existante.
- Official sources: `https://docs.kernel.org/accounting/psi.html` et `https://docs.kernel.org/filesystems/proc.html`.
- Topology: main-only; la rédaction bilingue forme un seul contrat sémantique et le runtime interdit la délégation proactive non demandée.
- Validate with: commandes du Test Contract; aucun serveur local requis pour le draft.
- Stop conditions: divergence de schema/locales, article path collision, claim non prouvé, worktree/base ambigu, dépendances manquantes, build rouge ou fichier sans rapport indexé.

## Open Questions

None. L'opératrice a choisi un draft local committé, non poussé et non publié; la surface, les deux langues, l'audience, l'angle, le CTA et les limites sont résolus par les contrats existants et l'incident vérifié.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-29 02:23:20 UTC | 100-sg-spec | GPT-5 | Created the bilingual public-tutorial contract from the verified Linux VM incident, declared article surface, claim boundaries, isolated site worktree, and local-only delivery choice. | draft | /101-sg-ready Linux VM pressure rescue public tutorial |
| 2026-08-29 02:26:18 UTC | 101-sg-ready | GPT-5 | Confirmed the unique FR/EN article pair, audience, source hierarchy, claim limits, isolated worktree, local-only persistence, edge cases, and proportional proof are decision-complete. | ready | /102-sg-start Linux VM pressure rescue public tutorial |

## Current Chantier Flow

- `100-sg-spec`: draft contract created from verified incident, runtime, editorial governance and official Linux sources.
- `101-sg-ready`: ready; no unresolved product, claim, surface, locale or proof decision remains.
- `102-sg-start`: pending.
- `103-sg-verify`: pending.
- `104-sg-end`: pending.
- `005-sg-ship`: not applicable in this run; operator selected local draft only.

Next step: `/102-sg-start Linux VM pressure rescue public tutorial`
