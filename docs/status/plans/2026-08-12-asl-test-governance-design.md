# ASL Test Governance Design (Scheme A)

## Decision

PTO-SPEC adopts an immediate, fail-closed ASL test layout and naming contract. There is no compatibility period for historical test filenames.

## Canonical test location

Every executable ASL test lives below `tests/asl/`. Its directory mirrors its owning ASL unit exactly:

```text
asl/<group>/<classification>/<unit>.asl
tests/asl/<group>/<classification>/<unit>/<test-file>.asl
```

The four legal groups are `arch`, `block`, `scalar`, and `tile`. A test directory may not introduce an extra classification level that is absent from the owning ASL path.

## Canonical filename

Every test filename has this shape:

```text
<group>-<type>-<name>-<NNN>.asl
```

- `group` is the first component of the owning ASL path.
- `type` is derived from `PTO-TEST.kind` by a fixed mapping.
- `name` is a short lowercase purpose slug.
- `NNN` is a three-digit local sequence.
- The complete filename is at most 68 characters, including `.asl`.
- Purpose tokens `test`, `execution`, `validate`, and `validation` are forbidden because group and type already carry that information.
- `PTO-TEST.id` remains the stable global identity and does not have to equal the filename.

The fixed kind-to-type mapping is:

| `PTO-TEST.kind` | filename type |
|---|---|
| `decode-positive` | `decode` |
| `decode-negative` | `decode` |
| `execution` | `exec` |
| `boundary` | `bound` |
| `fault` | `fault` |
| `atomicity` | `atomic` |
| `ordering` | `order` |
| `state-transition` | `state` |
| `static-invariant` | `static` |

## Purpose metadata

Every test keeps exactly one `PTO-TEST` record. Its `summary` states the behavior under test and its `pass_condition` states the observable success condition. Generic summaries such as “run test” or “validate execution” are rejected during review even when the filename is syntactically valid.

## ASL implementation readability

Normative ASL units under `asl/` may not place a complete `begin ... end;` implementation body on one physical line. Metadata records may remain single-line JSON comments. This rule applies to instruction and architecture units equally.

## Generation and migration

Generated AVS points emit the canonical filename directly. Existing files are renamed in one migration; no alias, symlink, duplicate, or historical filename acceptance remains. Repository checks fail on any later regression.
