# ADR 0059: Mnemonic and Encoded-Field Contract Closure

- **Status**: proposed
- **Date**: 2026-08-11
- **Deciders**: PTO ISA maintainers

## Context {#PTO-DEC-0059-CONTEXT}

<!-- ndf: kind=info level=may layer=L0 status=draft -->

PTO already projects one ASL file into one generated page for each accepted
mnemonic. The projection proves identity, encoding pieces, catalog constraints,
and handler linkage, but it does not yet prove that every field value has a
named disposition or that every mnemonic page explains the complete
architectural contract.

`B.DATR.DataType` exposes the immediate defect. The field is five bits wide and
therefore has 32 possible values. Twenty-five values name active data types;
seven values are unassigned. The current accepted-value constraint rejects the
unassigned values, but the ASL and generated page do not identify those seven
values as reserved future-extension space. A reader therefore cannot distinguish
an intentionally reserved value from an accidentally omitted definition.

The same completeness problem appears in other forms:

- generated field tables often use the placeholder role “encoded operand or
  control” instead of an architectural meaning;
- a constraint can list accepted values without naming the complement;
- cross-field legality, omission defaults, ignored fields, and no-effect cases
  are not represented uniformly;
- selector-encoded Tile mnemonics can be mistaken for standalone instruction
  words because their pages do not use one common encoding-class vocabulary;
- a semantic-handler name can appear without explaining inputs, results,
  state changes, memory behavior, fault atomicity, or ordering;
- binary comparison can prove masks and matches while missing prose or
  reserved-space drift.

This decision defines the contract that closes those gaps. It does not assign a
new opcode, selector, data type, or instruction semantic.

## Authority and source order {#PTO-DEC-0059-AUTHORITY}

<!-- ndf: kind=req level=must layer=L1 status=draft refines=PTO-DEC-0059-CONTEXT -->

Normative instruction facts MUST have one authored home under `asl/`. Catalogs,
Markdown, MkDocs navigation, traceability, and release evidence MUST be derived
projections. A second hand-maintained JSON or Markdown instruction-description
source MUST NOT be introduced.

Executable ASL owns legality and architectural effects. Structured metadata in
the same ASL unit owns names, field roles, value descriptions, encoding class,
assembly rendering, and cross-references. A repository checker MUST compare
these two surfaces so co-location cannot hide drift.

Shared definitions MUST live once under the matching `asl/arch/` subject and be
referenced by mnemonic ASL units. Mnemonic files MUST NOT repeat large shared
enumerations merely to make their generated pages complete. The generator MUST
expand shared contracts into each relevant page.

Normative ASL and generated instruction pages MUST remain version-neutral.
Release versions belong in release metadata, manifests, and historical status
records, not in reusable instruction semantics.

## Encoded-field domain contract {#PTO-DEC-0059-FIELD-DOMAIN}

<!-- ndf: kind=req level=must layer=L1 status=draft refines=PTO-DEC-0059-AUTHORITY -->

Every encoded field of width `N` MUST define a total disposition for all values
from zero through `2^N - 1`. The disposition is a disjoint partition:

1. **assigned** — the value has an architectural meaning;
2. **reserved** — the value has no current meaning and is held for a reviewed
   future extension.

The assigned and reserved sets MUST be disjoint and their union MUST equal the
full field domain. Immediate and opaque-bit fields whose every bit pattern is
meaningful satisfy the rule by assigning the full domain.

An assigned value MAY still fail a contextual or cross-field legality rule.
That failure does not make the value reserved. Conversely, a reserved value
MUST be rejected as an illegal instruction before architectural state, memory,
queue, descriptor, allocation, or ordering effects occur. Assemblers MUST NOT
emit reserved values, and canonical disassembly MUST NOT give them accepted
spellings.

Each field contract MUST state:

- bit width and instruction-bit pieces;
- signedness or raw-bit interpretation;
- architectural role;
- assigned values or assigned ranges and their meanings;
- reserved values or reserved ranges;
- encoded-zero meaning;
- omission/default behavior when the surrounding schema permits omission;
- static legality and any referenced cross-field legality rule;
- exception and no-effect behavior for rejection.

