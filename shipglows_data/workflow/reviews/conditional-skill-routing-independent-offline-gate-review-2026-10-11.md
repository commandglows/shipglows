---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-11"
updated: "2026-10-11"
status: reviewed
source_skill: manual
scope: conditional-skill-routing-v3-offline-readiness
owner: independent-evaluator
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md
  - tools/conditional_skill_routing_real_comparison_preflight.py
  - tools/fixtures/conditional_skill_routing/preparation-revisions/
depends_on: []
supersedes: []
evidence:
  - "Read-only independent verification of the nine registered public packet hashes and their direct public references."
  - "Read-only review of current spec, preparation reports, public v3 seal and independent reproduction."
  - "Read-only preflight on a new readiness instance; no model/provider operation."
next_review: "2026-10-12"
next_step: "Attach an independently validated final consumer profile and evaluator isolation proof, then issue only supported gate receipts."
---

# Revue indépendante des neuf gates offline

## Conclusion

Relecteur : Codex, évaluateur distinct des auteurs des preuves et paquets existants; les paquets ne déclarent pas d'identité de reviewer. Les neuf paquets de brouillon restent inchangés. Le payload held-out privé n'a pas été ouvert, lu, ni haché par cette revue. Aucun reçu JSON PASS n'est émis : aucun `consumer.profile_sha256` final vérifiable n'est attaché au jeu v3.

ID choisi pour la préparation, sans lancement : `conditional-skill-routing-codex-linux-real-v3-campaign-20261011-01`. Une nouvelle instance de readiness reprend le template avec ce seul champ renseigné; le template original reste inchangé. Aucun profil final n'est inventé : le scellement public indique encore que l'attachement du profil transport est en attente et ne revendique pas d'isolation OS physique de l'évaluateur.

Verdicts des contrôles : cinq PASS bornés aux contrôles d'identité/revue/mock ci-dessous; quatre PARTIAL. Ils ne constituent ni un PASS de préparation globale ni une autorisation de lancement.

| Gate | Contrôle exact | Verdict du contrôle |
| --- | --- | --- |
| `new_campaign_id` | ID choisi et lié au scellement v3 dans cette revue | pass |
| `source_closure` | `original_o1_o9_preserved` | partial |
| `source_closure` | `mandatory_load_closure_reviewed` | partial |
| `source_closure` | `complete_normative_source_spans_hashed` | fail — liaison au hash de spec actuel absente |
| `source_closure` | `baseline_source_revision_frozen` | unknown |
| `source_closure` | `authority_hierarchy_identical` | unknown |
| `fresh_heldout_seal` | `executable_binding_complete` | partial |
| `fresh_heldout_seal` | `author_confidentiality_preserved` | pass — absence de divulgation observée; isolation OS non prouvée |
| `fresh_heldout_seal` | `complete_fresh_set` | pass |
| `a3_fixture_identity_review` | `identity_path_body_preflight_audit_agree` | pass — validation déterministe attestée |
| `a3_fixture_identity_review` | `mismatch_refused` | pass — validation déterministe attestée |
| `a3_fixture_identity_review` | `prerequisite_delivery_before_audit` | pass — validation déterministe attestée |
| `fixture_only_runtime` | `exact_case_owned_broker_tool_inventory` | partial |
| `fixture_only_runtime` | `nonbroker_native_calls_refused_before_dispatch` | partial — un appel natif testé |
| `fixture_only_runtime` | `immutable_schema_bindings` | pass — cas mock vérifiés |
| `fixture_only_runtime` | `unknown_calls_refused_before_dispatch` | unknown |
| `fixture_only_runtime` | `host_secret_boundary_verified` | pass — enfant WSL/bwrap mock seulement |
| `fixture_only_runtime` | `evaluator_resource_boundary_verified` | partial — enfant sans montage évaluateur, isolation physique non prouvée |
| `complete_scenario_transport` | `all_four_families` | pass — mock |
| `complete_scenario_transport` | `conditional_turns_and_grants` | pass — mock |
| `complete_scenario_transport` | `actual_effect_then_exact_result_delivery` | pass — effet de fixture simulée |
| `complete_scenario_transport` | `refusals_errors_retries_preserved` | pass — outcomes simulés retenus |
| `instruction_role_span_capture` | `cli_and_model_requests_separate` | pass — fournisseur simulé |
| `instruction_role_span_capture` | `input_and_instructions_unchanged` | pass — captures mock |
| `instruction_role_span_capture` | `exact_roles_spans_hashes` | pass — capture mock |
| `instruction_role_span_capture` | `all_request_accounting` | pass — capture mock |
| `context_loss_compaction_policy` | `opaque_input_fail_closed` | pass — probe simulé |
| `context_loss_compaction_policy` | `availability_invalidated` | pass — probe simulé |
| `context_loss_compaction_policy` | `fresh_complete_delivery_before_action` | pass — probe simulé |
| `context_loss_compaction_policy` | `hidden_retention_not_claimed` | pass — aucune revendication de rétention |
| `independent_readiness_review` | `all_offline_gates_reviewed` | pass — revue présente ici |
| `independent_readiness_review` | `deferred_launch_parameters_explicit` | pass |
| `independent_readiness_review` | `no_real_model_run_claimed` | pass |
| `independent_readiness_review` | `preparation_only` | pass — readiness globale reste NOT READY |

