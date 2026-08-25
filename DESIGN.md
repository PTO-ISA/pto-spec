# Design

## Source of truth

- Status: Active
- Last refreshed: 2026-08-25
- Primary product surface: PTO Formal Specification Portal at
  `https://pto-isa.github.io/`
- Product owner: `PTO-ISA/pto-spec`
- Production content policy: the public site always represents the latest formal
  PTO ISA release. Development branches and unreleased `main` content may appear
  only in immutable review previews.
- Evidence reviewed:
  - `README.md`
  - `GOVERNANCE.md`
  - `CONTRIBUTING.md`
  - `docs/development/repository-layout.md`
  - `docs/mkdocs/mkdocs.yml`
  - `scripts/instruction_docs.py`
  - `scripts/ndf.py`
  - `spec/catalog/`
  - `spec/evidence/adr-index.json`
  - `spec/evidence/release-traceability-readiness.json`
  - `PTO-ISA/pto-isa.github.io` and its current Pages publication contract
  - Docusaurus documentation for MDX, content plugins, lifecycle APIs, static
    assets, SSG, versioning, internationalization, and GitHub Pages deployment
  - Plotly.js documentation for WebGL traces, animations, React integration,
    partial bundles, updates, and WebGL context limits

## Normative ownership

The portal is a generated view over the repository. It never owns ISA meaning.

```text
asl/**/*.asl
    -> generated Markdown mirror
    -> AVS
    -> catalog and commit-scoped evidence
    -> Docusaurus routes and interactive views
```

- `asl/{arch,block,scalar,tile}/` is the original and only current normative
  source for ASL/NDF semantics.
- `docs/{arch,block,scalar,tile}/` is a generated Markdown mirror with bounded
  non-normative supplementary content.
- Exact decode, legality, defaults, state effects, ordering, faults, and
  operation semantics must be embedded or generated from their ASL/catalog
  owners. They must not be rewritten by hand in Markdown, React components, or
  visualization data.
- Hand-written documentation may demonstrate behavior through examples,
  animation, diagrams, implementation guidance, and common pitfalls. It must be
  visibly labeled non-normative and must not redefine instruction semantics.
- If an ASL/NDF explanation is insufficient, improve the owning ASL/NDF source,
  regenerate every projection, add or update evidence, and run the required
  validation workflow. Do not repair the gap only in the website.
- ADRs explain decision history. They do not replace current ASL/NDF meaning.
- Pending, skipped, failed, stale, or different-commit evidence must retain its
  actual state and must never be rendered as success.

## Brand

- Personality: authoritative, precise, technically ambitious, calm, and
  implementation-oriented.
- Trust signals: exact release identity, commit SHA, source path, line range,
  content hash, validation state, and direct links to evidence.
- Visual posture: a restrained specification manual combined with a professional
  engineering workbench.
- Avoid:
  - cyberpunk neon and decorative particle effects;
  - excessive glass effects, gradients, shadows, or marketing cards;
  - animation without semantic or navigational purpose;
  - dashboards that turn nuanced readiness states into a single misleading
    score;
  - visualizations that become a second semantic representation.

## Product goals

- Make the latest released PTO ISA fast to search, understand, implement, and
  review.
- Let an implementer move from a mnemonic or NDF identity to encoding, embedded
  ASL, state effects, evidence, and decision history without changing context.
- Make NDF/ASL/ADR/AVS traceability explorable at repository scale.
- Present exact sources and evidence in a clear, readable form even when
  JavaScript or WebGL is unavailable.
- Provide high-quality interaction and animation where it explains decode,
  state transition, preflight, commit, rollback, or traceability.
- Support English and Simplified Chinese in the framework from the first
  release.
- Make site validity a release-blocking property.

## Non-goals

- The website does not define, normalize, infer, or amend PTO semantics.
- The production site does not publish an unreleased `main` snapshot.
- The first implementation slice does not provide a bespoke animation for every
  ASL unit.
- Plotly/WebGL is not loaded on every documentation route and is not used for
  encoding bitfields or small diagrams when accessible HTML, CSS, or SVG is
  better.
- Every active mnemonic and Architecture unit requires reviewed English and
  Chinese reader guides. Internal non-mnemonic Scalar/Block/Tile model units may
  retain the explicit English fallback until separately promoted into the target
  set.
