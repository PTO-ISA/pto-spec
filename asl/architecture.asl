// PTO Instruction Set Architecture ASL1 entry point.
//
// The Makefile assembles the normative sources in dependency order. This file
// intentionally contains only the architecture identity and top-level contract.

constant PTO_ARCHITECTURE_VERSION = 0;
constant PTO_XLEN = 64;
constant PTO_SCALAR_REGISTER_COUNT = 24;
constant PTO_TILE_REGISTER_COUNT = 64;
constant PTO_PIPE_COUNT = 4;
constant PTO_MODEL_PIPE_DEPTH = 4;
constant PTO_MODEL_MEMORY_AGENTS = 4;
constant PTO_MODEL_MEMORY_EVENTS = 16;

// ASL arrays require static bounds. This is an executable-model bound, not an
// architectural maximum tile size. Legality uses descriptor byte capacity.
config PTO_MODEL_TILE_ELEMENTS : integer {1..4096} = 256;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
