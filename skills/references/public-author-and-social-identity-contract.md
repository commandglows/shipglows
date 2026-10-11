---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-08-18"
status: active
source_skill: 900-shipglows-core
scope: public-author-and-social-identity
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/branding/public-identity-registry.json
  - skills/references/blog-and-cms-experience-contract.md
  - skills/references/editorial-content-corpus.md
  - skills/006-sg-design/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/009-sg-marketing/SKILL.md
  - skills/406-sg-seo/SKILL.md
  - tools/test_public_author_and_social_identity_contract.py
depends_on:
  - artifact: skills/references/editorial-content-corpus.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-18: Diane is the default public author; photo, public contact email, biography, homepage, and person/project social profiles must resolve through one reusable authority."
  - "Repository evidence: GoCharbon declares Diane while CommunityGlows contains generic team bylines and generic platform homepages that must not become official identity."
next_review: "2027-02-18"
next_step: "/103-sg-verify public-author-and-social-identity-contract"
---

# Public Author And Social Identity Contract

## Purpose And Ownership

Provide one portfolio authority for public authorship, people, organizations, projects, photos, biographies, public contact information, and official social profiles. Consumers resolve identity from `shipglows_data/branding/public-identity-registry.json`; they do not duplicate those values in article templates, CMS defaults, footers, author cards, metadata generators, campaigns, or translation files.

The registry is public-presentation data, not an account directory. It never stores credentials, private addresses, login identifiers, provider account IDs, OAuth tokens, recovery data, billing contacts, or permissions.

## Default Author Decision

- `defaultAuthorId` is `diane`.
- Person `diane` resolves to display name `Diane`.
- When public content has no explicit declared author, consumers use `diane`.
- A generic brand byline such as `Team`, `Editorial`, `CommunityGlows Team`, or `L’équipe CommunityGlows` does not override the default merely because it appears in legacy frontmatter.
- Guest, contributor, organization, or co-authored content may override the default only through declared registry identities and an explicit content-level `authorId` or `authorIds` relationship.
- A project brand may be the publisher while Diane remains the human author. Publisher and author are separate meanings.

The default may change only through an explicit operator decision and a registry migration that identifies affected content and structured data. Individual content overrides never mutate the portfolio default.

## Identity Types

### Person identity

A human public identity used for authorship, biography, portrait, personal homepage, public contact, and person-owned profiles.

### Organization identity

A declared company, collective, or editorial organization that may publish or author content only when the project explicitly intends that meaning. It is never inferred from a product name or generic team label.

### Project identity

A product or project presentation identity used for official website, project contact surface, publisher meaning, and project-owned social profiles. A Project identity may reference a default author but does not become that person.

### Official social profile

A canonical public account belonging to one declared person, organization, or project, on one named platform, for a declared purpose.

### Share action

A user action constructed from the current content URL and optional text. A Share action is never an official profile and must not be stored in `socialProfiles`.

## Canonical Registry Shape

The registry contains five top-level fields:

- `schemaVersion`: registry contract version;
- `defaultAuthorId`: one declared person or organization ID;
- `people`: human identities keyed by stable lowercase ID;
- `organizations`: declared non-person identities keyed by stable ID;
- `projects`: project identities keyed by stable project ID;
- `socialProfiles`: official profiles keyed by stable profile ID.

### Person fields

- `kind`: `person`;
- `displayName`: required public byline;
- `status`: `declared`, `verified`, or `retired`;
- `bios`: locale-to-public-biography map;
- `photoUrl`: HTTPS public portrait URL or null;
- `photoAlt`: localized or canonical meaningful alternative text, or null while no photo exists;
- `publicContactEmail`: explicitly approved public contact address or null;
- `homepageUrl`: canonical public homepage or null;
- `socialProfileIds`: references to declared profiles.

### Project fields

Each future project record declares `displayName`, `status`, `websiteUrl`, optional `publicContactEmail`, optional localized `bios`, optional `photoUrl`/`photoAlt` or logo authority, `defaultAuthorId`, `publisherId`, and `socialProfileIds`. Missing project records remain absent until product truth is supplied; consumers must not manufacture them from repository owners, package names, or platform links.

