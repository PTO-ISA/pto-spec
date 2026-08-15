<!-- GENERATED FROM: asl/arch/overview/architecture.asl -->
# Architecture

**Normative ASL source:** `asl/arch/overview/architecture.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-OVERVIEW-ARCHITECTURE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/overview/architecture.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-OVERVIEW-ARCHITECTURE","surface":"arch","classification":["overview","architecture"],"depends_on":[]}
// PTO Instruction Set Architecture ASL1 entry point.
//
// The Makefile assembles the normative sources in dependency order. This file
// intentionally contains only the architecture identity and top-level contract.

// NDF-BEGIN: PTO-SOURCE-HIERARCHY
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Current architecture contracts MUST be owned by mnemonic or architecture ASL;
// catalogs and Markdown MUST remain deterministic projections or evidence.
// NDF-END: PTO-SOURCE-HIERARCHY

// NDF-BEGIN: PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Accepted instruction completion and its architecture-visible memory events
// MUST be defined by the reachable ASL dispatch, completion, and memory-event owners.
// NDF-END: PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001

// NDF-BEGIN: PTO-ARCH-STATE-CLOSURE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Architecture-visible state MUST be exactly [[PTO-STATE-ARCH-GPR]],
// [[PTO-STATE-ARCH-TEMPORARY-QUEUES]], [[PTO-STATE-ARCH-PROGRAM-CONTROL]],
// [[PTO-STATE-ARCH-FAULT]], [[PTO-STATE-ARCH-MEMORY]],
// [[PTO-STATE-ARCH-MAINTENANCE]], [[PTO-STATE-ARCH-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-TRAP-CONTEXT]], [[PTO-STATE-TILE-LOCAL]],
// [[PTO-STATE-TILE-SHARED]], [[PTO-STATE-ARCH-GQM]], and
// [[PTO-STATE-BLOCK-CONTROL]], and MUST change only through the accepted ASL
// transitions owned by those state units.
// NDF-END: PTO-ARCH-STATE-CLOSURE-001

// NDF-BEGIN: PTO-TILE-CAPACITY-PER-PE
// ndf: kind=contract level=L1 layer=tile status=accepted
// A decoded Tile size MUST denote one selected PE's capacity; PE_MASK selects
// how many equal per-PE allocations the processor provides.
// NDF-END: PTO-TILE-CAPACITY-PER-PE

// NDF-BEGIN: PTO-RELEASE-VERIFICATION
// ndf: kind=mechanism level=L2 layer=architecture status=accepted
// A release candidate MUST be the exact commit that passes the pinned ASL model,
// every runtime shard, coverage, projections, and release-evidence checks.
// NDF-END: PTO-RELEASE-VERIFICATION

constant PTO_ARCHITECTURE_VERSION = 0;
constant PTO_XLEN = 64;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