- The retired MkDocs site is not retained as an active alternate manual. Git
  history and redirects preserve navigation without publishing a stale second
  contract.
- The site has no runtime backend, GitHub token, private repository fetch, or
  server-side search dependency.

## Success signals

- Implementers can search by mnemonic, NDF ID, unit ID, test ID, field, engine,
  family, or source path and reach the correct workbench route.
- Every released ASL unit has one route with its exact embedded source identity,
  generated Markdown mirror, NDF relationships, tests, and evidence.
- Every active mnemonic and Architecture unit has a reader-first English guide,
  a claim-aligned Chinese localized projection, and independent semantic and
  translation review evidence.
- Every generated count and relationship agrees with the release commit's
  catalog and traceability evidence.
- Reviewers can expand, collapse, filter, and open evidence without losing the
  selected instruction or clause context.
- The NDF graph remains usable at full repository scale and provides a readable
  local-neighborhood mode.
- Release publication fails closed when site generation, links, source hashes,
  browser behavior, accessibility, visual checks, or performance gates fail.

## Personas and jobs

### Primary persona: implementer

- Compiler, assembler, disassembler, emulator, simulator, RTL, verification,
  and toolchain engineers.
- Primary job: search for a mnemonic or stable identity and obtain the exact
  released contract, source, encoding, dependencies, and executable evidence.
- Secondary jobs: compare related operations, inspect state interactions, trace
  a requirement to tests, and open exact source lines.

### Secondary persona: specification reviewer

- Architecture reviewers, formal-model reviewers, and release reviewers.
- Primary job: prove that ASL/NDF, generated documentation, catalogs, AVS, ADRs,
  and commit-scoped evidence form one closed release contract.
- Secondary jobs: find unresolved gaps, inspect decision history, and review a
  release candidate preview before publication.

### Supporting persona: learner

- Developers learning PTO or approaching a family for the first time.
- The homepage serves this human reading path first: architecture identity,
  then Scalar, Block, and Tile surfaces, then ADR/NDF records. Implementation
  workbenches remain optimized for the primary implementer persona.

## Information architecture

### Primary navigation

- PTO Architecture
- Scalar
- Block
- Tile
- ADR / NDF
- Search

Scalar, Block, and Tile navigation uses an exact released-surface facet. It must
not be implemented as a free-text search whose substring matches can cross
surface boundaries.

### Default flow

```text
PTO Architecture
    -> Scalar
    -> Block
    -> Tile
    -> ADR decision history and NDF current clauses
    -> exact unit workbench, source, and executable evidence
```

### Homepage reading order

1. Explain PTO as one source-defined architecture and identify the released
   architecture owner.
2. Introduce the Scalar surface and its released inventory.
3. Introduce the Block/command surface and its released inventory.
4. Introduce the direct Tile surface and its released inventory.
5. Explain the distinct roles of ADR decision history and NDF clauses, then
   offer search, graph exploration, and exact source workbenches.

Homepage prose is an orientation layer, not a second semantic manual. It may
summarize released inventory and repository structure, but every semantic claim
must resolve to the embedded ASL/NDF owner.

### Core routes

- `/` — latest release landing page and global search.
- `/search` — implementation-oriented search results and filters.
- `/architecture/` — architecture, state, memory, profile, and instruction
  classification entry points.
- `/instructions/<surface>/<classification>/<mnemonic>/` — instruction
  workbench.
- `/ndf/<clause-id>/` — readable clause, owner, references, evidence index, and
  local relationship graph.
- `/explore/ndf/` — repository-wide Plotly/WebGL relationship explorer.
- `/evidence/` — release traceability, coverage, readiness, and manifests.
- `/guides/` — non-normative implementer guides and demonstrations.
- `/releases/` — latest release identity and immutable historical releases.
- `/project/` — governance, contribution, repository layout, ADRs, and open
  questions.

### Content hierarchy on an instruction route

- Identity, release, commit, source path, and hash.
- Canonical assembly and generated encoding.
- Embedded ASL decode and operation regions.
- Generated legality, defaults, operands, state, memory, ordering, and fault
  contracts.
- Interactive demonstration labeled non-normative.
- NDF clauses and dependency neighborhood.
- Expandable, searchable evidence index.
- Decision history and exact source links.

## Design principles

- Source before interpretation: place exact owner identity and embedded source
  ahead of hand-written explanation.
