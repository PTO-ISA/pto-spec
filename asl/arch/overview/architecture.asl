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