### Social profile fields

Each future profile record declares:

- `platform`: canonical platform ID such as `github`, `linkedin`, `instagram`, `youtube`, `x`, `bluesky`, or a project-approved alternative;
- `canonicalUrl`: exact HTTPS profile/channel URL, never only a platform homepage;
- `handle`: public handle/channel name when the platform exposes one;
- `ownerType`: `person`, `organization`, or `project`;
- `ownerId`: an existing registry identity;
- `purpose`: `author`, `project`, `support`, `community`, `video`, `code`, or another project-declared purpose;
- `locales`: supported public locales or an empty all-locales list;
- `status`: `declared`, `verified`, or `retired`;
- `verifiedAt`: ISO date/time or null until account ownership and destination are verified;
- `lastCheckedAt`: ISO date/time or null until the link is checked;
- optional `replacedByProfileId` for an intentional migration.

Profile IDs remain stable when a handle or URL changes. Historical URLs may be retained in migration evidence, not as duplicate active profiles.

## Unknown, Declared, Verified, And Retired

- **Unknown:** null/empty field; do not render or infer it.
- **Declared:** operator or governed project source supplied the public value; it may be rendered when safe.
- **Verified:** ownership/purpose and destination were checked at `verifiedAt`; verification is scoped and expires according to project policy.
- **Retired:** no longer presented as active; consumers omit it and may follow `replacedByProfileId`.

Discovery is not declaration. A GitHub repository owner, generic platform link, package author, email in Git config, provider account, or search result is only a candidate until the operator or project authority declares it.

## Photo, Biography, Homepage, And Contact

- `photoUrl` must be an explicitly declared public HTTPS asset with stable delivery, provenance, dimensions or responsive behavior owned by the project, and no expiring/private signature.
- `photoAlt` names the person when the portrait conveys identity; decorative duplicate portraits use empty alternative text at the component layer without deleting the canonical description.
- `bios` may be localized. Translation preserves facts and voice; it does not invent credentials, titles, achievements, pronouns, or claims.
- `homepageUrl` is a declared canonical public destination, not a guessed social profile or repository.
- `publicContactEmail` must be explicitly approved for publication. Never infer it from a login, authentication, billing, legal, support, provider, Git, WHOIS, commit, or private email.
- Consumers render public email through safe accessible link text and project anti-abuse policy. Structured data includes it only when the project explicitly allows that additional exposure.

## Consumer Resolution

### Content and CMS

Resolve `authorId`/`authorIds` first, then `defaultAuthorId`. Store stable IDs in content and CMS records; derive names, photo, bio, contact, homepage, and profiles at render/export time. A copied display name is compatibility data, not the authority.

### Design and components

Author cards, bylines, profile blocks, contact identity, social-link lists, publisher blocks, and footers consume the same resolved view model. Components omit unavailable optional fields cleanly, use project tokens, preserve accessible names and focus, and distinguish external profiles from sharing actions.

### Marketing and campaigns

Founder, author, spokesperson, contact, and product-account references use declared IDs. Campaign copy never substitutes a project account for Diane, invents a founder credential, or sends readers to a generic platform homepage.

### SEO and structured data

Person or Organization author nodes, publisher nodes, `sameAs`, profile URLs, images, and contact properties derive from registry identities and current publication status. `sameAs` contains only applicable declared/verified official profiles; share URLs and generic platform homepages are forbidden.

### Localization

Names, handles, URLs, IDs, and emails remain stable. Bios, photo alternatives, labels, purposes, and surrounding copy may be localized. Missing localized biography is omitted or follows a project-declared fallback; it is never machine-invented as fact.

## Public Identity Readiness`n`nUntil a project-owned registry and readiness validator exist, consumers must resolve identity from declared project sources and report missing values explicitly. Do not claim readiness when required public identity data is absent.`n`n## Drift Rules

Flag for review when:

