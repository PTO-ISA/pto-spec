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
// The five-bit scalar namespace contains 24 absolute GPRs and two four-entry
// bundle-local temporary queues (T and U).
constant PTO_SCALAR_REGISTER_COUNT = 32;
constant PTO_ABSOLUTE_GPR_COUNT = 24;
constant PTO_TEMPORARY_QUEUE_DEPTH = 4;
constant PTO_PREDICATE_REGISTER_COUNT = 8;
constant PTO_PREDICATE_WIDTH = 32;
constant PTO_ACR_COUNT = 16;
constant PTO_TILE_REGISTER_COUNT = 64;
constant PTO_SHARED_TILE_COUNT = 256;
constant PTO_MODEL_MEMORY_AGENTS = 4;
constant PTO_MODEL_MEMORY_EVENTS = 16;
// The active architecture exposes 2048 architectural 128-byte cells per PE.
// The executable model uses the architectural capacity as its upper bound.
constant PTO_TILE_CELL_BYTES = 128;
constant PTO_TILE_CELL_COUNT = 2048;
constant PTO_TILE_CAPACITY_BYTES = 262144;
constant PTO_TILE_MAX_ALLOCATION_BYTES = 8192;
constant PTO_MODEL_MAX_TILE_CAPACITY_BYTES = PTO_TILE_CAPACITY_BYTES;
constant PTO_RESERVATION_GRANULE_BYTES = 64;
constant PTO_BUNDLE_DIMENSION_COUNT = 3;
constant PTO_BUNDLE_SCALAR_BINDING_COUNT = 32;
constant PTO_BUNDLE_TILE_BINDING_COUNT = 16;
constant PTO_TILE_BASE_COUNT = 6;

// ASL arrays require static bounds. 8 KiB of packed four-bit elements is the
// largest legal per-PE Tile payload and therefore requires 16,384 slots.
config PTO_MODEL_TILE_ELEMENTS : integer {1..16384} = 16384;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
