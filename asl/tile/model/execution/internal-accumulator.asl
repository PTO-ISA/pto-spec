// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR","surface":"tile","classification":["model","execution","internal-accumulator"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}

// NDF-BEGIN: PTO-CUBE-INTERNAL-ACCUMULATOR-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// InternalAcc MUST be a transparent implementation cache. Explicit TileReg C
// MUST remain the architectural accumulator input and explicit TileReg D MUST
// be allocated and published on every successful operation. CCTRL MAY provide
// non-binding input-prefetch and output-replacement hints, but cache hit, miss,
// capacity, residency, replacement, and timing MUST NOT change architectural
// results, faults, allocation, publication, source lifetime, or ordering.
// NDF-END: PTO-CUBE-INTERNAL-ACCUMULATOR-001

// These hooks are non-binding implementation hints. The portable model does
// not read or write cached payload and does not observe whether a hint is used.
impdef func TileProfileInternalAccumulatorPrefetchHint(
    source: TileIndex, required_bytes: integer {0..262144})
begin
    pass;
end;

impdef func TileProfileInternalAccumulatorReplacementHint(
    destination: TileIndex, required_bytes: integer {0..262144})
begin
    pass;
end;
