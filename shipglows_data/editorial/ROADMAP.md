---
artifact: editorial_roadmap
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-11"
updated: "2026-08-16"
status: draft
source_skill: sg-content
scope: public-editorial-backlog
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/editorial/content-map.md
  - shipglows_data/editorial/page-intent-map.md
  - shipglows_data/editorial/claim-register.md
  - shipglows_data/editorial/blog-and-article-surface-policy.md
  - site/src/content/articles/
depends_on:
  - shipglows_data/editorial/content-map.md
  - shipglows_data/editorial/claim-register.md
supersedes: []
evidence:
  - "Operator editorial direction 2026-08-16: turn the Windows environment and reproducibility investigation into technical, educational, and interrogative ShipGlows content."
  - "The indexed blog collection is the declared surface for new general long-form topics."
next_review: "2026-09-16"
next_step: "Qualify the Wave 1 briefs against current implementation and primary technical sources."
---

# Editorial Roadmap — ShipGlows

> Operational records in this file use `skills/references/operational-record-format.md`.
> Use this tracker for public editorial follow-up only. Technical implementation work stays in `shipglows_data/workflow/TASKS.md`.

## Editorial direction

Own the practical and architectural questions behind reproducible development environments for humans and coding agents. The editorial promise is not that ShipGlows has already solved every platform boundary. The valuable story is the investigation: what must be declared, what can be converged, what remains interactive, and where existing standards or tools should be composed instead of reimplemented.

Use interrogative titles when the answer depends on trade-offs. Separate current ShipGlows behavior from proposed architecture, and prefer primary documentation plus reproducible local evidence for technical claims.

## Wave 1 — Reproducibility architecture

🔴 [ShipGlows] task: Environnement reproductible et bootstrap convergent, parle-t-on vraiment de la même chose ? | status: todo | area: reproducible-environments | id: SG-ED-ENV-01 | audience: développeurs et équipes plateforme | question: réinstaller jusqu'à obtenir un état fonctionnel équivaut-il à reproduire le même environnement ? | angle: distinguer reproductibilité, convergence, idempotence, portabilité et herméticité | surface: indexed blog FR/EN | funnel: documentation ShipGlows et manifeste d'environnement futur | proof: s'appuyer sur des définitions et exemples vérifiables sans revendiquer une herméticité actuelle | next: produire le brief et le glossaire comparatif

🔴 [ShipGlows] task: Sommes-nous en train de réinventer Nix ? | status: todo | area: ecosystem-positioning | id: SG-ED-ENV-02 | audience: ingénieurs familiers de Nix, Flox ou Dev Containers | question: ShipGlows doit-il devenir un gestionnaire de paquets ou une couche d'orchestration au-dessus des outils existants ? | angle: comparer responsabilités, limites hôte, état projet, agents, Android, authentification et licences | surface: indexed blog FR/EN | funnel: architecture et roadmap ShipGlows | proof: distinguer clairement capacités livrées, hypothèses et décisions futures | next: construire une matrice Nix, Flox, mise, WinGet Configuration, Dev Containers et ShipGlows

🔴 [ShipGlows] task: Pourquoi Flox sur Unix mais pas directement sur Windows ? | status: todo | area: cross-platform-tooling | id: SG-ED-ENV-03 | audience: équipes qui veulent un contrat multi-plateforme | question: faut-il imposer WSL, choisir un moteur Windows natif ou compiler un même manifeste vers plusieurs backends ? | angle: exposer les frontières entre noyau, shell, GUI, SDK mobiles et outils hôte | surface: indexed blog FR/EN | funnel: guide d'environnement ShipGlows | proof: vérifier le support plateforme actuel de Flox et éviter de présenter un backend futur comme livré | next: documenter trois scénarios de décision

🔴 [ShipGlows] task: Desired, resolved, observed, les trois états d'un environnement que les agents doivent comprendre | status: todo | area: environment-model | id: SG-ED-ENV-04 | audience: concepteurs d'outillage et d'agents IA | question: comment distinguer ce que le projet demande, ce qui a été sélectionné et ce qui existe réellement sur la machine ? | angle: proposer un modèle de contrôle qui explique détection, résolution, installation, diagnostic et dérive | surface: indexed blog FR/EN | funnel: spécification du manifeste et diagnostics ShipGlows | proof: présenter le modèle comme proposition architecturale tant qu'il n'est pas contracté | next: dessiner le flux et collecter deux incidents Windows comme exemples

## Wave 2 — Windows, mobile and agent reality

🟠 [ShipGlows] task: Reproduire Flutter et Android sous Windows dépasse largement l'installation d'un SDK | status: todo | area: flutter-android | id: SG-ED-ENV-05 | audience: développeurs Flutter et mainteneurs d'installateurs | question: pourquoi un flutter doctor presque vert ne garantit-il ni émulateur ni build Windows ? | angle: relier JDK, SDK Android, licences, images, AVD, virtualisation, Visual Studio et appareils réels | surface: indexed blog FR/EN | funnel: guide Windows DevServer | proof: tester les parcours fresh, partial et existing host; ne pas confondre Visual Studio et Visual Studio Code | next: bâtir la matrice Android, Flutter Web, Flutter Windows et émulateur

🟠 [ShipGlows] task: Pour un agent de code, le PATH fait partie du produit | status: todo | area: agent-environment | id: SG-ED-ENV-06 | audience: développeurs d'agents et responsables DevEx | question: pourquoi un outil installé reste-t-il indisponible pour un agent lancé dans un autre shell ou processus ? | angle: analyser PATH persistant, environnement du processus, shims, versions et diagnostic actionnable | surface: indexed blog FR/EN | funnel: diagnostics et environment.md ShipGlows | proof: utiliser des reproductions Windows et séparer disponibilité interactive et disponibilité agent | next: capturer trois topologies de lancement réelles