- One context per implementation task: instruction, NDF, source, and evidence
  views remain in the same workbench route.
- Progressive disclosure: readable contract first, deeper source and graph views
  on demand.
- Interaction must explain: motion shows a meaningful transition, dependency,
  or evidence relationship.
- Static before enhanced: every route has accessible server-rendered HTML before
  Plotly/WebGL enhancement.
- Release exactness over freshness: production represents the latest verified
  release, never an unverified newer draft.
- Failure states remain visible: the UI does not hide missing, stale, or failed
  evidence.

## Visual language

- Color: neutral light reading surfaces; dark engineering workbench surfaces;
  blue and cyan for selection and data focus; restrained green, amber, and red
  only for explicit validated, pending, and failing states.
- Typography: highly readable sans-serif UI text, stable monospace source and
  identifiers, and a restrained heading scale suitable for dense reference
  pages.
- Spacing/layout rhythm: compact but not cramped; reference tables and source
  should occupy more space than surrounding chrome.
- Shape/radius/elevation: small radii, subtle separators, minimal elevation, and
  no decorative nesting of cards.
- Motion:
  - use short focus transitions for search and graph navigation;
  - use step animation for decode, preflight, state mutation, commit, and
    rollback demonstrations;
  - never autoplay a long or looping sequence;
  - respect `prefers-reduced-motion` and provide explicit step controls.
- Imagery/iconography: technical diagrams, encoding bitfields, state maps, and
  restrained line icons. Avoid stock imagery and ornamental illustrations.

## Components

### Shared components

- `GlobalSpecSearch`
- `ReleaseIdentity`
- `SourceIdentity`
- `ASLViewer`
- `GeneratedContract`
- `EncodingBitfield`
- `NdfClause`
- `NdfNeighborhood`
- `NdfGlobalExplorer`
- `EvidenceIndex`
- `StateTransitionDemo`
- `ReleaseValidity`
- `LanguageFallbackNotice`

### Component contracts

- `ASLViewer` receives build-generated source text, line information, content
  hash, and exact release permalink. It never accepts hand-written semantic
  replacement text.
- `GeneratedContract` consumes catalog or ASL-derived data and marks its source
  artifact.
- `EvidenceIndex` supports filtering, per-group expand/collapse, expand all,
  collapse all, keyboard navigation, and exact source opening.
- `NdfGlobalExplorer` dynamically loads the smallest reviewed Plotly/WebGL
  bundle, uses deterministic build-generated positions, and opens a readable
  clause detail panel on selection.
- `StateTransitionDemo` is explicitly non-normative and cites the ASL functions
  and evidence it demonstrates.
- A large WebGL component is mounted only after an explicit user action and is
  purged when hidden or unmounted.

### Token ownership

- Docusaurus theme tokens own global typography, color modes, spacing, focus,
  and responsive breakpoints.
- Portal-specific tokens live under `docs/site/src/css/` and must not create an
  unrelated second design system.
- Plotly layouts derive colors and type from portal tokens and redraw after a
  theme change.

## Accessibility

- Target standard: WCAG 2.2 AA.
- Keyboard/focus behavior:
  - all search, tab, disclosure, graph selection, playback, zoom, and source
    actions are keyboard accessible;
  - focus order follows reading order;
  - focus remains visible in light and dark themes.
- Contrast/readability:
  - code, identifiers, metadata, and status text meet contrast requirements;
  - status never depends on color alone.
- Screen-reader semantics:
  - every interactive graph has a concise text summary and a structured list or
    table fallback;
  - dynamic selection and search results use polite announcements;
  - source line numbers are not read as part of every code line unless
    explicitly requested.
- Reduced motion and sensory considerations:
  - animations become step changes when reduced motion is requested;
  - no flashing, looping, or background motion;
  - WebGL views have non-animated and non-WebGL fallbacks.

## Responsive behavior

- Desktop: full workbench, Plotly/WebGL exploration, animation, filtering,
  zooming, and side-by-side source/evidence views.
- Tablet: retain full capability with smaller local graph limits and stacked
  detail panes.
- Phone: preserve complete readable source, NDF, generated contracts, and
  evidence; default large graphs to a local neighborhood or indexed list.
- WebGL unavailable: use static SVG, tables, and relationship lists.
- Touch devices: do not depend on hover; selection opens explicit details.

## Interaction states

