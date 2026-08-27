# Design

## Source of truth

- Status: Active
- Last refreshed: 2026-08-27
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
  - Arm A64 instruction-reference composition, using `ADD (immediate)` as the
    concrete page study: short purpose, encoding diagram, per-variant assembly,
    shared decode pseudocode, assembler symbols, operation pseudocode, then
    operational information
  - `.codex/skills/pto-asl/references/arm-style.md`

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
  animation, diagrams, implementation guidance, and common pitfalls. The UI
  presents these as reader aids without repeated legalistic status banners;
  semantic authority is established once, through the directly embedded ASL
  and the source ledger at the end of the page. Reader aids must not redefine
  instruction semantics.
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
  engineering workbench. The dark-first palette uses obsidian neutrals,
  oxidized red for primary/current-route emphasis, and brushed gold for focus,
  source identity, and selected-data highlights. It is Huawei/Ascend-inspired
  in tone without claiming or reproducing an official brand system.
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

- Architecture
- All instructions
- Scalar
- Block
- Tile
- NDF
- NDF graph
- Decisions / ADR
- Search

Scalar, Block, and Tile navigation uses an exact released-surface facet. It must
not be implemented as a free-text search whose substring matches can cross
surface boundaries.

Every primary reading route uses a stable left navigation rail on desktop,
including the homepage, Architecture landing page, instruction workbenches,
NDF indexes and exploration, and ADR/Decision entry points. The rail is ordered
as Home, Architecture, All instructions, Scalar, Block, Tile, NDF, NDF graph,
Decisions, and Search. On the instruction index, the `surface` URL query
parameter is the canonical selected facet; rail links, filter buttons, browser
history, and current-route state must remain synchronized with it. The rail
shows hierarchy and the current route, may collapse individual groups, and is
never fully hidden by default on desktop. The top navbar remains a compact set
of direct entries rather than the only navigation surface.

The native Docusaurus Reference sidebar remains the stable left navigation for
governance, status, development, and release documents that are not canonical
unit workbenches. Architecture, Scalar, Block, and Tile unit documents do not
remain in that sidebar: their legacy `/reference/...` URLs redirect to the one
canonical unit page. The Reference sidebar marks the exact current project
record, while the global top navbar retains Home, Architecture, instructions,
NDF, and Search access without duplicating two rails. Custom routes use the
shared `PortalShell` and `SpecNavigation` components instead of duplicating
route-specific navigation. At tablet and phone widths the persistent rail
becomes a clearly labelled navigation button and in-flow drawer; it does not
overlay or obscure the document.

English uses `Architecture`. Simplified Chinese uses the concise label `架构`.
Navigation must not use `PTO Architecture`, `PTO架构`, `PTO ISA`, or `PTO 手册`
as sibling labels for the same destination. Formal release identity and the
normative product name remain unchanged where those names are actual source or
version identities.

### Default flow

