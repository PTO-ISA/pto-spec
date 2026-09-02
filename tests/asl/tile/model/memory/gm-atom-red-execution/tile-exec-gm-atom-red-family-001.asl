// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ATOM-RED-FAMILY-001","source":"asl/tile/model/memory/gm-atom-red-execution.asl","requirements":["PTO-ATOM-RED-ENCODING-001","PTO-ATOM-RED-BODY-SCHEMA-001","PTO-ATOM-RED-TYPE-LEGALITY-001","PTO-ATOM-RED-INC-DEC-SEMANTICS-001","PTO-ATOM-RED-POPC-SEMANTICS-001","PTO-ATOM-RED-ORDERING-001","PTO-ATOM-RED-FAULTS-001","PTO-INST-BLOCK-BSTART-MGATHER-ADD","PTO-INST-BLOCK-BSTART-MGATHER-AND","PTO-INST-BLOCK-BSTART-MGATHER-CAS","PTO-INST-BLOCK-BSTART-MGATHER-DEC","PTO-INST-BLOCK-BSTART-MGATHER-EXCH","PTO-INST-BLOCK-BSTART-MGATHER-INC","PTO-INST-BLOCK-BSTART-MGATHER-MAX","PTO-INST-BLOCK-BSTART-MGATHER-MIN","PTO-INST-BLOCK-BSTART-MGATHER-OR","PTO-INST-BLOCK-BSTART-MGATHER-XOR","PTO-INST-BLOCK-BSTART-MSCATTER-ADD","PTO-INST-BLOCK-BSTART-MSCATTER-AND","PTO-INST-BLOCK-BSTART-MSCATTER-DEC","PTO-INST-BLOCK-BSTART-MSCATTER-INC","PTO-INST-BLOCK-BSTART-MSCATTER-MAX","PTO-INST-BLOCK-BSTART-MSCATTER-MIN","PTO-INST-BLOCK-BSTART-MSCATTER-OR","PTO-INST-BLOCK-BSTART-MSCATTER-POPC","PTO-INST-BLOCK-BSTART-MSCATTER-XOR","PTO-INST-TILE-MGATHER-ADD","PTO-INST-TILE-MGATHER-AND","PTO-INST-TILE-MGATHER-CAS","PTO-INST-TILE-MGATHER-DEC","PTO-INST-TILE-MGATHER-EXCH","PTO-INST-TILE-MGATHER-INC","PTO-INST-TILE-MGATHER-MAX","PTO-INST-TILE-MGATHER-MIN","PTO-INST-TILE-MGATHER-OR","PTO-INST-TILE-MGATHER-XOR","PTO-INST-TILE-MSCATTER-ADD","PTO-INST-TILE-MSCATTER-AND","PTO-INST-TILE-MSCATTER-DEC","PTO-INST-TILE-MSCATTER-INC","PTO-INST-TILE-MSCATTER-MAX","PTO-INST-TILE-MSCATTER-MIN","PTO-INST-TILE-MSCATTER-OR","PTO-INST-TILE-MSCATTER-POPC","PTO-INST-TILE-MSCATTER-XOR"],"kind":"execution","summary":"GM atom/red legality, mapping, INC/DEC limits, atom old-value publication, and mscatter.popc one-per-request effects are executable.","pass_condition":"All Functions 8--27 map to the frozen operations, reserved functions are outside the selected family, the narrowed CAS matrix rejects non-U types, and direct atom/red effects match the frozen observable results.","related_sources":["asl/block/model/dispatch/tlsu-gm-atom-red.asl","asl/tile/model/memory/gm-atom-red.asl"]}
func main() => integer
begin
    assert BundleGMAtomRedDataTypeLegal(8, TileDataType_U16);
    assert BundleGMAtomRedDataTypeLegal(8, TileDataType_U32);
    assert BundleGMAtomRedDataTypeLegal(8, TileDataType_U64);
    assert !BundleGMAtomRedDataTypeLegal(8, TileDataType_S32);
    assert !BundleGMAtomRedDataTypeLegal(8, TileDataType_U8);
    assert BundleGMAtomRedDataTypeLegal(12, TileDataType_FP32);
    assert BundleGMAtomRedDataTypeLegal(14, TileDataType_U32);
    assert !BundleGMAtomRedDataTypeLegal(14, TileDataType_U64);
    assert BundleGMAtomRedDataTypeLegal(27, TileDataType_U32);
    assert !BundleGMAtomRedDataTypeLegal(27, TileDataType_U64);
    assert GMAtomicOperationFromFunction(8) == GMAtomic_CAS;
    assert GMAtomicOperationFromFunction(18) == GMAtomic_XOR;
    assert GMReductionOperationFromFunction(19) == GMReduction_MAX;
    assert GMReductionOperationFromFunction(27) == GMReduction_POPC;
    assert GMIncValue(Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 5) == Zeros{PTO_XLEN} + 5;
    assert GMIncValue(Zeros{PTO_XLEN} + 5, Zeros{PTO_XLEN} + 5) == Zeros{PTO_XLEN};
    assert GMDecValue(Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 5) == Zeros{PTO_XLEN} + 2;
    assert GMDecValue(Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 5) == Zeros{PTO_XLEN} + 5;
    assert GMDecValue(Zeros{PTO_XLEN} + 6, Zeros{PTO_XLEN} + 5) == Zeros{PTO_XLEN} + 5;

    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 7);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    Store(Zeros{PTO_XLEN} + 0x400, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x404, 4, Zeros{PTO_XLEN} + 20);
    StartMemoryEventCapture(0);
    GM_ATOM_VALUE(GMAtomic_ADD, 0, Zeros{PTO_XLEN} + 0x400, 1, 2, TilePad_Null);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 20;
    assert _MemoryEventCount == 2;
    let atom_add_value0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x400, 4);
    let atom_add_value1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x404, 4);
    assert atom_add_value0 == Zeros{PTO_XLEN} + 13;
    assert atom_add_value1 == Zeros{PTO_XLEN} + 27;
    StopMemoryEventCapture();

    ResetProfileState();
    ConfigureTile(3, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(3);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x504, 4, Zeros{PTO_XLEN} + 20);
    GM_RED_POPC(GMReduction_POPC, Zeros{PTO_XLEN} + 0x500, 3);
    let red_popc_value0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let red_popc_value1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x504, 4);
    assert red_popc_value0 == Zeros{PTO_XLEN} + 11;
    assert red_popc_value1 == Zeros{PTO_XLEN} + 21;
    return 0;
end;