- Loading: server-rendered identity and text remain visible while optional
  visualization chunks load.
- Empty: explain whether filters returned no results or the release has no
  relationship of that type.
- Error: identify the failed data artifact or component and retain the static
  source/evidence fallback.
- Success: show the exact validated release and commit, not a generic green
  dashboard state.
- Disabled: explain missing browser capability or unavailable relationship and
  offer the fallback.
- Offline/slow network: documentation routes remain usable after their static
  HTML loads; large visualization chunks are optional.

## Content voice

- Tone: precise, concise, implementation-oriented, and explicit about evidence
  boundaries.
- Default language: English.
- Supported locales: `en` and `zh-CN` from the first framework release.
- Chinese coverage may grow incrementally across landing pages, navigation,
  guides, and demonstrations.
- ASL/NDF source, stable IDs, paths, and evidence identities are never
  translated.
- Missing Chinese content falls back visibly to English. Machine translation is
  not presented as reviewed content.
- Use `normative`, `generated projection`, `non-normative demonstration`,
  `decision history`, `executable evidence`, and `commit-scoped evidence`
  consistently.

## Repository layout

```text
docs/
|-- site/                    # Docusaurus application source
|   |-- src/components/      # Portal React components
|   |-- src/pages/           # Landing, search, and explorer routes
|   |-- src/css/             # Theme extensions and tokens
|   |-- plugins/             # Build-time PTO content integration
|   |-- static/              # Public static assets and .nojekyll
|   `-- docusaurus.config.*
|-- arch|block|scalar|tile/  # Generated ASL Markdown mirrors
|-- guides/                  # Non-normative implementer guidance
|-- demos/                   # Non-normative MDX demonstrations
|-- governance/
|-- releases/
`-- status/

asl/                         # Normative ASL/NDF owners
spec/catalog/                # Generated machine-readable projections
spec/evidence/               # Generated commit-scoped evidence
build/site-data/             # Disposable per-route site data
```

## Implementation constraints

- Framework/styling system:
  - Docusaurus 3 with React and MDX;
  - Plotly.js for data-rich interactive views behind a client-only boundary;
  - reviewed baseline: Docusaurus 3.10.2, React 19.2.8, and the Plotly.js
    4.0.0 `gl2d` minified distribution;
  - exact reviewed package versions are locked by the package manager;
  - the first implementation should evaluate the current stable Docusaurus,
    Plotly.js, and React adapter releases rather than using `latest` at build
    time.
- Content integration:
  - a Docusaurus plugin reads ASL/NDF/catalog/evidence only during build;
  - large data is emitted per route with `createData()` or equivalent static
    files, not injected as global page data;
  - raw source inclusion follows an explicit generated allowlist;
  - every entry carries release, commit, path, line, and content-hash identity;
  - deterministic graph layout is computed during build. Plotly renders and
    interacts with the result but does not own the dependency graph.
- Plotly/WebGL:
  - use a reviewed partial bundle such as the smallest `gl2d`-equivalent bundle
    that provides `scattergl`;
  - use `BrowserOnly` or an equivalent dynamic client boundary for Plotly;
  - use `Plotly.react`, `restyle`, or `relayout` for updates;
  - keep at most one large active WebGL figure on a route and call
    `Plotly.purge()` when it closes;
  - use accessible HTML/CSS/SVG for encoding bitfields and small diagrams.
- Internationalization:
  - English is complete and default;
  - `zh-CN` routing, navigation, locale switch, and fallback behavior ship with
    the first framework release;
  - translations never fork normative source content.
- Hosting:
  - production URL is `https://pto-isa.github.io/` with `baseUrl: /`;
  - `PTO-ISA/pto-spec` owns site source below `docs/site/`;
  - `PTO-ISA/pto-isa.github.io` is the Pages deployment controller;
  - the existing MkDocs publisher from `hw-native-sys/pto-isa` must be disabled
    before cutover;
  - the Pages repository must switch from legacy branch publication to GitHub
    Actions;
  - no compiled site is committed to `PTO-ISA/pto-spec`.
- Compatibility constraints:
  - current stable Chrome, Edge, Firefox, and Safari;
  - current mobile Safari and Chrome for readable documentation and fallback
    views;
  - production remains useful without JavaScript and without WebGL.

## Performance constraints

