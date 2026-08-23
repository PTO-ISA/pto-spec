// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","surface":"arch","classification":["programming-model","core-pe-topology"],"depends_on":["PTO-ARCH-OVERVIEW-ARCHITECTURE"]}
// The five-bit scalar namespace contains 24 absolute GPRs and two four-entry
// bundle-local temporary queues (T and U).
constant PTO_SCALAR_REGISTER_COUNT = 32;
constant PTO_ABSOLUTE_GPR_COUNT = 24;
constant PTO_TEMPORARY_QUEUE_DEPTH = 4;
constant PTO_PREDICATE_REGISTER_COUNT = 8;
constant PTO_PREDICATE_WIDTH = 32;
constant PTO_ACR_COUNT = 16;
constant PTO_TILE_REGISTER_COUNT = 64;
constant PTO_SHARED_TILE_COUNT = 64;
constant PTO_MODEL_MEMORY_AGENTS = 4;
constant PTO_MODEL_MEMORY_EVENTS = 16;

// Fixed semantic PE identities are numbered PE0..PE3.  The architectural
// four-bit mask keeps PE0 in its high bit, so consumers that index a mask by
// semantic PE identity must use this explicit representation bridge.
pure func PTOPEMaskBitOfPEIdentity(
    pe_identity: integer {0..3}) => integer {0,1,2,3}
begin
    return (3 - pe_identity) as integer {0,1,2,3};
end;
