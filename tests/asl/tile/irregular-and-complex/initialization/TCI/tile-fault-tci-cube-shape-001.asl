// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-CUBE-SHAPE-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-TCI-CONTRACT-001"],"kind":"fault","summary":"TCI CUBE rejects invalid physical geometry, row shape, tuple, binding, and capacity before publication","pass_condition":"each malformed CUBE case reports its specified BundleControl, TileLegality, or TileAllocation fault and leaves destination zero unallocated","related_sources":["asl/block/model/dispatch/generation-schema.asl","asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func TCICubeShapeFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func RunTCICubeFault(
    valid_columns: Word, valid_rows: Word, columns: Word,
    destination_size: integer {0..12}, datr_type: bits(5),
    bind_scalar: boolean, source_count: integer {0..3},
    duplicate_scalar: boolean, expected_fault: FaultCode)
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCICubeShapeFaultStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        datr_type, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, valid_columns);
    SetBundleDimension(1, valid_rows);
    SetBundleDimension(2, columns);
    AddBundleTileBinding(
        TRUE, 0, destination_size, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 1);
        WritePEGPR(pe as MemoryAgentId, 5, Zeros{PTO_XLEN});
    end;
    if bind_scalar then
        SetBundleScalarBinding(0, 0, 4, 5, 0, source_count);
    end;
    if duplicate_scalar then
        SetBundleScalarBinding(1, 0, 4, 5, 0, 3);
    end;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert !_Tiles[[0]].allocated;
end;

func main() => integer
begin
    RunTCICubeFault(
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4, 1, DTYPE_NONE, TRUE, 3, FALSE,
        Fault_TileLegality);
    assert _LastFault == Fault_TileLegality;
    // Logical columns may not exceed the exact physical Col.
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 1, 1, DTYPE_NONE, TRUE, 3, FALSE,
        Fault_TileLegality);
    assert _LastFault == Fault_TileLegality;
    // CUBE_M16 U16 has a four-column CELL quantum.
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3, 1, DTYPE_NONE, TRUE, 3, FALSE,
        Fault_TileLegality);
    assert _LastFault == Fault_TileLegality;
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 17,
        Zeros{PTO_XLEN} + 4, 1, DTYPE_NONE, TRUE, 3, FALSE,
        Fault_TileLegality);
    assert _LastFault == Fault_TileLegality;
    // Eight physical columns require two CELLs and therefore two SizeCode
    // units; one unit must fail as TileAllocation without publication.
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 5, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 8, 1, DTYPE_NONE, TRUE, 3, FALSE,
        Fault_TileAllocation);
    assert _LastFault == Fault_TileAllocation;
    // The CUBE tuple requires DTYPE_NONE even though the carrier is U16.
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4, 1, Zeros{5} + 26, TRUE, 3, FALSE,
        Fault_TileLegality);
    assert _LastFault == Fault_TileLegality;
    // A missing or wrong-arity B.IOR is command structure, not TileLegality.
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4, 1, DTYPE_NONE, FALSE, 0, FALSE,
        Fault_BundleControl);
    assert _LastFault == Fault_BundleControl;
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4, 1, DTYPE_NONE, TRUE, 2, FALSE,
        Fault_BundleControl);
    assert _LastFault == Fault_BundleControl;
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4, 1, DTYPE_NONE, TRUE, 3, TRUE,
        Fault_BundleControl);
    assert _LastFault == Fault_BundleControl;
    // This aligned geometry exceeds the model representability bound and must
    // be rejected as TileLegality before allocation.
    RunTCICubeFault(
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 65532, 10, DTYPE_NONE, TRUE, 3, FALSE,
        Fault_TileLegality);
    assert _LastFault == Fault_TileLegality;
    return 0;
end;