Reserved zero bits and fixed constants are fields for closure purposes even
when they are absent from the assembly syntax. Their required value and
rejection behavior MUST be explicit.

## `B.DATR.DataType` allocation {#PTO-DEC-0059-DATATYPE}

<!-- ndf: kind=req level=must layer=L1 status=draft refines=PTO-DEC-0059-FIELD-DOMAIN -->

`B.DATR.DataType` MUST remain a five-bit field. It MUST use the following total
32-value allocation. This decision names the previously implicit complement;
it does not change any assigned value.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

Codes 15, 21, 22, 23, 29, 30, and 31 MUST reject. No code represents `NONE`,
`NULL`, “inherit,” or an absent data type. Code zero means FP64. If a block
schema permits `B.DATR` or its DataType contribution to be omitted, the
operation-specific schema default MUST supply a named assigned type; omission
MUST NOT be modeled by a reserved encoding.

The shared architectural data-type definition MUST own this table. `B.DATR`,
typed block starts, Tile descriptor decoding, operation legality, generated
catalogs, and all downstream PTO projections MUST reference the same
definition.
This five-bit namespace is distinct from every scalar numeric namespace and
from the six-bit TLSU transfer-type namespace. A generic ASL carrier MAY be
wider than five bits, but a `B.DATR.DataType` decode MUST consume exactly the
five encoded bits and MUST NOT acquire an additional code through a sixth bit.

## Mnemonic encoding classes {#PTO-DEC-0059-MNEMONIC-CLASS}

<!-- ndf: kind=req level=must layer=L1 status=draft refines=PTO-DEC-0059-AUTHORITY -->

Every `PTO-INSTRUCTION` record MUST declare exactly one of the first four
encoding classes below. A named `PTO-UNIT` that is not accepted assembly syntax
MUST declare the fifth class:

1. **standalone-encoded** — one or more instruction words directly decode to
   the mnemonic;
2. **encoding-alias** — the mnemonic is an accepted alternate spelling of an
   existing encoded form and declares its canonical disassembly spelling;
3. **selector-encoded-block-operation** — the mnemonic is selected by encoded
   block fields and executes only after a valid block schema is assembled and
   committed; it has no standalone instruction word;
4. **pseudo-expansion** — the assembler expands the mnemonic into a declared
   ordered sequence of accepted encoded instructions;
5. **semantic-only** — the name is an ASL architectural helper or state
   operation, is not a mnemonic, and is not accepted assembly syntax.

Deleted spellings and names reserved for possible future use are not accepted
mnemonics. They MUST live in an explicit name-disposition ledger as either
`deleted` or `reserved-name`, with no generated accepted instruction page.
Encoding-space reservation is independent: a deleted spelling MAY have no
reserved bit pattern, while an extension form MAY require PTO to reserve an
encoding range without accepting its name or semantics.

For a selector-encoded block operation, the mnemonic ASL contract MUST state:

- the carrier start form and exact Mode/Function or family/function selector;
- required block commands and their ordering constraints;
- optional commands and their explicit defaults;
- the source of each operand and result binding;
- fields accepted by the operation and the rejection rule for nonzero surplus
  fields;
- the commit point and no-effect behavior on schema or operation rejection;
- that no standalone opcode exists.

## Per-mnemonic explanation contract {#PTO-DEC-0059-MNEMONIC-CONTENT}

<!-- ndf: kind=req level=must layer=L1 status=draft refines=PTO-DEC-0059-MNEMONIC-CLASS -->

Each accepted mnemonic ASL unit and its generated page MUST provide the
following information. A non-applicable subject MUST be written as an explicit
`none`; it MUST NOT be silently omitted.

1. stable mnemonic ID, surface, semantic class, and execution engine where
   applicable;
2. accepted assembly forms and canonical disassembly form;
3. encoding class and encoding ownership;
4. instruction length, match/mask, fixed bits, and all encoded fields for each
   standalone form; exact canonical owner for an alias; exact ordered expansion
   for a pseudo; or exact selector/block composition for a block operation;
5. architectural meaning and complete value disposition for every field;
6. operands, result destinations, types, aliasing permissions, and source
   snapshot/write order;
7. required inputs, optional inputs, omission defaults, and the distinction
   between omitted and explicitly encoded zero;