- content omits `authorId` and renders something other than the default `Diane`;
- legacy bylines use `Team`, `Editorial`, `CommunityGlows Team`, `L’équipe CommunityGlows`, or equivalent generic wording without a declared organization author;
- a purported profile is only `https://instagram.com`, `https://linkedin.com`, another platform homepage, a search URL, or an authentication/management URL;
- the same profile URL has multiple active IDs or ambiguous owner/purpose;
- public components hardcode names, bios, photos, email, homepage, handles, or profile URLs outside the registry adapter;
- a retired or unknown profile appears in `sameAs`, footers, author cards, campaigns, or metadata;
- a private or operational email appears in the public registry or output.

Drift does not authorize automatic replacement of a legitimate guest or organization author. Resolve the intended identity from project truth first.

## Accessibility, Privacy, And Security

- Social links expose platform and owner in their accessible name; icon-only links require a programmatic label.
- External links use safe project behavior and visible focus; opening a new tab is never the only way to identify destination.
- Missing or failed portraits preserve the byline and do not expose storage URLs or private fallbacks.
- Public identity data is minimized to declared presentation needs and remains separate from authentication and authorization.
- The registry never proves ownership, grants publishing access, connects a social account, or stores credentials.
- Avoid unnecessary email exposure in metadata, client bundles, or scraping-friendly surfaces when the public contact experience can use a protected form or project-declared alternative.

## Pressure Scenarios

### PUBLIC-ID-DEFAULT-AUTHOR

An article has no `authorId`. It resolves to `diane`, renders `Diane`, and omits unknown photo, bio, email, homepage, and profiles without generic-team substitution.

### PUBLIC-ID-GENERIC-BYLINE

Legacy frontmatter contains `CommunityGlows Team`, `L’équipe CommunityGlows`, `Team`, or `Editorial`. The consumer flags drift unless that exact organization identity and author intent are declared.

### PUBLIC-ID-PLATFORM-HOMEPAGE

A project contains `https://instagram.com` or `https://linkedin.com`. The URL is not eligible for an Official social profile or `sameAs` until an exact owned profile is declared.

### PUBLIC-ID-PERSON-VS-PROJECT

Diane and a product both have accounts on the same platform. Consumers select the identity by `ownerType`, `ownerId`, and `purpose`; author cards do not show the product profile and project footers do not silently show a personal profile.

### PUBLIC-ID-PRIVATE-CONTACT

A login, authentication, billing, legal, support, or private email exists elsewhere in the repository or provider. It is never copied to `publicContactEmail` without explicit publication approval.

### PUBLIC-ID-STALE-PROFILE

A handle or URL changes. The existing profile ID becomes updated or retired with replacement evidence, every canonical consumer resolves the new active destination, and duplicate active links are rejected.

## Proof Matrix

| Claim | Minimum proof |
| --- | --- |
| Default author is governed | Parse the registry and assert `defaultAuthorId=diane`, one seeded person, and `displayName=Diane`. |
| Unknown data is safe | Assert undisclosed photo, bio, email, homepage, projects, and profiles remain null/empty and are omitted by representative adapters. |
| Identity types remain distinct | Contract tests cover person/project/organization/profile/share boundaries and explicit author overrides. |
| Social links are official | Validate HTTPS exact-profile shape, owner references, status, and rejection of generic platform homepages. |
| Consumers are aligned | Direct loader checks plus adapter/component/metadata tests for affected projects when populated. |
| Existing products conform | Project-specific drift scans and rendered proof; this shared contract alone does not remediate product content. |

## Stop Conditions

Stop, omit the field, or report partial when:

- a photo, biography, public email, homepage, author override, or profile is not explicitly declared;
- profile ownership, purpose, destination, or publication consent is ambiguous;
- the requested value comes only from private/auth/billing/provider data or repository metadata;
- a consumer would duplicate identity values instead of resolving the registry;
- a project-specific population or remediation lacks its own approved scope and proof;
- completion would require account access, credentials, provider mutation, publication, deployment, commit, or push outside the active authority.

## Maintenance Rule

Update the shared contract when identity types, registry fields, resolution, privacy, accessibility, structured-data, verification, or drift rules change. Populate and update actual values in the registry through project/portfolio truth review; do not edit this doctrine merely because one person's photo, email, bio, or handle changes.