## Vérification commune

Les neuf empreintes de paquets concordent avec le registre du rapport de préparation. Les références publiques directes ont aussi été rehachées. Toutes concordent sauf l'empreinte de spec attendue par les paquets `source_closure` et `independent_readiness_review` : ils attendent `691006e1322c610c356cfeb30547b6dae2d884adf845235784ee65f1ddafd98a`, tandis que la spec actuelle vaut `bf787adcf495967313569ac9a42c9556415e4065fc16fcc8d71b9ac0a8253082`. Leurs paquets restent valides comme brouillons; leur liaison à la spec actuelle ne l'est pas.

Documents lus et empreintes actuelles :

- `shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md` — `bf787adcf495967313569ac9a42c9556415e4065fc16fcc8d71b9ac0a8253082`.
- `shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md` — `d20753c4125a7e148dcdd2b2a58c4238373d508db1cef1284fdaf4635fded6d8`.
- `shipglows_data/workflow/reviews/conditional-skill-routing-cli-broker-transport.md` — `f0be938fb6f5d5d902e2510a7186cfc28a70c73bdab334a4d0b67f6a3f83906f`.
- `shipglows_data/workflow/reviews/conditional-skill-routing-cli-capture-integration.md` — `ab64e4b78c1b1ecd6fd2bb47030c51052bdbbb1af9e57483a5fddc0eb0bb1995`.
- `shipglows_data/workflow/reviews/conditional-skill-routing-handoff.md` — `65a639169f362836d8e717fd886e331eb51ad23b386804f3b42fbaf2e05f1f85`.
- `shipglows_data/workflow/reviews/conditional-skill-routing-cli-instruction-compaction.md` — `84a4d06e583b79297403344ee3b4d828f7f7c98b7852d0f4b133ed188c97256f`.
- `shipglows_data/workflow/reviews/conditional-skill-routing-calibration.md` — `5e617dd1de6e64e17164374af729dd02385b25a2b6795a5a995f094e8f4082bd`.

## Résultats par gate

### 1. `new_campaign_id` — PASS

- Contrôle : identifiant distinct choisi et lié ici au scellement v3 avant tout tuning réel. L'identifiant diffère de l'expérience préparée et de la campagne historique. Aucun run n'est créé.
- Preuves : `codex-linux-real-v3-campaign-identity-public.json` SHA256 `76dff4e2f2a5671f7f89f898df0b86fb18bdf5b67a3bf43d1e3f2316593c3ef3`; instance de readiness ci-dessous SHA256 `66854b8d421fbc5eb8630c7a1332ac7362b393ce9944e9da0007bfd1c982af7a`; scellement public v3 SHA256 `f9cdbfa91553587a288a831e3678dc79ce714a88254ec445f5c6871cd8c5021b`.
- Limite : le champ est enregistré dans une nouvelle instance, pas dans le template verrouillé. Le préflight exécuté contre cette instance ne le signale plus manquant.