8. legality rules, including cross-field and descriptor conditions;
9. architectural state effects and preserved state;
10. memory accesses, access order, atomicity, restart, and ordering semantics;
11. synchronous exceptions and the before-effects rejection boundary;
12. deterministic operation pseudocode or embedded ASL operation region;
13. at least one canonical assembly example and, when a reserved or boundary
    value exists, one rejecting example.

The summary MUST describe the instruction's architectural effect. Repeating the
mnemonic name, semantic family, or handler name is not an explanation.

## ASL metadata and executable ownership {#PTO-DEC-0059-ASL-SCHEMA}

<!-- ndf: kind=arch level=must layer=L2 status=draft refines=PTO-DEC-0059-FIELD-DOMAIN,PTO-DEC-0059-MNEMONIC-CONTENT -->

The existing `PTO-INSTRUCTION` and `PTO-UNIT` records MUST be extended rather
than replaced. The extension MUST support references to shared ASL-owned
contracts so a mnemonic file remains concise. At minimum it MUST represent:

- `encoding_class`;
- `canonical_assembly` and accepted aliases;
- structured `field_contracts` or references to shared field contracts;
- operand/result roles and defaults;
- legality, state-effect, memory-effect, ordering, and exception summaries;
- block-composition data for selector-encoded operations;
- references to executable ASL regions and stable requirement IDs.

Shared field contracts MUST have stable IDs. References MUST resolve, and a
field reference MUST match the field width, pieces, and signedness in every form
that uses it. An instruction-local override MAY narrow contextual legality or
change an operand label, but MUST NOT silently change a shared raw-code meaning.

Executable decode and semantic functions MUST remain the behavior authority.
Metadata MUST be checked against decoder constraints, handler reachability, and
runtime canaries. Generated catalogs MUST contain the resolved structured
contract so downstream tools do not parse prose.

## Projection and navigation {#PTO-DEC-0059-PROJECTION}

<!-- ndf: kind=arch level=must layer=L2 status=draft refines=PTO-DEC-0059-ASL-SCHEMA -->

The ASL tree, generated Markdown tree, and independent test tree MUST keep their
mirrored scalar/block/tile/arch classification. Each mnemonic MUST retain one
ASL file and one page. Shared architecture subjects such as data types, field
domains, state, and memory rules MUST each retain their own ASL unit and page.

Generated pages MUST render resolved value tables and shared contracts at the
point of use while linking back to their unique ASL owner. Embedded ASL regions
MUST be byte-derived from the named source region. Supplementary prose MAY add
rationale or examples but MUST NOT redefine an encoding, value, default,
legality rule, or operation.

Agent and skill entry points MUST direct readers to active ASL and generated
pages first. Legacy and historical material MUST be excluded from search and
navigation unless the task explicitly requests history.

## Verification contract {#PTO-DEC-0059-VERIFICATION}

<!-- ndf: kind=verif level=must layer=L3 status=draft verifies=PTO-DEC-0059-FIELD-DOMAIN,PTO-DEC-0059-MNEMONIC-CONTENT,PTO-DEC-0059-PROJECTION -->

Lightweight repository validation MUST fail closed on:

- an encoded field whose assigned/reserved partition is incomplete,
  overlapping, duplicated, or out of range;
- a reserved field value that appears in accepted assembly, a positive decoder
  witness, or canonical disassembly;
- a field without an architectural role, zero meaning, and applicable default;
- a mnemonic without exactly one encoding class;
- a selector-encoded block operation without complete composition/default data;
- a standalone-encoding claim without a catalog form, or a no-standalone claim
  with an independently decoded word;
- an accepted mnemonic with a placeholder summary or missing required subject;
- unresolved shared-contract references;
- stale catalogs, pages, navigation, or embedded ASL;
- active agent navigation that routes to legacy definitions.

The manual release validation MUST additionally execute:

- one negative decode/dispatch canary for every reserved value or a generated
  exhaustive equivalent;
- assigned-value boundary witnesses for every finite selector domain;
- cross-field legality canaries;
- omission versus encoded-zero cases for every optional field;
- exact block composition and commit/fault atomicity cases for every
  selector-encoded operation;
- end-to-end ASL-to-catalog-to-page-to-test traceability for every mnemonic.

