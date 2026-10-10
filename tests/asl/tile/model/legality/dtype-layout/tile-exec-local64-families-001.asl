// PTO-TEST: {"id":"PTO-AVS-TILE-LOCAL64-FAMILIES-001","source":"asl/tile/model/legality/dtype-layout.asl","requirements":["PTO-LOCAL-TILE-B64-APPLICABILITY-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"Applicable Local numeric families execute all three 64-bit counterparts over M32 double-CELL operands.","pass_condition":"Independent exact integer and IEEE binary64 golden encodings prove arithmetic, scalar, unary, fused, reduction and fill results with preserved sources.","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/execution/unary.asl","asl/tile/model/execution/reduction.asl","asl/tile/model/execution/fused-multiply-add.asl"]}
pure func Local64OperationCode(operation: TileOperation) => bits(12)
begin
    for code = 0 to 127 do
        let decoded = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + code);
        if decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationOfIndex(decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) == operation then
            return Zeros{12} + code;
        end;
    end;
    unreachable;
end;

func Local64Case(operation: TileOperation, data_type: TileDataType,
    expected: Word)
begin
    ResetProfileState();
    for index = 0 to 3 do
        let configured = ConfigureCubeTile(index as TileIndex, 256, 1, 1,
            data_type, TileLayout_CUBE_M32);
        assert configured;
    end;
    let left = if data_type == TileDataType_FP64 then
        Zeros{PTO_XLEN} + 0x4020000000000000 else Zeros{PTO_XLEN} + 8;
    let right = if data_type == TileDataType_FP64 then
        Zeros{PTO_XLEN} + 0x4000000000000000 else Zeros{PTO_XLEN} + 2;
    let addend = if data_type == TileDataType_FP64 then
        Zeros{PTO_XLEN} + 0x3ff0000000000000 else Zeros{PTO_XLEN} + 1;
    WriteTileElement(1, 0, 0, left);
    WriteTileElement(2, 0, 0, right);
    WriteTileElement(3, 0, 0, addend);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.scalar0 = right;
    let (completed, -) = ExecuteTileInstruction(TileDecode_TEPL,
        Local64OperationCode(operation), operands);
    assert completed == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == expected;
    assert ReadTileElement(1, 0, 0) == left;
    assert _Tiles[[0]].cube_cell_count == 2;
end;