### 2. `source_closure` — PARTIAL

- Contrôles examinés : `original_o1_o9_preserved`, `mandatory_load_closure_reviewed`, `complete_normative_source_spans_hashed`, `baseline_source_revision_frozen`, `authority_hierarchy_identical`.
- Résultat : la calibration actuelle contient les obligations O1–O9; cela ne remplace pas une comparaison à une révision source gelée. Les spans normatifs complets de la spec actuelle ne sont pas liés. La revue de readiness et le paquet source-closure réutilisent l'ancien hash de spec; le contrôle d'égalité d'autorité et la révision baseline gelée ne sont donc pas démontrés.
- Preuves : paquet `codex-linux-real-v3-source-closure-review-public.json` SHA256 `011d2cced3909bb4bb5659e91c5f7d5a1f8353a1881fe8768d8ee6f1eafa4d74`; spec actuelle SHA256 ci-dessus; calibration SHA256 `5e617dd1de6e64e17164374af729dd02385b25a2b6795a5a995f094e8f4082bd`.
- Manque : fermeture complète des spans contre la spec actuelle et preuve du baseline source gelé. Le paquet existant ne peut pas être déclaré conforme à la spec actuelle.

### 3. `fresh_heldout_seal` — PARTIAL

- Contrôles examinés : `executable_binding_complete`, `author_confidentiality_preserved`, `complete_fresh_set`.
- Résultat : le jeu frais de huit cas (quatre familles, quatre cas froids et quatre continuations) et la reproduction byte-exact du binding baseline sont attestés. L'attachement au profil générique final reste en attente. L'isolation OS physique de l'évaluateur est explicitement non revendiquée; la précaution de stockage n'en est pas une preuve.
- Preuves : paquet `codex-linux-real-v3-heldout-profile-review-public.json` SHA256 `768465428e527d82f1d888faed15f8d769c2265e1d99b1ec7972da18bdc55b68`; scellement public v3 SHA256 `f9cdbfa91553587a288a831e3678dc79ce714a88254ec445f5c6871cd8c5021b`; reproduction indépendante SHA256 `c5a1e9179a7a8cfcf5210b7ff70169698cdccf2fff5682c0b49510435f157702`.
- Limite : revue en mémoire seulement; aucun lancement CLI held-out, modèle, campagne ou vérification du payload privé.

### 4. `a3_fixture_identity_review` — PARTIAL

- Contrôles examinés : `identity_path_body_preflight_audit_agree`, `mismatch_refused`, `prerequisite_delivery_before_audit`.
- Résultat : les trois marqueurs sont vrais dans la validation déterministe A3 du scellement public; la reproduction indépendante couvre l'ensemble frais et les callbacks exacts. Le scellement reste toutefois sans profil transport final et ne constitue pas une exécution CLI/modèle A3.
- Preuves : paquet `codex-linux-real-v3-a3-identity-review-public.json` SHA256 `25cc2d4574948d255b02fd5b52812af415bbff994da950c0731387a305f25e72`; scellement public v3 SHA256 `f9cdbfa91553587a288a831e3678dc79ce714a88254ec445f5c6871cd8c5021b`; reproduction indépendante SHA256 `c5a1e9179a7a8cfcf5210b7ff70169698cdccf2fff5682c0b49510435f157702`.
- Manque : revue A3 distincte liée au profil final.

### 5. `fixture_only_runtime` — PARTIAL

