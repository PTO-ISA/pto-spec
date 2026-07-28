// PTO Instruction Set Architecture ASL1 entry point.
//
// The Makefile assembles the normative sources in dependency order. This file
// intentionally contains only the architecture identity and top-level contract.

constant PTO_ARCHITECTURE_VERSION = 0;
constant PTO_XLEN = 64;
// The five-bit scalar namespace contains 24 absolute GPRs and two four-entry
// block-local temporary queues (T and U).
constant PTO_SCALAR_REGISTER_COUNT = 32;
constant PTO_ABSOLUTE_GPR_COUNT = 24;
constant PTO_TEMPORARY_QUEUE_DEPTH = 4;
constant PTO_PREDICATE_REGISTER_COUNT = 8;
constant PTO_ACR_COUNT = 16;
constant PTO_TILE_REGISTER_COUNT = 64;
constant PTO_MODEL_MEMORY_AGENTS = 4;
constant PTO_MODEL_MEMORY_EVENTS = 16;
constant PTO_MODEL_MAX_TILE_CAPACITY_BYTES = 524288;
constant PTO_RESERVATION_GRANULE_BYTES = 64;
constant PTO_BLOCK_DIMENSION_COUNT = 3;
constant PTO_BLOCK_SCALAR_BINDING_COUNT = 32;
constant PTO_BLOCK_TILE_BINDING_COUNT = 16;
constant PTO_TILE_BASE_COUNT = 6;

// ASL arrays require static bounds. This is an executable-model bound, not an
// architectural maximum tile size. Legality uses descriptor byte capacity.
config PTO_MODEL_TILE_ELEMENTS : integer {1..4096} = 256;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
