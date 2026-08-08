# Formal specification quality

## Normative change evidence

Every normative change must identify:

- stable PTO requirement IDs and source links;
- architecture-visible inputs, outputs, and state;
- legal operand and state domains;
- fault, diagnostic, or unspecified cases;
- target-profile applicability;
- executable evidence and known coverage gaps.

If the public contract is ambiguous, do not select a convenient behavior. Record an architecture decision request.

## Semantic review

Check:

- **Type soundness**: widths, integer constraints, array indices, enumerations, records, and conversions are explicit.
- **Totality**: every legal input has a result or state transition.
- **Determinism**: nondeterminism is intentional and modeled, not an uninitialized value or arbitrary evaluation order.
- **State locality**: all reads and writes are architecture-visible and reviewable.
- **Aliasing**: source/destination overlap and read-before-write behavior are defined.
- **Boundaries**: zero sizes, maximum sizes, partial valid regions, wraparound, saturation, and exceptional values are
  covered where applicable.
- **Ordering**: memory, event, and asynchronous effects state their ordering guarantees.
- **Portability**: backend constraints are not silently promoted to virtual-ISA rules.
- **Decode closure**: every accepted encoding has a canonical positive witness, overlaps have reviewed priority, and
  every catalog-reserved or review-only selector rejects.
- **Catalog closure**: every accepted direct operation maps to exactly one semantic handler and validation feature.
- **Semantic reachability**: decoded forms bind operands and reach a defined state transition; function-name presence or
  enum linkage alone is insufficient.
- **Evidence hygiene**: external comparison evidence records provenance and disposition without importing incompatible
  material into the normative model.
- **Reproducible external gates**: comparison evidence runs every claimed gate on a clean content-addressed snapshot and
  archives a publication-safe command identity, exit code, result, output hashes, and a sanitized diagnostic excerpt.
  Restricted source/version recipes stay behind constructed local generator inputs. Missing commands, timeouts, and
  nonzero exits fail closed; generated evidence must never substitute hardcoded outcomes for executed checks.

## Test shape

Require the relevant subset of:

- one representative legal case;
- minimum and maximum domain boundaries;
- invalid or illegal operands;
- destination/source aliasing;
- fixed-width overflow or saturation;
- invalid-region preservation;
- architecture-visible state before and after execution;
- profile-differential behavior;
- differential evidence against another accepted model, when available.

Successful ASLRef execution proves consistency with the written model, not correctness of the model against the PTO
architecture. Traceability and review supply that second proof obligation.

For PTO instruction-set changes, `make pr-check` is the minimum review gate. It proves ASL layout, NDF structure,
generated catalog and documentation freshness, independent test-point topology, and publication hygiene. Release
readiness additionally requires `make repo-check` plus the manual exact-head `make release-verify` lane; an ASLRef result
from a different commit, a stale artifact, or a partial test set is not evidence.

## Change isolation

Keep these changes separate whenever practical:

- ASLRef/toolchain pin updates;
- repository governance or CI changes;
- normative semantics;
- mechanical refactors;
- generated artifacts.

This separation makes semantic review and regression attribution tractable.