```text
Architecture
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

### Architecture landing-page reading order

The `/architecture/` route is a reader-first map over current architecture
owners, not a replacement architecture manual. It presents:

1. a compact mental model connecting program, Core/PE execution, Scalar and
   Block/bundle control, Tile operations, state, and memory;
2. a relationship table and a typical implementation reading path before any
   source inventory;
3. source-backed topics for execution/programming model, architecture state,
   register classes, memory model, type/shape model, fault/diagnostic model,
   and version/compatibility;
4. short reader-guide excerpts projected from the exact owning units, with
   direct links to their workbenches and original ASL;
5. explicit source gaps when the current owners distribute or omit a requested
   contract, rather than a generic explanation that invents one; and
6. a collapsed provenance ledger after the human reading path.

The site build owns the topic-to-owner map and validates every referenced unit,
source path, source hash, reviewed reader-guide hash, and exact block identity.
Typical scenarios and source boundaries are exact bound reader-guide blocks,
not hand-written architectural claims. React renders the projection and may
supply localized navigation labels, but it must not carry a second copy of
architectural semantics.

### Core routes

- `/` — latest release landing page and global search.
- `/search` — implementation-oriented search results and filters.
- `/instructions/` — complete released instruction index with Scalar, Block,
  and Tile facets; surface subroutes retain the active facet.
- `/architecture/` — architecture, state, memory, profile, and instruction
  classification entry points.
- `/instructions/<surface>/<classification>/<mnemonic>/` — instruction
  workbench.
- `/ndf/` — complete source-backed NDF index.
- `/ndf/<clause-id>/` — readable clause, owner, references, evidence index, and
  local relationship graph.
- `/explore/ndf/` — repository-wide Plotly/WebGL relationship explorer.
- `/evidence/` — release traceability, coverage, readiness, and manifests.
- `/guides/` — non-normative implementer guides and demonstrations.
- `/releases/` — latest release identity and immutable historical releases.
- `/project/` — governance, contribution, repository layout, ADRs, and open
  questions.

### One canonical unit page

Generated Markdown under `docs/{arch,scalar,block,tile}/` remains the checked-in
ASL projection and reader-guide source, but it is not published as a second
instruction/reference page. Every released unit has one canonical workbench
route that renders the Markdown reader blocks, exact embedded ASL, NDF,
Decision/AVS evidence, and provenance together. Legacy `/reference/...` unit
URLs redirect to that canonical route. The Docusaurus Reference plugin retains
only governance, status, development, and release documents that are not unit
workbenches.

The instruction and NDF indexes are generated from the same release
traceability graph and route manifest. They never maintain a second handwritten
catalog. Every NDF detail route resolves the exact canonical clause body and
links every owning/affected unit back to its canonical workbench.

### Content hierarchy on an instruction route

1. Mnemonic, one-sentence purpose, and stable instruction identity.
2. For bundle-defined Tile operations, the complete bundle/block syntax comes
   first: ordered BSTART/B.xxx/BSTOP rail, legal variants, minimum and complete
   examples, occurrence constraints, parameter sources, defaults, mutual
   exclusions, and links to every command owner.
3. The BSTART encoding follows under the explicit title `Entry instruction
   encoding`. It must never imply that the entry command is the whole Tile
   operation.
4. Exact decode ASL that binds encoded fields into small typed locals and
   rejects reserved combinations before effects.
5. An assembler-symbol table generated from the same ASL/catalog owner,
   explaining each visible operand, option, default, and assigned value.
6. A semantic execution path ordered as bundle inputs, decode/bind, derived
   state, legality, complete-footprint preflight, operation, and publish/commit.
   Every stage embeds its exact mnemonic-owner DOC region. When a stage executes
   a shared helper, it embeds the exact referenced ASL fragment with module,
   lines, source hash, fragment hash, and source link.
7. Human-readable operational information: effects, ordering, fault boundary,
   aliases, constraints, and bounded walkthroughs.
8. NDF and ADR bodies expanded inline from their canonical sources. Stable ID
   chips and human-readable content are primary; provenance is collapsed below.
9. A final source ledger containing release, commit, ASL path and hash,
   generated-document path and hash, and exact ASL/NDF owner links.

Release and source provenance stays available but does not interrupt the
reader-first explanation at the top of the page.

### Arm-style embedding contract

The Arm `ADD (immediate)` page is a structural reference, not a semantic source.
Its important property is that encoding, decode, symbols, and operation are
separate projections of one instruction definition:

- the register diagram appears once, before variant-specific assembly forms;
- each assembly placeholder links conceptually to one symbol definition;
- decode pseudocode is embedded in place and only performs field binding and
  legality preparation;
- operation pseudocode is embedded separately and performs the architectural
  computation and writeback;
- shared helpers remain links/references rather than copied implementations;
- operational notes follow the exact pseudocode instead of interrupting it.

PTO must preserve the same separation. A `DOC-BEGIN: decode` region that merely
returns an operation or handler enum is instruction-selection linkage, not a
reader-visible decode. The portal must label it as such and must not present it
as Encoding/Decode ASL. Promoting it to a true Decode section requires enhancing
the owning ASL to expose field binding and legality, regenerating projections,
and rerunning the normative verification flow.

## Design principles

- Human reading before provenance chrome: begin with what the instruction is,
  its assembly syntax, and its behavior; place commit and source identity in the
  final source ledger.
- Source inside the explanation: the working-mechanism section embeds the exact
  ASL operation region instead of paraphrasing it into a second semantic source.
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

- Color: dark-first obsidian reading and workbench surfaces; vivid signal red
  for brand, primary actions, and current-route emphasis; high-contrast gold/
  yellow for focus,
  source identity, and selected-data highlights. Light mode remains available
  as a warm neutral fallback. Green, amber, and danger colors retain distinct
  status meanings; brand red never means failure by itself.
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
- `PortalShell`
- `SpecNavigation`
- `ArchitectureOverview`
- `ReleaseIdentity`
- `SourceIdentity`
- `SourceLedger`
- `AssemblySyntax`
- `ASLViewer`
- `GeneratedContract`
- `EncodingBitfield`
- `NdfClause`
- `InstructionIndex`
- `NdfIndex`
- `NdfDetail`
- `InstructionComposition`
- `SemanticExecution`
- `SemanticIdPath`
- `NdfNeighborhood`
- `NdfGlobalExplorer`
- `EvidenceIndex`
- `StateTransitionDemo`
- `ReleaseValidity`
- `LanguageFallbackNotice`

### Component contracts

- `PortalShell` supplies the shared desktop rail and mobile navigation drawer
  to custom routes without duplicating the native Reference sidebar. It keeps
  the document in normal flow and never narrows the content below its readable
  responsive width.
- `SpecNavigation` owns one locale-aware route tree. It exposes the current
  location through visible styling and `aria-current`, keeps desktop navigation
  visible by default, and provides an explicit mobile open/close control with
  keyboard and screen-reader semantics.
- `ArchitectureOverview` consumes only build-generated architecture topic data
  resolved from released ASL units and their reviewed reader-guide projections.
  It renders a mental model, topic relationships, scenarios, exact owner links,
  source boundaries, and a collapsed provenance ledger. Missing or distributed
  contracts remain visible as source gaps.
- `ASLViewer` receives build-generated source text, line information, content
  hash, and exact release permalink. It shows the operation region first,
  decode second, and the complete owner on demand. It never accepts hand-written
  semantic replacement text.
- `InstructionComposition` consumes only structured owner metadata parsed by
  the build plugin. It is generic across bundle instruction families and
  renders ordered rails, variants, constraints, defaults, examples, command
  detail routes, and exact command-owner links. React contains no TLOAD
  semantic strings beyond presentation labels.
- Every Tile composition rail and generated Markdown block-composition section
  consumes the same ASL-owned `contract.block_composition` projection. A second
  `metadata.block` form may provide additional structural detail only when the
  build validates it against the same owner; it must not silently omit a legal
  variant declared by the contract.
- `InstructionIndex`, `NdfIndex`, and `NdfDetail` consume only build-generated
  release data. Index entries link to canonical workbench/detail routes and
  preserve stable identity, source path, and hash.
- `SemanticExecution` consumes owner-declared stage bindings. Owner DOC regions
  must surround executable ASL. Shared-module fragments are extracted from
  explicit source markers at build time; missing, duplicate, reversed, non-ASL,
  or hash-inconsistent regions fail the build.
- `SemanticIdPath` never guesses owner boundaries by splitting a stable ID.
  Build-time schema data supplies surface, owner, category/kind, and case or
  decision number. The default view shows the most useful two to four facets;
  the complete ID remains in the copy action, search index, deep-link anchor,
  tooltip, provenance, and accessible name.
- `NdfClause` renders canonical body text expanded by default. Mouse drag and
  keyboard/touch move buttons may temporarily reorder whole cards in the
  current page session. Reordering never changes URL, source order, identity,
  hash, relationship data, or canonical source; reload restores source order
  and a reset action restores it immediately.
- ADR/NDF content assets are parsed once from canonical sources and reused by
  every referring route. ADR cards render the actual Context/Decision/Rationale/
  Consequences structure present in the source, including lists, tables, and
  code. NDF cards render the exact owning clause body. A link-only card is a
  product defect.
- ASL code uses one repository-owned Prism grammar for workbench sources,
  generated reference fences, and expandable AVS sources. Keywords, functions,
  built-ins, literals, comments, and operators are distinguishable in light and
  dark themes; line numbers retain WCAG contrast, and source meaning never
  depends on color alone.
- `AssemblySyntax` reads canonical forms from the ASL-owned instruction metadata
  already present in route data. It never maintains a separate syntax table.
- Every Tile page begins its Assembly section with one uniform high-level call
  grammar: `Mnemonic <shape/type/attribute parameters> inputs -> outputs`.
  Build-time projection derives parameter labels from ASL-owned BSTART/B.DATR/
  B.DIM composition and derives input/output order from `contract.operands`.
  The page exposes a binding table from every high-level placeholder back to
  its exact source field/declaration. LinxISA v0.58 Tile syntax is a structural reading
  reference; current PTO owning ASL wins on explicit destinations, operand
  order, and the removal of legacy `.reuse` spellings.
- `AssemblerSymbols` joins catalog fields with ASL-owned operand roles, defaults,
  assigned values, and reserved-value behavior. It never invents descriptions.
- `SourceLedger` is the last major section on a workbench route and consolidates
  release, commit, ASL/NDF owners, generated projection paths, and hashes.
- `GeneratedContract` consumes catalog or ASL-derived data and marks its source
  artifact.
- `EvidenceIndex` supports filtering, per-group expand/collapse, expand all,
  collapse all, keyboard navigation, and exact source opening.
- `NdfGlobalExplorer` dynamically loads the smallest reviewed Plotly/WebGL
  bundle, uses deterministic build-generated positions, and opens a readable
  clause detail panel on selection.
- `StateTransitionDemo` is presented as an interactive walkthrough and cites the
  ASL functions and evidence it demonstrates in the final source ledger.
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
  - the mobile specification-navigation control is reachable before document
    content, announces expanded state, and returns focus predictably when
    closed;
  - the current left-navigation item uses `aria-current="page"`; group labels
    and disclosure controls have explicit accessible names;
  - NDF reordering provides Move up, Move down, and Restore default order
    controls with polite announcements; the drag handle is separate from body
    selection and links.
- Contrast/readability:
  - code, identifiers, metadata, and status text meet contrast requirements;
  - status never depends on color alone.
  - ordinary text meets at least 4.5:1 contrast and meaningful UI boundaries
    meet at least 3:1; dark red is not used for small text on dark surfaces;
  - focus uses the gold focus-ring token and remains visible in forced-colors
    mode; red/gold categories always retain text, shape, or role labels.
- Screen-reader semantics:
  - every interactive graph has a concise text summary and a structured list or
    table fallback;
  - dynamic selection and search results use polite announcements;
  - source line numbers are not read as part of every code line unless
    explicitly requested.
  - Semantic ID chips expose their role labels and the complete stable ID in
    the group and copy-button accessible names.
- Reduced motion and sensory considerations:
  - animations become step changes when reduced motion is requested;
  - no flashing, looping, or background motion;
  - WebGL views have non-animated and non-WebGL fallbacks.

## Responsive behavior

- Desktop: persistent left navigation plus the full workbench, Plotly/WebGL
  exploration, animation, filtering, zooming, and side-by-side source/evidence
  views. The rail participates in layout and never overlays the document.
- Tablet: the left rail becomes a visible in-flow navigation drawer/button;
  retain full capability with smaller local graph limits and stacked detail
  panes.
- Phone: preserve complete readable source, NDF, generated contracts, and
  evidence; expose the same navigation hierarchy through the labelled drawer;
  default large graphs to a local neighborhood or indexed list.
- WebGL unavailable: use static SVG, tables, and relationship lists.
- Touch devices: do not depend on hover; selection opens explicit details.
- Touch devices use the same NDF move buttons when native drag is unsuitable;
  no persistence or account state is introduced.

## Interaction states

- Loading: server-rendered identity and text remain visible while optional
  visualization chunks load.
- Empty: explain whether filters returned no results or the release has no
  relationship of that type.
- Error: identify the failed data artifact or component and retain the static
  source/evidence fallback.
- Success: show the exact validated release and commit, not a generic green
  dashboard state.
- Reordered NDF view: announce the temporary move; Restore default order returns
  to canonical source order; reload always discards session order.
- Disabled: explain missing browser capability or unavailable relationship and
  offer the fallback.
- Offline/slow network: documentation routes remain usable after their static
  HTML loads; large visualization chunks are optional.

## Content voice

- Tone: precise, concise, implementation-oriented, and explicit about evidence
  boundaries.
- Default language: English.
- Supported locales: `en` and `zh-CN` from the first framework release.
- Use `Architecture` in English navigation and `架构` in Simplified Chinese.
  Do not mix `PTO Architecture`, `PTO架构`, `PTO ISA`, or `PTO 手册` as labels
  for the same navigation level.
- Chinese coverage may grow incrementally across landing pages, navigation,
  guides, and demonstrations.
- ASL/NDF source, stable IDs, paths, and evidence identities are never
  translated.
- Missing Chinese content falls back visibly to English. Machine translation is
  not presented as reviewed content.
- Prefer direct section titles such as `Assembly syntax`, `Encoding`,
  `Assembler symbols`, `Decode ASL`, `Operation ASL`, `Behavior`, `NDF clauses`,
  `Evidence`, and `Sources and release identity`. Put the one-sentence
  instruction definition directly beneath the mnemonic title.
- Instruction pages do not explain their own projection machinery in eyebrow
  labels. Remove labels such as `At a glance`, `Generated from released
  catalog`, `Embedded directly`, and similar source-status microcopy; establish
  provenance through the final source ledger instead.
- NDF clause bodies are visible in place under their stable IDs. Their source
  links remain available, but the reader does not have to open a disclosure to
  read current clause text.
- NDF and ADR card headers prioritize a human title/status plus two to four
  semantic ID facets. Commit, path, hashes, version, and other provenance live
  in a collapsed `Sources and references` section without weakening build-time
  validation.
- Do not show `Unpublished`, `preview`, or repetitive `non-normative` banners in
  page chrome. An unreleased build uses the neutral label `Release candidate`;
  release eligibility and exact provenance remain machine-readable and visible
  in the final source ledger.

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
  - NDF/ADR records are parsed once from allowlisted canonical paths and reused
    across routes; missing IDs, duplicate IDs, source-hash mismatches, reversed
    regions, and unallowlisted paths fail closed;
  - bundle composition and semantic-stage metadata remain ASCII-compatible
    owner data; localized JSON strings may use Unicode escapes so ASLRef input
    remains ASCII while the site renders reviewed `zh-CN` text;
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
- TLOAD bundle-first prototype with Ordinary Local, Local CUBE, and Ordinary
  Shared variants, entry-encoding separation, executable owner stages, and
  exact shared-helper fragments.
- Inline canonical NDF and ADR content, source-derived semantic ID paths, and
  session-only accessible NDF card reordering.
- Searchable and collapsible evidence index.
- One TLOAD-only interactive state-transition walkthrough whose source citations
  are consolidated with the page provenance.
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
