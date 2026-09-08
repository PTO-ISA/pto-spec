// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-TILE-ALLOCATION","surface":"arch","classification":["features","tile-allocation"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}
// Every PE owns an independent 2048-cell Local pool; one Local object
// is capped at 64 KiB. Multiple Local objects may consume the aggregate pool.
// The Core also owns one
// independent 2048-cell Shared pool.  Local and Shared allocations do not
// compete for one combined capacity budget.
constant PTO_TILE_CELL_BYTES = 128;
constant PTO_TILE_CELL_COUNT = 2048;
constant PTO_TILE_CAPACITY_BYTES = 262144;
constant PTO_TILE_MAX_ALLOCATION_BYTES = 65536;
constant PTO_SHARED_TILE_MAX_ALLOCATION_BYTES = 262144;
constant PTO_MODEL_MAX_TILE_CAPACITY_BYTES = PTO_TILE_CAPACITY_BYTES;
constant PTO_RESERVATION_GRANULE_BYTES = 64;
constant PTO_BUNDLE_DIMENSION_COUNT = 3;
constant PTO_BUNDLE_SCALAR_BINDING_COUNT = 32;
constant PTO_BUNDLE_TILE_BINDING_COUNT = 16;
constant PTO_TILE_BASE_COUNT = 6;

// ASL arrays require static bounds. The executable model uses S63 witnesses
// for the 256 KiB Shared boundary, requiring 32,768 element slots. This is a
// model bound, not a claim that every payload uses that many architectural
// elements.
config PTO_MODEL_TILE_ELEMENTS : integer {1..32768} = 32768;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
// Target-runtime compatibility is opt-in in generated model profiles. The
// portable PTO contract keeps system operations restricted to SYS blocks.
config PTO_MODEL_ALLOW_SYSTEM_OPS_IN_NON_SYS_BLOCK : boolean = FALSE;
config PTO_MODEL_LINX_RUNTIME_COMPAT : boolean = FALSE;
// The reference profile uses its bounded in-ASL byte array.  A named runtime
// profile may opt into the worker-backed sparse address space; the portable
// default remains entirely local and deterministic.
config PTO_MODEL_HOST_MEMORY : boolean = FALSE;
// The frame instructions use an explicit ABI-selected stack-pointer GPR.
// Portable PTO retains the architectural R1 stack pointer; a named runtime
// profile may select a different ABI register without changing instruction
// handlers.
config PTO_MODEL_FRAME_SP_INDEX : integer {0..31} = 1;
// A legacy compressed stop shares the low halfword with C.BSTART.STD FALL.
// The compatibility decoder may disambiguate it only at a selecting bundle
// boundary; ordinary fallthrough C.BSTART remains distinct.
config PTO_MODEL_LINX_LEGACY_C_BSTOP : boolean = FALSE;
// A hosted Linx trace-end marker may terminate the active direct block and
// select its BARG continuation. Portable PTO retains the ordinary TRACE
// boundary lifecycle.
config PTO_MODEL_LINX_TRACE_BOUNDARY_COMPAT : boolean = FALSE;
// Maximum MSET transfer size. The portable reference profile is additionally
// bounded by its fixed in-ASL byte array; a hosted runtime profile applies
// this explicit ceiling while retaining full-range preflight and byte-atomic
// ordering.
config PTO_MODEL_MSET_MAX_BYTES : integer {63..262144} = 262144;
