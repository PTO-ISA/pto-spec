// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-CUBE-FAULT-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-TCI-CONTRACT-001"],"kind":"fault","summary":"TCI CUBE rejects malformed packed steps and preserves strict zero-mask no-op behavior","pass_condition":"an out-of-range signed step, including -2 and another non-unit value, raises Fault_TileLegality before allocation; a zero mask ignores invalid dimensions and malformed GPR bindings; only participating PE Step2D values are preflighted, so selected-valid/unselected-invalid succeeds while selected-invalid faults","related_sources":["asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/dispatch/generation-schema.asl"]}
pure func TCICubeFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func RunTCICubeNonUnitFault(step2d: Word)
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCICubeFaultStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 1);
        WritePEGPR(pe as MemoryAgentId, 5, step2d);
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCICubeFaultStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 1);
        WritePEGPR(pe as MemoryAgentId, 5, Zeros{64} + 0x0000000200000000);
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let malformed_step = ExecuteBundleTileOperation();
    assert !malformed_step;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;

    ResetProfileState();
    let zero_started = ExecuteCommandInstruction(TCICubeFaultStart(), 32);
    assert zero_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN});
    SetBundleDimension(1, Zeros{PTO_XLEN});
    SetBundleScalarBinding(0, 0, 31, 31, 31, 0);
    AddBundleTileBinding(
        TRUE, 0, 1, '0000', FALSE, FALSE, 0, 0, TRUE);
    let zero_mask = ExecuteBundleTileOperation();
    assert zero_mask;
    assert _LastFault == Fault_None;
    assert !_Tiles[[0]].allocated;

    ResetProfileState();
    let participating_started = ExecuteCommandInstruction(
        TCICubeFaultStart(), 32);
    assert participating_started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1000', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 1);
        WritePEGPR(pe as MemoryAgentId, 5, Zeros{PTO_XLEN});
    end;
    for pe = 1 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 3 do
        WritePEGPR(pe as MemoryAgentId, 5,
            Zeros{64} + 0x0000000200000000);
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let participating_completed = ExecuteBundleTileOperation();
    assert participating_completed && _LastFault == Fault_None;
    assert ReadTileElement(
        _BundleTileBindings[[0]].destination, 1, 1) ==
        Zeros{PTO_XLEN} + 1;

    ResetProfileState();
    let selected_fault_started = ExecuteCommandInstruction(
        TCICubeFaultStart(), 32);
    assert selected_fault_started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1000', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 1);
        WritePEGPR(pe as MemoryAgentId, 5, Zeros{PTO_XLEN});
    end;
    WritePEGPR(0, 5, Zeros{64} + 0x0000000200000000);
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let selected_fault = ExecuteBundleTileOperation();
    assert !selected_fault;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;

    RunTCICubeNonUnitFault(Zeros{64} + 0xfffffffe00000000);
    RunTCICubeNonUnitFault(Zeros{64} + 3);
    return 0;
end;