- Contrôles examinés : inventaire des outils par cas, refus avant dispatch des appels non-broker, schémas immuables, refus des appels inconnus, frontière des secrets hôtes, frontière des ressources évaluateur.
- Résultat : les huit exécutions mock montrent WSL/bwrap, environnement vide, montages bornés, loopback seul, aucun événement natif observé et callbacks broker exacts. Un `exec_command` natif a été refusé en HTTP 502 avant émission SSE. Codex conserve néanmoins ses fonctions natives activées; cet exemple ne prouve pas le refus exhaustif de tout appel natif/inconnu. L'isolation physique de l'évaluateur n'est pas établie.
- Preuves : paquet `codex-linux-real-v3-fixture-runtime-review-public.json` SHA256 `01689d98fd5116c26bf2edb12d80c84755c7b487b56220eaae7059db46e9021a`; rapport d'intégration CLI SHA256 `ab64e4b78c1b1ecd6fd2bb47030c51052bdbbb1af9e57483a5fddc0eb0bb1995`; rapport transport broker SHA256 `f0be938fb6f5d5d902e2510a7186cfc28a70c73bdab334a4d0b67f6a3f83906f`; résumés H1–S2 listés dans l'index ci-dessous.
- Manque : profil final, inventaire/exclusion exhaustifs et preuve de frontière des ressources évaluateur.

### 6. `complete_scenario_transport` — PASS, mock seulement

- Contrôles examinés : `all_four_families`, `conditional_turns_and_grants`, `actual_effect_then_exact_result_delivery`, `refusals_errors_retries_preserved`.
- Résultat : les huit cas H1/H2, A1/A2, B1/B2 et S1/S2 totalisent 199 requêtes simulées, 184 callbacks exacts et quatre refus de fixture. Les revues par cas vérifient les échanges authentifiés, schémas, callbacks exécutés et résultats exacts dans les requêtes suivantes. L'effet est un effet de fixture simulée.
- Preuves : paquet `codex-linux-real-v3-scenario-transport-review-public.json` SHA256 `dcb0dd09034dca191e38477ec4248101cf7a619a575204fabee3b8edd228a1d9`; rapport broker SHA256 `f0be938fb6f5d5d902e2510a7186cfc28a70c73bdab334a4d0b67f6a3f83906f`; huit résumés et huit revues indépendantes liés par hash dans l'index ci-dessous.
- Limite : les captures brutes des huit cas ont été supprimées. Les résumés/revues publics prouvés ne démontrent ni action réelle, ni refus de modèle, ni comportement réel d'un fournisseur.

### 7. `instruction_role_span_capture` — PASS, capture mock seulement

- Contrôles examinés : `cli_and_model_requests_separate`, `input_and_instructions_unchanged`, `exact_roles_spans_hashes`, `all_request_accounting`.
- Résultat : les rapports de capture distincts vérifient les rôles user/developer, les spans Unicode partiel/complet et leurs hashes, les requêtes/callbacks exacts ainsi que le comptage avec retry et relecture. Les entrées restent séparées des sorties d'outil.
- Preuves : paquet `codex-linux-real-v3-instruction-role-span-review-public.json` SHA256 `293a9aad9267fac983a9bf0044dfbd928785540232e07892628387b3e63cdd8f`; rapport instruction/compaction SHA256 `84a4d06e583b79297403344ee3b4d828f7f7c98b7852d0f4b133ed188c97256f`; code de capture SHA256 `2dc5073f40bac41084bed5c01caf3a56c63d5ddd4b9671ae05869fe56b876646`; comptable Responses SHA256 `bf23df2226a435532e469ef77df7c6841ef6ac58e7d72f9badc7af27b7a24543`.
- Limite : cela prouve la capture/instrumentation avec fournisseur simulé, pas la livraison ou rétention par un modèle réel.

### 8. `context_loss_compaction_policy` — PASS, politique/probe simulés

- Contrôles examinés : `opaque_input_fail_closed`, `availability_invalidated`, `fresh_complete_delivery_before_action`, `hidden_retention_not_claimed`.
- Résultat : le probe invalide la disponibilité après perte de contexte, refuse l'action tant que la ressource complète n'a pas été relivrée, puis vérifie la récupération. Le rapport ne revendique pas de rétention cachée.
- Preuves : paquet `codex-linux-real-v3-context-loss-policy-review-public.json` SHA256 `b104dfa72ba816fcc1196e06be6ae64ed608963dd8bdeb6c1b318bcaee7b29f9`; rapport instruction/compaction SHA256 `84a4d06e583b79297403344ee3b4d828f7f7c98b7852d0f4b133ed188c97256f`; probe de compaction SHA256 `a47fc11bfd17a791f542fa729af55d668ee0e53ab5606b5148f04fd8ac319124`.
- Limite : compaction/fournisseur simulés; la rétention interne réelle demeure UNKNOWN.

