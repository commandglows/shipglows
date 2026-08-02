# Tasks — quit-coke-app

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Build / Release Blockers

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Fix la regression `AppSwipeScope` introduite par le refactor du pager (`more_tabbed_screen.dart`, `tracker_screen.dart`) pour que `flutter analyze lib test pubspec.yaml` repasse au vert | ✅ done |
| 🟡 | Nettoyer les infos d'analyse restantes dans `lib/bootstrap.dart` (packages `source_maps`, `source_map_stack_trace`, `stack_trace`) | ✅ done |
| 🟡 | Remplacer le placeholder App Store URL dans `lib/config/cocaine_config.dart` quand la fiche App Store existe | 📋 todo |

---

## App Store Submission Checklist

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Privacy policy + CGU — ecran in-app FR/EN/ES (legal_screen.dart) | ✅ done |
| 🔴 | Privacy policy web — section app mobile ajoutee sur jarretelacoke.fr/confidentialite | ✅ done |
| 🔴 | CFBundleName corrige quit_coke_app → NoCocaïne | ✅ done |
| 🔴 | pubspec.yaml description generique corrigee | ✅ done |
| 🔴 | Sentry DSN configure dans Doppler | ✅ done |
| 🔴 | Coller URL privacy policy dans App Store Connect apres deploy site | 📋 todo |
| 🟠 | Tester sur vrai appareil iOS avant soumission | 📋 todo |
| 🟠 | Fixer les 2 warnings Dart (unused import + unused variable) | ✅ done |
| 🟠 | Localisation EN/ES incomplete — 176 const convertis en getters trilingues FR/EN/ES | ✅ done |
| 🟡 | Ecrire des tests (un seul widget_test.dart template actuellement) | 📋 todo |
| 🟡 | Verifier NSUserTrackingUsageDescription si analytics utilise — pas necessaire (aucun IDFA/ATT) | ✅ done |

---