func main() => integer
begin
    Local64Case(TileOperation_TADD, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4024000000000000);
    Local64Case(TileOperation_TSUB, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4018000000000000);
    Local64Case(TileOperation_TMUL, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4030000000000000);
    Local64Case(TileOperation_TDIV, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4010000000000000);
    Local64Case(TileOperation_TREM, TileDataType_FP64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TMIN, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4000000000000000);
    Local64Case(TileOperation_TMAX, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TADDS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4024000000000000);
    Local64Case(TileOperation_TSUBS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4018000000000000);
    Local64Case(TileOperation_TMULS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4030000000000000);
    Local64Case(TileOperation_TDIVS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4010000000000000);
    Local64Case(TileOperation_TREMS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TMINS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4000000000000000);
    Local64Case(TileOperation_TMAXS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TABS, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TNEG, TileDataType_FP64, Zeros{PTO_XLEN} + 0xc020000000000000);
    Local64Case(TileOperation_TRELU, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TFMA, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4031000000000000);
    Local64Case(TileOperation_TROWSUM, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TROWPROD, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TROWMIN, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TROWMAX, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TCOLSUM, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TCOLPROD, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TCOLMIN, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TCOLMAX, TileDataType_FP64, Zeros{PTO_XLEN} + 0x4020000000000000);
    Local64Case(TileOperation_TADD, TileDataType_S64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSUB, TileDataType_S64, Zeros{PTO_XLEN} + 0x6);
    Local64Case(TileOperation_TMUL, TileDataType_S64, Zeros{PTO_XLEN} + 0x10);
    Local64Case(TileOperation_TDIV, TileDataType_S64, Zeros{PTO_XLEN} + 0x4);
    Local64Case(TileOperation_TREM, TileDataType_S64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TMIN, TileDataType_S64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TMAX, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TADDS, TileDataType_S64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSUBS, TileDataType_S64, Zeros{PTO_XLEN} + 0x6);
    Local64Case(TileOperation_TMULS, TileDataType_S64, Zeros{PTO_XLEN} + 0x10);
    Local64Case(TileOperation_TDIVS, TileDataType_S64, Zeros{PTO_XLEN} + 0x4);
    Local64Case(TileOperation_TREMS, TileDataType_S64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TMINS, TileDataType_S64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TMAXS, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TABS, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TNEG, TileDataType_S64, Zeros{PTO_XLEN} + 0xfffffffffffffff8);
    Local64Case(TileOperation_TRELU, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TFMA, TileDataType_S64, Zeros{PTO_XLEN} + 0x11);
    Local64Case(TileOperation_TROWSUM, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TROWPROD, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TROWMIN, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TROWMAX, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLSUM, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLPROD, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLMIN, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLMAX, TileDataType_S64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TADD, TileDataType_U64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSUB, TileDataType_U64, Zeros{PTO_XLEN} + 0x6);
    Local64Case(TileOperation_TMUL, TileDataType_U64, Zeros{PTO_XLEN} + 0x10);
    Local64Case(TileOperation_TDIV, TileDataType_U64, Zeros{PTO_XLEN} + 0x4);
    Local64Case(TileOperation_TREM, TileDataType_U64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TMIN, TileDataType_U64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TMAX, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TADDS, TileDataType_U64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSUBS, TileDataType_U64, Zeros{PTO_XLEN} + 0x6);
    Local64Case(TileOperation_TMULS, TileDataType_U64, Zeros{PTO_XLEN} + 0x10);
    Local64Case(TileOperation_TDIVS, TileDataType_U64, Zeros{PTO_XLEN} + 0x4);
    Local64Case(TileOperation_TREMS, TileDataType_U64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TMINS, TileDataType_U64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TMAXS, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TABS, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TNEG, TileDataType_U64, Zeros{PTO_XLEN} + 0xfffffffffffffff8);
    Local64Case(TileOperation_TRELU, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TFMA, TileDataType_U64, Zeros{PTO_XLEN} + 0x11);
    Local64Case(TileOperation_TROWSUM, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TROWPROD, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TROWMIN, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TROWMAX, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLSUM, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLPROD, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLMIN, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TCOLMAX, TileDataType_U64, Zeros{PTO_XLEN} + 0x8);
    Local64Case(TileOperation_TAND, TileDataType_S64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TOR, TileDataType_S64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TXOR, TileDataType_S64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSHL, TileDataType_S64, Zeros{PTO_XLEN} + 0x20);
    Local64Case(TileOperation_TSHR, TileDataType_S64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TANDS, TileDataType_S64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TORS, TileDataType_S64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TXORS, TileDataType_S64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSHLS, TileDataType_S64, Zeros{PTO_XLEN} + 0x20);
    Local64Case(TileOperation_TSHRS, TileDataType_S64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TNOT, TileDataType_S64, Zeros{PTO_XLEN} + 0xfffffffffffffff7);
    Local64Case(TileOperation_TAND, TileDataType_U64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TOR, TileDataType_U64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TXOR, TileDataType_U64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSHL, TileDataType_U64, Zeros{PTO_XLEN} + 0x20);
    Local64Case(TileOperation_TSHR, TileDataType_U64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TANDS, TileDataType_U64, Zeros{PTO_XLEN} + 0x0);
    Local64Case(TileOperation_TORS, TileDataType_U64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TXORS, TileDataType_U64, Zeros{PTO_XLEN} + 0xa);
    Local64Case(TileOperation_TSHLS, TileDataType_U64, Zeros{PTO_XLEN} + 0x20);
    Local64Case(TileOperation_TSHRS, TileDataType_U64, Zeros{PTO_XLEN} + 0x2);
    Local64Case(TileOperation_TNOT, TileDataType_U64, Zeros{PTO_XLEN} + 0xfffffffffffffff7);
    return 0;
end;
