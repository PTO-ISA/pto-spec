// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-DEFINEDNESS-009","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"fault","summary":"Local CUBE Matrix requires every valid source element but excludes physical CELL padding","pass_condition":"one undefined valid element rejects before allocation while defined poisoned padding does not participate in the product","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/shape/cube-cell.asl"]}
func StartDefinednessTMATMUL()
begin
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
end;

func ConfigureDefinednessPrimaries()
begin
    let cube_configuration_1 = ConfigureCubeTileForMask(1, 128, 2, 2,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert cube_configuration_1;
    let cube_configuration_2 = ConfigureCubeTileForMask(2, 128, 2, 2,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert cube_configuration_2;
end;

pure func DefinednessFP16Value(value: integer {1..8}) => Word
begin
    case value of
        when 1 => return Zeros{PTO_XLEN} + 0x3c00;
        when 2 => return Zeros{PTO_XLEN} + 0x4000;
        when 3 => return Zeros{PTO_XLEN} + 0x4200;
        when 4 => return Zeros{PTO_XLEN} + 0x4400;
        when 5 => return Zeros{PTO_XLEN} + 0x4500;
        when 6 => return Zeros{PTO_XLEN} + 0x4600;
        when 7 => return Zeros{PTO_XLEN} + 0x4700;
        when 8 => return Zeros{PTO_XLEN} + 0x4800;
    end;
end;

func WriteDefinednessPayload()
begin
    WriteTileElement(1, 0, 0, DefinednessFP16Value(1));
    WriteTileElement(1, 0, 1, DefinednessFP16Value(2));
    WriteTileElement(1, 1, 0, DefinednessFP16Value(3));
    WriteTileElement(1, 1, 1, DefinednessFP16Value(4));
    WriteTileElement(2, 0, 0, DefinednessFP16Value(5));
    WriteTileElement(2, 0, 1, DefinednessFP16Value(6));
    WriteTileElement(2, 1, 0, DefinednessFP16Value(7));
    WriteTileElement(2, 1, 1, DefinednessFP16Value(8));
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureDefinednessPrimaries();
    WriteTileElement(1, 0, 0, DefinednessFP16Value(1));
    WriteTileElement(1, 0, 1, DefinednessFP16Value(2));
    WriteTileElement(1, 1, 0, DefinednessFP16Value(3));
    MarkTileValidRegionDefined(2);
    StartDefinednessTMATMUL();
    let undefined_valid = ExecuteBundleTileOperation();
    assert !undefined_valid;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ResetProfileState();
    ConfigureDefinednessPrimaries();
    WriteDefinednessPayload();
    let a_padding = TileStorageIndex(_Tiles[[1]], 15, 3);
    let b_padding = TileStorageIndex(_Tiles[[2]], 7, 7);
    _Tiles[[1]].payload[[a_padding]] = Ones{PTO_XLEN};
    _Tiles[[2]].payload[[b_padding]] = Ones{PTO_XLEN};
    _Tiles[[1]].defined_elements[a_padding] = '1';
    _Tiles[[2]].defined_elements[b_padding] = '1';
    StartDefinednessTMATMUL();
    let padding_excluded = ExecuteBundleTileOperation();
    assert padding_excluded;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x41980000;
    assert ReadTileElement(destination, 1, 1) ==
        Zeros{PTO_XLEN} + 0x42480000;
    return 0;
end;