### 9. `independent_readiness_review` — PASS pour la revue; readiness globale NOT READY

- Contrôles examinés : `all_offline_gates_reviewed`, `deferred_launch_parameters_explicit`, `no_real_model_run_claimed`, `preparation_only`.
- Résultat : les neuf gates sont évalués dans ce rapport; fournisseur, compte, modèle, budget et autorité d'exécution restent explicitement différés; aucun appel modèle réel n'est revendiqué. Ce PASS porte sur l'exécution de la revue, pas sur la préparation globale.
- Preuves : paquet `codex-linux-real-v3-independent-readiness-review-public.json` SHA256 `f33b39f842135b63acf46b531a5d43017eac0ab96645db562ce90d78b01db7ee`; rapport de préparation SHA256 `d20753c4125a7e148dcdd2b2a58c4238373d508db1cef1284fdaf4635fded6d8`; instance de readiness SHA256 `66854b8d421fbc5eb8630c7a1332ac7362b393ce9944e9da0007bfd1c982af7a`.
- Limite : aucun reçu de readiness preflight n'est émis, car les reçus amont ne sont pas liés à un hash de profil final.

## Index des résumés transport H1–S2

Chaque entrée donne le SHA256 du résumé public, puis celui de sa revue indépendante adjacente. Les huit empreintes de revue concordent avec l'inventaire du résumé.

