// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-OPEN-GENERATION-007","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-ARCH-SHARED-VTAG-LIFETIME-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"An open Shared B.ASSEMBLE holds parent capacity across last-use of its old published Sx.","pass_condition":"The old payload can be consumed without freeing its open generation reservation to another Sx, LAST replaces the charge once, and abort releases the reservation.","related_sources":["asl/block/model/operands/shared-generation.asl","asl/tile/model/capacity/shared.asl","asl/tile/model/state/shared-registers.asl"]}
pure func SharedOpenGenerationStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedOpenGenerationBinding(size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedOpenGenerationAssemble(init: boolean, last: boolean,
                                       offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;

func SharedOpenGenerationWriter(init: boolean, last: boolean,
                                offset: integer, value: integer) => boolean
begin
    _Memory[[0]] = Zeros{8} + value;
    let started = ExecuteCommandInstruction(SharedOpenGenerationStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    let binder = ExecuteCommandInstruction(
        SharedOpenGenerationBinding(if init then 2 else 0), 32);
    let modifier = ExecuteCommandInstruction(
        SharedOpenGenerationAssemble(init, last, offset), 32);
    assert started == CommandExecution_Executed &&
           binder == CommandExecution_Executed &&
           modifier == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func SharedOpenGenerationConsumeOld(shared_id: SharedTileID)
begin
    ClearBundleHeaderState();
    BindBundleSharedIOWithReuse(shared_id, 0, '1111', FALSE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 8) as SharedTileID;
    let other_id = (Zeros{6} + 9) as SharedTileID;
    let first = SharedOpenGenerationWriter(TRUE, FALSE, 0, 0x11);
    assert first;
    ClearBundleHeaderState();
    let published = SharedOpenGenerationWriter(FALSE, TRUE, 1, 0x22);
    assert published;
    assert SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 256;

    ClearBundleHeaderState();
    let reopened = SharedOpenGenerationWriter(TRUE, FALSE, 0, 0x33);
    assert reopened;
    assert BundleSharedGenerationOpen(shared_id);
    assert SharedTileRecord(shared_id).reserved_capacity_bytes == 256;
    SharedOpenGenerationConsumeOld(shared_id);
    assert !SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 256;

    var huge = SharedTileRecord(shared_id).tile;
    huge.capacity_bytes = 262144;
    huge.rows = 2048;
    let competing = AtomicUpdateSharedTile(other_id, huge, '1111');
    assert !competing;
    assert !SharedTileRecord(other_id).descriptor_valid;

    ClearBundleHeaderState();
    let completed = SharedOpenGenerationWriter(FALSE, TRUE, 1, 0x44);
    assert completed;
    assert SharedTileRecord(shared_id).payload_live;
    assert SharedTileRecord(shared_id).reserved_capacity_bytes == 0;
    assert SharedTileCapacityInUse() == 256;

    ClearBundleHeaderState();
    let pending = SharedOpenGenerationWriter(TRUE, FALSE, 0, 0x55);
    assert pending;
    SharedOpenGenerationConsumeOld(shared_id);
    assert SharedTileCapacityInUse() == 256;
    AbortBundleSharedGeneration(shared_id);
    assert SharedTileRecord(shared_id).descriptor_valid;
    assert !SharedTileRecord(shared_id).payload_live;
    assert SharedTileRecord(shared_id).reserved_capacity_bytes == 0;
    assert SharedTileCapacityInUse() == 0;
    return 0;
end;