The pull-request path MAY run only the lightweight structural and projection
checks. Exhaustive ASLRef execution and coverage remain release gates. A failed,
missing, skipped, or pending release check MUST NOT count as success.

## PTO publication boundary {#PTO-DEC-0059-PUBLICATION}

<!-- ndf: kind=req level=must layer=L1 status=draft depends-on=PTO-DEC-0059-FIELD-DOMAIN,PTO-DEC-0059-MNEMONIC-CONTENT -->

PTO MUST publish one exact release commit, tree, and manifest. Every downstream
consumer of a PTO scalar, block, or Tile mnemonic MUST consume structured PTO
projections and preserve:

- encoding class, length, mask, match, fixed bits, fields, and constraints;
- assigned and reserved field-value dispositions;
- canonical assembly/disassembly and accepted common aliases;
- operand/result roles, defaults, legality, state effects, memory effects,
  ordering, exceptions, and block composition.

Extension instructions MUST remain outside the PTO accepted surface. PTO MUST
reserve every extension encoding space that could otherwise conflict, without
accepting the extension mnemonic or semantics. A reserved PTO field value or
encoding range may be assigned only by a new accepted PTO architecture
decision.

A downstream conformance comparator MUST consume structured PTO projections,
not prose or mnemonic counts. A mismatch MUST reject the downstream artifact.

## Delivery sequence {#PTO-DEC-0059-DELIVERY}

<!-- ndf: kind=arch level=must layer=L2 status=draft depends-on=PTO-DEC-0059-VERIFICATION,PTO-DEC-0059-PUBLICATION -->

Implementation MUST proceed in this order:

1. extend the ASL metadata schema and lightweight closure checker without
   changing instruction behavior;
2. make the shared DataType contract total and update `B.DATR` plus all typed
   consumers;
3. close the remaining block field domains and block composition contracts;
4. audit and complete every scalar mnemonic;
5. audit and complete every selector-encoded Tile mnemonic;
6. regenerate catalogs, pages, navigation, traceability, and release evidence;
7. run the complete PTO release validation on one clean exact commit;
8. publish the exact PTO release manifest and reject downstream artifacts that
   do not carry that identity.

Each step MUST preserve reviewed masks, matches, selectors, and existing
semantics unless a separate accepted architecture decision explicitly changes
them. Mechanical schema/projection work and normative semantic changes MUST NOT
be hidden in one undifferentiated commit.

## Acceptance criteria {#PTO-DEC-0059-ACCEPTANCE}

<!-- ndf: kind=verif level=must layer=L3 status=draft verifies=PTO-DEC-0059-DELIVERY -->

This decision is complete only when all of the following are true:

- `B.DATR.DataType` reports 25 assigned and seven reserved values, with all 32
  values covered exactly once;
- every reserved DataType value rejects before effects;
- every encoded field in the accepted PTO surface has a total disposition;
- every accepted mnemonic has exactly one encoding class and all required
  explanation subjects;
- every selector-encoded Tile operation explicitly states that it has no
  standalone opcode and provides its complete block composition;
- no active catalog or page contains a placeholder architectural role or
  handler-only semantic explanation;
- ASL, catalogs, generated pages, navigation, tests, and traceability compare
  cleanly from one source graph;
- PTO release validation succeeds for one clean exact commit;
- the release manifest binds that exact commit, tree, projections, and
  validation evidence.

## Consequences {#PTO-DEC-0059-CONSEQUENCES}

<!-- ndf: kind=info level=may layer=L0 status=draft -->

The authored ASL grows only by concise per-mnemonic facts and references to
shared contracts. Generated pages become longer where a complete value table or
composition is necessary, but the information remains derived and searchable.
Future instruction additions must allocate from an explicitly reserved domain,
define every field and effect, add executable rejection evidence, and update
PTO encoding ownership before release. Git history remains the only legacy backup;
active normative trees do not retain parallel legacy definitions.

## Open questions {#PTO-DEC-0059-OPEN}

<!-- ndf: kind=info level=may layer=L0 status=draft -->

None. The architectural decisions required for this design were explicitly
confirmed before this record was written. Implementation findings that expose a
new semantic ambiguity must be recorded as a new open item rather than guessed.