| Cas | Chemin du résumé public | SHA256 résumé | Chemin de revue indépendante | SHA256 revue |
| --- | --- | --- | --- | --- |
| H1 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-H1-v1-20261009-final-attempt1/summary.json` | `688fca186dc890b0b5fdb7f9a482e7ae90eb89c6310ecc401db7ec52333aea4c` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-H1-v1-20261009-final-attempt1/independent-case-proof-review.json` | `7fcec45dda6232d34e7df819c7f1bd707fae33682039c4bcb19da7d5cf1777de` |
| H2 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-H2-v1-20261009-final-attempt1/summary.json` | `d59904d8b45a94b1e2f2e929ef359669e0a02aee1c5eb984e7bdeeab41464878` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-H2-v1-20261009-final-attempt1/independent-case-proof-review.json` | `c07ba46bc1566a70773329a7f7408df506552722370d04fe80b8815c1d933966` |
| A1 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-A1-v1-20261009-final-attempt1/summary.json` | `a07b159576ad761799f4962da53055a90fdd62705679e8e9096b8c223fddb7d5` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-A1-v1-20261009-final-attempt1/independent-case-proof-review.json` | `5cef45e95600a7a9cea2c7fcd03bf745c5f582343e9157d05625d3515b877ffb` |
| A2 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-A2-v1-20261009-final-attempt1/summary.json` | `410b9b7f16259e9cd8bd27bfd5856c8d926acd99e589fa5c9392d47f9e931e85` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-A2-v1-20261009-final-attempt1/independent-case-proof-review.json` | `023bc6faae5bc327ed80d61ba2ea632bdb9f9b5d9e779f8e89f08dac889661ce` |
| B1 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-B1-v1-20261009-final-attempt1/summary.json` | `a467e8a926b2f8a41599384d0477a73a12c5ad79ee8edf9a160287b094d0506f` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-B1-v1-20261009-final-attempt1/independent-case-proof-review.json` | `044672ee20dd08a21e0f969b39b7dca30dbe7a84a208f71a0b4f62878650dc21` |
| B2 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-B2-v1-20261009-final-attempt1/summary.json` | `a1749f051a94eebb825cd6251d7bb2f0b0da5db6b6e1f1d176fa656483288c62` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-B2-v1-20261009-final-attempt1/independent-case-proof-review.json` | `1abb4516dfd9bc00c6783c9cfcb213cd4faa4f851bb0a7452a86a95df50ab32b` |
| S1 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-S1-v1-20261009-final-attempt1/summary.json` | `ca20e83cc4df8e7d158021744e4da0274429813c39ec7d2ca105e24db3a37486` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-S1-v1-20261009-final-attempt1/independent-case-proof-review.json` | `a8998a2b9ebb10a08a184bca5b9286f70ce6141069780b89095238e6baf9c45d` |
| S2 | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-S2-v1-20261009-final-attempt1/summary.json` | `5c8ecf3eb827240c014f9bd4048c4ee283709ab470dbe49ed185be3b3831736b` | `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-parent-case-S2-v1-20261009-final-attempt1/independent-case-proof-review.json` | `75caaf82995a2bf4bdae113cabd25371422c123f367187cd17e2991c29512b9f` |

## Empreintes des neuf paquets existants

Les neuf fichiers ci-dessous sont restés en état de brouillon et n'ont pas été modifiés.

| Gate | Chemin du paquet public | SHA256 |
| --- | --- | --- |
| `new_campaign_id` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-campaign-identity-public.json` | `76dff4e2f2a5671f7f89f898df0b86fb18bdf5b67a3bf43d1e3f2316593c3ef3` |
| `source_closure` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-source-closure-review-public.json` | `011d2cced3909bb4bb5659e91c5f7d5a1f8353a1881fe8768d8ee6f1eafa4d74` |
| `fresh_heldout_seal` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-heldout-profile-review-public.json` | `768465428e527d82f1d888faed15f8d769c2265e1d99b1ec7972da18bdc55b68` |
| `a3_fixture_identity_review` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-a3-identity-review-public.json` | `25cc2d4574948d255b02fd5b52812af415bbff994da950c0731387a305f25e72` |
| `fixture_only_runtime` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-fixture-runtime-review-public.json` | `01689d98fd5116c26bf2edb12d80c84755c7b487b56220eaae7059db46e9021a` |
| `complete_scenario_transport` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-scenario-transport-review-public.json` | `dcb0dd09034dca191e38477ec4248101cf7a619a575204fabee3b8edd228a1d9` |
| `instruction_role_span_capture` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-instruction-role-span-review-public.json` | `293a9aad9267fac983a9bf0044dfbd928785540232e07892628387b3e63cdd8f` |
| `context_loss_compaction_policy` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-context-loss-policy-review-public.json` | `b104dfa72ba816fcc1196e06be6ae64ed608963dd8bdeb6c1b318bcaee7b29f9` |
| `independent_readiness_review` | `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-independent-readiness-review-public.json` | `f33b39f842135b63acf46b531a5d43017eac0ab96645db562ce90d78b01db7ee` |

## Préflight et limites de préparation

Template original : `tools/fixtures/conditional_skill_routing/preparation-revisions/real-comparison-readiness-template.json`, SHA256 `c973ad5fa0a1de21fd8e2dafd8fa8eeb02d644c7d12cf958729ff573090e8761`.

Nouvelle instance : `tools/fixtures/conditional_skill_routing/preparation-revisions/real-comparison-readiness-codex-linux-v3-20261011-01.json`, SHA256 `66854b8d421fbc5eb8630c7a1332ac7362b393ce9944e9da0007bfd1c982af7a`. Comparée au template, seul `campaign_id` change.

Le préflight en lecture seule a été relancé sur cette instance : `structural_valid=true`, aucune erreur, `model_calls=0`, `launch_performed=false`, `prepared_for_authorized_baseline=false`, `launch_authorized=false`, `ready_to_launch_baseline=false` et `ready_to_launch_final96=false`. Le nouvel ID n'est plus manquant; les huit reçus offline restent non liés. `consumer.profile_sha256`, le provider, modèle, paramètres, budget et autorité d'exécution demeurent différés. Le script de préflight a pour SHA256 `815de58b9a674fedc47d965c7edda13bad2998555417c50466ba51357721df8e`.

Aucune comparaison, campagne, authentification, session modèle ou requête fournisseur réelle n'a été effectuée. AC5 et les seuils restent inchangés. L'autorisation de lancement demeure séparée. Doppler n'a pas été utilisé.