🟠 [ShipGlows] task: Un lockfile ne suffit pas quand le navigateur a lui aussi une révision | status: todo | area: browser-toolchains | id: SG-ED-ENV-07 | audience: équipes utilisant Playwright, tests visuels ou capture motion | question: comment aligner package, CLI et binaire Chromium sans dépendre du hasard du cache ? | angle: raconter la chaîne version du package, installation du navigateur, cache, exécutable prouvé et fallback sûr | surface: indexed blog FR/EN | funnel: outillage de vérification ShipGlows | proof: ne promettre la compatibilité que pour des couples réellement validés | next: préparer une expérience reproductible avec cache vide et cache divergent

🟠 [ShipGlows] task: La configuration MCP est-elle une dépendance d'environnement ? | status: todo | area: mcp-environment | id: SG-ED-ENV-08 | audience: utilisateurs de Codex, Claude, OpenCode et Kilo | question: un environnement est-il reproductible si ses agents n'ont pas accès aux mêmes outils ? | angle: traiter schémas de configuration, chemins natifs, versions, secrets, capacités et preuve de convergence | surface: indexed blog FR/EN | funnel: documentation MCP ShipGlows | proof: ne jamais publier de secret ou prétendre à la parité entre agents sans test par surface | next: inventorier les contrats de configuration réellement supportés

## Wave 3 — Human boundaries and open specification

🟡 [ShipGlows] task: Authentification et licences, les parties irréductiblement humaines de la reproductibilité | status: todo | area: trust-and-consent | id: SG-ED-ENV-09 | audience: auteurs de bootstrap et responsables sécurité | question: que peut automatiser un installateur sans accepter des conditions ou manipuler des identifiants à la place de l'utilisateur ? | angle: séparer installation, consentement, connexion, stockage de secrets et attestation finale | surface: indexed blog FR/EN | funnel: menus d'authentification et documentation de sécurité | proof: s'en tenir aux flux officiels et aux limites de sécurité documentées | next: construire une taxonomie automatique, interactif, interdit

🟡 [ShipGlows] task: Que devrait contenir un manifeste d'environnement de développement moderne ? | status: todo | area: environment-manifest | id: SG-ED-ENV-10 | audience: mainteneurs DevEx et auteurs de standards | question: comment décrire outils, SDK, services, navigateurs, MCP, variables, workloads et vérifications sans enfermer le projet dans un seul moteur ? | angle: proposer un noyau portable et des extensions de plateforme compilables vers Flox, mise et WinGet Configuration | surface: indexed blog FR/EN | funnel: future spécification ShipGlows | proof: publier comme exploration et comparer aux spécifications existantes avant de figer un schéma | next: rédiger un exemple minimal puis tester ses pertes sur trois backends

🟡 [ShipGlows] task: Les Dev Containers ne possèdent pas l'hôte, où la reproductibilité s'arrête-t-elle ? | status: todo | area: containers | id: SG-ED-ENV-11 | audience: équipes utilisant VS Code Dev Containers ou CI conteneurisée | question: quels éléments restent hors du conteneur pour Android, émulateurs, navigateurs, USB, virtualisation et agents locaux ? | angle: tracer explicitement la frontière hôte, conteneur, appareil et service externe | surface: indexed blog FR/EN | funnel: architecture multi-backend ShipGlows | proof: éviter l'opposition simpliste entre conteneurs et environnements natifs | next: vérifier les frontières sur deux projets représentatifs

🟡 [ShipGlows] task: Peut-on fournir une attestation d'environnement utile aux agents ? | status: todo | area: environment-attestation | id: SG-ED-ENV-12 | audience: équipes qui délèguent à des agents IA | question: quelles preuves minimales permettent à un agent de savoir ce qui est réellement disponible avant d'agir ? | angle: combiner inventaire borné, versions, chemins, capacités, diagnostics et horodatage sans exposer de secrets | surface: indexed blog FR/EN | funnel: environment.md et diagnostics ShipGlows | proof: ne pas confondre inventaire local et garantie de fonctionnement | next: définir un exemple d'attestation lisible par humain et machine

## Existing backlog

🟠 [ShipGlows] task: Préparer puis rédiger la première séquence email durable à partir d'un brief d'audience, d'objectif, de promesse et de CTA | status: todo | area: email-sequence | id: SG-ED-EMAIL-01 | source: décision utilisateur 2026-07-11 | reference: skills/references/email-sequence-storage.md | next: /202-sg-emailing définir le brief de la séquence 1

## Editorial guardrails

- Use current primary sources for tool support, platform compatibility, schemas, licenses, and specifications.
- Label future manifests, backends, attestations, and orchestration layers as proposals until implementation and contracts exist.
- Distinguish Visual Studio from Visual Studio Code, Android SDK components from Android Studio, and an installed emulator binary from a usable AVD.
- Do not claim perfect reproducibility, guaranteed agent correctness, quantified productivity, security compliance, or universal cross-platform parity.
- Prefer a tested incident, diagnostic, or comparison matrix over generic thought leadership.

## Historical completed work

🟢 [ShipGlows] task: Documenter publiquement les modes `309-sg-tasks sessions` et `sessions rename <status>`, avec leurs limites pour les forks et le tracker | status: done | area: public-skill-documentation | id: SG-ED-DOC-01 | source: décisions utilisateur 2026-07-15/16 | reference: shipglows-site/src/content/skills/sg-tasks.md | next: none
