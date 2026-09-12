// PTO-TEST: {"id":"PTO-AVS-SCALAR-BODY-ENTRY-TILE-BLOCK-002","source":"asl/scalar/model/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001"],"kind":"execution","summary":"A decoded scalar instruction enters the body of an active Tile block without an intervening Standard BSTART.","pass_condition":"C.MOVR executes, makes the body active, and preserves the TileElement block kind.","related_sources":["asl/block/model/lifecycle/begin.asl","asl/block/model/lifecycle/enter-stop.asl"]}
func main() => integer
begin
    ResetProfileState();
    let header = Zeros{PTO_XLEN} + 0x100;
    let scalar = header + 4;
    WriteTPC(header);
    BeginBundleAt(
        header,
        BundleKind_TileElement,
        BundleTransfer_Fallthrough,
        scalar + 2,
        scalar,
        Zeros{PTO_XLEN},
        TRUE);

    assert BundleIsActive();
    assert !BundleBodyIsActive();
    assert _BARG.block_type == BundleKind_TileElement;

    // C.MOVR zero, ->a1. No C.BSTART.STD separates this scalar body
    // instruction from the active Tile block header.
    WriteMemoryByte(scalar, Zeros{8} + 0x06);
    WriteMemoryByte(scalar + 1, Zeros{8} + 0x18);

    let scalar_status = ExecuteNextPTOInstruction();
    assert scalar_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert BundleIsActive();
    assert BundleBodyIsActive();
    assert _BARG.block_type == BundleKind_TileElement;
    assert ReadGPR(3) == Zeros{PTO_XLEN};
    return 0;
end;