## UX / UI Polish

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Enregistrement retroactif — bottom sheet "Detail du jour" depuis le calendrier | ✅ done |
| ✅ | Header Today aplati sur une seule rangee (salutation + streak centre + flamme) | ✅ done |
| ✅ | Tailles UI augmentees globalement (polices, icones, boutons, chips, nav) | ✅ done |
| ✅ | Barres dopamine toujours visibles (meme a 100%) | ✅ done |
| ✅ | Cartes objectif/argent en une rangee | ✅ done |
| ✅ | Widget check-in fusionne (resume + nouveau check-in, couleur adaptative) | ✅ done |
| ✅ | Dialog consommation : dismiss on outside tap | ✅ done |
| ✅ | Rituel matin : emojis triggers, fix save intention perso, message confirmation | ✅ done |
| ✅ | SOS modal : titre centre + timeline phases horizontale + deck swipeable outils | ✅ done |
| ✅ | Navigation swipe horizontal entre pages principales | ✅ done |
| ✅ | Carte lecon du jour : label integre, contour, deplacee en haut | ✅ done |
| ✅ | Widget achat : couleur distincte (warning/dore) | ✅ done |
| ✅ | Deck SOS outils refondu en vraies cartes type Tinder / jeu avec stack visuel et swipe-only | ✅ done |
| ✅ | SOS sans onglets : timeline enrichie, actions rondes integrees en haut, details de phase inline et deck recentre | ✅ done |
| ✅ | Lisibilite mobile renforcee sur la barre dopamine compacte | ✅ done |
| ✅ | Deck SOS : retirer le compteur de cartes, reboucler en continu et garder le panneau detail strictement dans la carte | ✅ done |
| ✅ | Widgets d'intention matin/soir rendus contextuels selon l'heure locale (matin jusqu'a 17:59, soir apres 18:00) | ✅ done |
| ✅ | Theme automatique clair/sombre base sur le soleil et la localisation reelle | ✅ done |
| ✅ | Mode zen renforce en vraie variante d'experience sobre (Today, Carte, Tracker, Dashboard, compteur, quetes et notifications) | ✅ done |
| ✅ | Today compacte : objectif reintegre a la bande de stats, lecon du jour fusionnee a la carte de phase et mode zen du Today durci | ✅ done |
| 🟡 | Empêcher la scrollbar de Today/Dashboard quand il n'y a pas de débordement de contenu | ✅ done |
| 🟡 | Afficher les intentions du matin dans le Journal de fierte | 📋 todo |
| 🟡 | Rituel du soir : rappeler l'intention du matin dans la question | 📋 todo |
| 🟡 | Tester sur vrai appareil la permission localisation et le basculement soleil du theme Auto | 📋 todo |
| 🟡 | Tester sur vrai appareil le mode zen complet (Today, Carte, Tracker, Dashboard, compteur, notifications) | 📋 todo |

---

## Content / SEO / Promotion

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Structurer le cluster "mecanismes de l'app" autour de la promesse "reintroduire du reel" | 🔄 in progress |
| 🟠 | Produire une page pilier de vente expliquant la methode Quit Coke sans jugement | ✅ done |
| 🟠 | Produire les 6 articles marketing / SEO du cluster mecanismes produit | ✅ done |
| 🟡 | Faire une passe editoriale finale sur les 7 nouveaux articles (titres, intros, CTA, coherence de ton) | 📋 todo |
| 🟡 | Definir l'ordre de publication du cluster (pilier -> mecanismes -> relais SEO symptomes) | 📋 todo |
| 🟡 | Rediger metas, OG titles/descriptions et snippets sociaux pour chaque nouvel article | 📋 todo |
| 🟡 | Concevoir un maillage interne complet entre articles SEO symptomes et pages mecanismes produit | 📋 todo |
| 🟡 | Transformer la page pilier en vraie landing page marketing web | 📋 todo |
| 🟢 | Creer un article / page concept sur "la prochaine bonne action" comme promesse centrale du produit | 📋 todo |
| 🟢 | Creer un article / page concept sur "friction honnete" pour expliquer la logique produit anti-impulsion | 📋 todo |
| 🟢 | Creer un article / page concept sur "autonomie progressive" et l'echafaudage qui se retire | 📋 todo |

---

## Tracker — Quantite precise & reduction des risques

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Remplacer peu/moyen/beaucoup par nombre de prises (1-5) + poids en grammes (0.5g-10g) | ✅ done |
| 🟠 | Ajouter le mode de consommation (sniffe, fume, injecte, oral) au tracker | ✅ done |
| 🟠 | Education contextuelle : encadre de reduction des risques par mode dans le formulaire | ✅ done |
| 🟠 | Detection d'escalade : algorithme + alerte rouge dans RecoveryInsights | ✅ done |
| 🟠 | Insight "mode principal" avec conseil adapte dans RecoveryInsights | ✅ done |
| 🟠 | Smart defaults : apres 4+ entrees, options non-utilisees derriere un bouton "+" | ✅ done |
| 🟠 | Retirer tous les champs heroine/opioides de TrackerEntry | ✅ done |
| 🟡 | Tester sur appareil le formulaire avec les 3 selecteurs et le bouton "+" | 📋 todo |
| 🟡 | Ajouter un graphique d'evolution du mode dans le dashboard (timeline sniff/fume/injection) | 📋 todo |
| 🟡 | Alerter le coach IA du mode d'injection pour adapter ses reponses | 📋 todo |

---

## Contenu educatif & site

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Relier les 48 micro-lecons aux articles jarretelacoke.fr (deepReadUrl sur chaque lecon) | ✅ done |
| 🟠 | Relier les 39 cartes de recentrage aux articles jarretelacoke.fr (siteArticleUrl) | ✅ done |
| 🟠 | Debloquer les 16 modules formations vers le contenu du site (plus de lock premium) | ✅ done |
| 🟡 | Traduire les cartes de recentrage en francais (actuellement en anglais) | ✅ done |
| 🟠 | Migrer toutes les strings hardcodees vers Fr class (i18n complet) | ✅ done |
| 🟡 | Ajouter des cartes de recentrage supplémentaires basées sur les 87 articles /questions/ du site | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Recovery Chemistry Insights — messages chimiques contextuels basés sur le temps depuis la dernière prise | 🔄 in progress |
| 🟠 | Stabiliser et tester sur appareil le nouveau flow SOS swipeable (deck sans onglets, timeline inline, sorties, enregistrement de conso, cartes custom, rendu Tinder) | 🔄 in progress |
| 🟠 | Affiner le contenu editorial des cartes SOS : benefices, formulations corporelles, budgets projetes, tonalite compassionnelle | 📋 todo |
| 🟠 | Ajouter 3 mini-jeux SOS anti-craving swipeables avec XP (Snake, recentrage, trajectoire) | ✅ done |
| 🟠 | Ajouter 3 mini-jeux SOS de mots (tri tunnel/reel, anagrammes, phrase repere) | ✅ done |
| 🟠 | Tester sur appareil les 6 mini-jeux SOS pour ajuster rythme, lisibilite, duree et ressenti en vrai moment de craving | 📋 todo |
| 🟠 | Formaliser une doctrine produit anti-casino pour les mini-jeux SOS (caps, duree, feedback, limites, non-retention) | 📋 todo |
| 🟠 | Concevoir une vraie famille de mini-jeux SOS avec fonction par usage (distraire, ralentir, reconditionner, remettre du reel) | 📋 todo |
| 🟡 | Mieux relier les mini-jeux SOS aux autres sorties utiles (defi delai, coach, respiration, contact safe, tracker) | 📋 todo |
| 🟡 | Personnaliser les mini-jeux SOS selon les declencheurs, le profil et les refuges de l'utilisateur | 📋 todo |
| 🟡 | Explorer d'autres mini-jeux de langage (mots mêles, mot intrus, memory semantique, paires de sens) | 📋 todo |
| 🟡 | Creuser le dosage ethique de l'association negative autour de la coke sans basculer dans la honte ou le degout force | 📋 todo |
| 🟡 | Approfondir les variantes UX des jeux `Snake`, `tapper ce qui aide` et `trajectoire` (plus zen, plus sensoriel, plus symbolique) | 📋 todo |
| 🟡 | Produire une roadmap priorisee des mini-jeux SOS par impact psychologique, facilite de code et utilite SOS | 📋 todo |
| 🟠 | Creer un vrai cluster editorial / philosophie produit pour sortir les pages "vision de l'app" du seau `questions` | 📋 todo |
| ✅ | Repenser l'entree `Formations` de la page Plus : conserver un point d'entrée en tête de liste + dispatcher de manière contextuelle vers le parcours d'apprentissage (Today / Carte) avec focus track/module | ✅ done |
| 🟡 | Demanteler la page `Succes` de la page Plus : badges de progression reintegres dans Carte, entree retiree de Plus et ancienne route redirigee vers Carte | ✅ done |
| 🟡 | Demanteler la page `Defis hebdomadaires` de la page Plus : reintegrer la feature dans Today (carte / detail), puis supprimer l'entree et la page dediee | ✅ done |
| ✅ | Repositionner `Ma boite a outils` : garder la feature et probablement la page, mais la laisser cote Plus / Personnalisation comme espace de gestion a froid ; SOS doit seulement consommer ces outils, pas devenir leur back-office | ✅ done |
| ✅ | Demanteler la page `Journal de fierte` de la page Plus : garder la feature, la laisser vivre d'abord dans Today via le rituel du soir, et si besoin conserver seulement une vue d'historique secondaire accessible depuis ce flow | ✅ done |
| ✅ | Repositionner `Journal de reflexion` : garder la feature, mais sortir la page des entrees fortes de Plus ; la rendre accessible d'abord depuis le flow post-consommation, le tracker ou un sous-espace d'historique / reflexion personnel | ✅ done |
| 🟡 | Renforcer le maillage et le SEO autour du mot-cle `sevrage de la cocaine` dans les contenus produit | 📋 todo |
| 🟠 | Concevoir un onboarding progressif ("progressive profiling") pour demander les bonnes infos au bon moment sans alourdir l'entree | ✅ done |
| 🟠 | Etendre le profil utilisateur avec objectifs d'usage de l'app (arreter, reduire, reprendre le controle, comprendre, suivre sa conso) | ✅ done |
| 🟠 | Ajouter dans le profil les activites refuge / plaisirs sains / liens safe afin de personnaliser le deck SOS | ✅ done |
| 🟠 | Ajouter un module "objectif d'achat / projet a financer" (montant, icone, raison emotionnelle) pour reutilisation dans les moments de craving | ✅ done |
| 🟠 | Ajouter un systeme de `défi délai` dans le flow SOS (10 min / 30 min / 2 h) avec XP et recompense partielle meme si la consommation arrive ensuite | ✅ done |
| 🟠 | Ajouter un `feed anti-impulsion` dans le SOS avec micro-cartes de recentrage, favoris et contenu editorial court | ✅ done |
| 🟡 | Affiner la V2 du `défi délai` : suggestions de cartes selon durée, meilleure synthese gamification, badges dédiés | 📋 todo |
| 🟡 | Affiner la V2 du `feed anti-impulsion` : plus de cartes, favoris visibles ailleurs, cartes scientifiques sourcées, raccourcis encore plus personnels | 📋 todo |
| 🟡 | Exposer les alternatives budget dans le dashboard, la sobriety view et les retrospectives (semaine / mois / annee) | 📋 todo |
| 🟡 | Ajouter un systeme de suggestions budget mappées par paliers ("avec 20€, tu pourrais...") avec categories desirables | 📋 todo |
| 🟡 | Ajouter des prompts progressifs plus fins selon usage reel (contacts safe, liens refuge, projet budget, artistes/playlist preferee) | 🔄 in progress |
| 🟡 | Affiner et tester sur appareil les nouvelles cartes de personnalisation, l'ecran profil et leur reinjection dans le flow SOS | 📋 todo |
| 🟡 | Ajouter l'edition / suppression / priorisation des cartes custom directement depuis le flow SOS ou le toolkit | ✅ done |
| 🟠 | Ajouter une carte feedback dans le deck SOS et un point d'entree settings (texte local + audio local) | ✅ done |
| 🟠 | Faire evoluer le feedback app vers un vrai flux admin serveur (texte + audio uploades, allowlist email, vue de lecture interne) | ✅ done |
| 🟠 | Redéployer le frontend Flutter/web pour activer en live le nouveau flux feedback admin et son écran interne | 📋 todo |
| 🟠 | Tester sur vrai appareil les permissions micro et la qualite du feedback vocal | 📋 todo |
| 🟠 | Ajouter un journal de regrets post-consommation / post-descente (texte + vocal) avec cartes de rappel dans le SOS | ✅ done |
| 🟠 | Faire evoluer le projet financier unique vers plusieurs projets de vie reutilisables dans le SOS | ✅ done |
| 🟠 | Tester sur vrai appareil la lecture des regrets vocaux dans le SOS et verifier que l'effet est utile plutot que culpabilisant | 📋 todo |
| 🟡 | Enrichir fortement le catalogue SOS avec cartes orientees plaisir, beaute, accomplissement, lien social et sens | ✅ done |
| 🟡 | Remplacer les onglets SOS par un deck de cartes swipeable trie selon l'historique reel de l'utilisateur | ✅ done |
| 🟡 | Ajouter une carte de sortie "Rien ne me fait envie" avec branche "J'ai peur de consommer" et pause avant enregistrement | ✅ done |
| 🟡 | Ajouter un mode budget dans la carte "J'ai peur de consommer" avec depenses semaine / mois / annee et alternatives concretes | ✅ done |
| 🟢 | Explorer l'import natif de contacts pour ne plus saisir les numeros a la main dans les cartes custom | 💤 deferred |
| 🟢 | Explorer des micro-messages "sortir du tunnel" encore plus contextuels selon le trigger, l'heure et l'historique recent | 💤 deferred |

---

## Audit Findings
<!-- Populated by /sg-audit — dated sections added automatically -->

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Remove or replace unused discontinued `flutter_markdown` dependency (`flutter pub get --dry-run` reports replacement: `flutter_markdown_plus`) | ✅ done |
| 🟡 | Remove unused direct/codegen dependencies after a quick analyzer pass: `cupertino_icons`, `flutter_animate`, `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`, and `build_runner` if no generated model flow is intended | ✅ done |
| 🟡 | Add dependency update automation for pub, npm, GitHub Actions, and Gradle plugin surfaces | ✅ done |
| 🟡 | Plan `sentry_flutter` 9.x as `/sg-migrate` work; it remains the only direct major dependency migration after the cleanup pass | 📋 todo |