- Documentation and search routes must not load Plotly.
- Plotly/WebGL is dynamically loaded only for explorer or expanded graph views.
- WaveDrom is dynamically loaded only on routes with released encoding JSON;
  encoding pages retain a server-rendered accessible table and inspectable
  WaveJSON fallback.
- Default documentation-route JavaScript should remain below 350 KiB gzip,
  excluding lazy visualization chunks.
- The Plotly partial bundle and graph data are separate cacheable chunks.
- Repository-wide graph data is filtered or indexed before rendering; local
  views do not mount the entire graph unnecessarily.
- Release build completes inside the GitHub Pages ten-minute deployment limit.
- The published artifact remains below the GitHub Pages one-gigabyte limit.
- Release Lighthouse targets:
  - accessibility at least 95;
  - best practices at least 95;
  - SEO at least 95;
  - desktop performance at least 90;
  - mobile performance at least 80;
  - cumulative layout shift below 0.1.

## Release validity

Site validity is release-blocking. A release is not publishable until all of the
following are true for the same immutable release candidate commit:

- The complete ASL/NDF, documentation projection, catalogs, AVS, and release
  evidence gates pass.
- The Docusaurus build succeeds from a clean checkout with locked dependencies.
- Every released ASL unit has exactly one source-backed route.
- Site identities, source hashes, counts, and relationships equal their release
  evidence inputs.
- There are no broken links, missing assets, stale pages, duplicate routes, or
  unresolved locale routes.
- Search returns exact identities and does not index forbidden or retired
  content.
- Plotly/WebGL explorer, evidence disclosure, source viewer, theme switching,
  locale switching, and fallbacks pass automated browser tests.
- Desktop, tablet, phone, light, dark, reduced-motion, no-WebGL, and no-JavaScript
  paths pass their required checks.
- Accessibility and performance budgets pass.
- A content-addressed preview artifact is produced and reviewed before release
  publication.
- The preview artifact hash and source commit are recorded with the release.
- Production deployment is triggered only from the accepted release event and
  replaces the previous root site atomically.

## Migration and redirects

- The Docusaurus portal replaces the current MkDocs site at
  `https://pto-isa.github.io/`.
- The first production cutover occurs only at a formal release whose immutable
  commit already contains the Docusaurus source and site gates. The existing
  `v0.58.4` tag is not rewritten to bootstrap the portal.
- The old publisher is disabled before the new publisher receives production
  authority.
- Existing URLs receive deterministic redirects when a current released route
  exists.
- An unmapped legacy URL receives a migration notice and search entry point. It
  must not silently serve stale semantics.
- Old generated HTML remains recoverable from Git history but is not an active
  second manual.

## Current implementation scope

- Docusaurus application under `docs/site/`.
- English and `zh-CN` locale framework.
- Latest-release landing page and global specification search.
- One source-backed workbench for each of the 852 released ASL units, in both
  locale trees.
- Generated per-locale unit route ledgers with exact ASL and Markdown projection
  hashes.
- Exact ASL source embedding and generated NDF clause views.
- Searchable and collapsible evidence index.
- One TLOAD-only state-transition demonstration, explicitly non-normative.
- One repository-wide Plotly/WebGL NDF relationship explorer.
- Static and non-WebGL fallbacks.
- Immutable release preview and release-blocking site validation.
- Root-domain cutover plan and redirect manifest.

The initial TLOAD vertical slice established the data contract, source boundary,
design system, release workflow, and interaction model. The current scope applies
that contract to every released ASL unit while keeping TLOAD's animation an
instruction-specific demonstration rather than a semantic source.

## Decision boundaries

Implementation may decide without additional product approval:

- exact React component composition and internal file names under `docs/site/`;
- deterministic graph-layout algorithm and data chunking strategy;
- Docusaurus plugin boundaries and per-route data schema details;
- test framework and screenshot tooling;
- restrained visual tokens consistent with this design;
- fallback representation when it preserves all released information.

Implementation must request review before changing:

- normative ownership or the allowed role of hand-written Markdown;
- the latest-release-only production policy;
- production domain or repository authority;
- release-blocking gate categories;
- supported languages or translation policy;
- primary persona or default search-to-workbench flow;
- accessibility targets or fallback obligations.

## Open questions

- [ ] Compare the initial checked redirect manifest against the final legacy
  sitemap immediately before production cutover.
- [ ] Define the first reviewed Chinese landing-page and navigation translation
  set before locale launch.
