// PTO-REQ-TEPL-001, PTO-REQ-TILE-LEGALITY-001: S4-T8 TEPL
// decoded-selector totality and reference-profile corner semantics.

func ConfigureTeplTile(index: TileIndex, rows: integer {1..256},
                       columns: integer {1..256}, data_type: TileDataType)
begin
    ConfigureTile(index, 2048, rows, columns, rows, columns, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func FillTeplTile(index: TileIndex, seed: integer {0..65535})
begin
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let offset = (row * tile.valid_columns + column)
                as integer {0..65535};
            WriteTileElement(index, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + seed + offset + 1);
        end;
    end;
end;

func ConfigureTeplFilledTile(index: TileIndex, rows: integer {1..256},
                             columns: integer {1..256},
                             data_type: TileDataType,
                             seed: integer {0..65535})
begin
    ConfigureTeplTile(index, rows, columns, data_type);
    FillTeplTile(index, seed);
end;

func ConfigureTeplDefaultCase() => TileInstructionOperands
begin
    for index = 0 to 5 do
        ConfigureTeplFilledTile(index as TileIndex, 2, 2,
            TileDataType_U64, (index + 1) as integer {0..65535});
    end;
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.destination1 = 5;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    operands.scalar0 = Zeros{PTO_XLEN} + 2;
    operands.positive0 = 1;
    operands.positive1 = 1;
    operands.positive2 = 1;
    operands.positive3 = 1;
    operands.natural0 = 0;
    operands.natural1 = 0;
    operands.selected_byte = 3;
    operands.flag0 = FALSE;
    return operands;
end;

pure func TeplOperationIsRowReduction(operation: TileOperation) => boolean
begin
    return operation == TileOperation_TROWSUM ||
           operation == TileOperation_TROWPROD ||
           operation == TileOperation_TROWMAX ||
           operation == TileOperation_TROWMIN ||
           operation == TileOperation_TROWARGMAX ||
           operation == TileOperation_TROWARGMIN;
end;

pure func TeplOperationIsColumnReduction(operation: TileOperation) => boolean
begin
    return operation == TileOperation_TCOLSUM ||
           operation == TileOperation_TCOLPROD ||
           operation == TileOperation_TCOLMAX ||
           operation == TileOperation_TCOLMIN ||
           operation == TileOperation_TCOLARGMAX ||
           operation == TileOperation_TCOLARGMIN;
end;

pure func TeplOperationIsRowExpand(operation: TileOperation) => boolean
begin
    return operation == TileOperation_TROWEXPAND ||
           operation == TileOperation_TROWEXPANDADD ||
           operation == TileOperation_TROWEXPANDSUB ||
           operation == TileOperation_TROWEXPANDMUL ||
           operation == TileOperation_TROWEXPANDDIV ||
           operation == TileOperation_TROWEXPANDMAX ||
           operation == TileOperation_TROWEXPANDMIN ||
           operation == TileOperation_TROWEXPANDEXPDIF;
end;

pure func TeplOperationIsColumnExpand(operation: TileOperation) => boolean
begin
    return operation == TileOperation_TCOLEXPAND ||
           operation == TileOperation_TCOLEXPANDADD ||
           operation == TileOperation_TCOLEXPANDSUB ||
           operation == TileOperation_TCOLEXPANDMUL ||
           operation == TileOperation_TCOLEXPANDDIV ||
           operation == TileOperation_TCOLEXPANDMAX ||
           operation == TileOperation_TCOLEXPANDMIN ||
           operation == TileOperation_TCOLEXPANDEXPDIF;
end;

pure func TeplOperationIsPartial(operation: TileOperation) => boolean
begin
    return operation == TileOperation_TPARTADD ||
           operation == TileOperation_TPARTMUL ||
           operation == TileOperation_TPARTMAX ||
           operation == TileOperation_TPARTMIN;
end;

func ConfigureTeplDecodedCase(operation: TileOperation) => TileInstructionOperands
begin
    ResetProfileState();
    var operands = ConfigureTeplDefaultCase();

    if TeplOperationIsRowReduction(operation) then
        ConfigureTeplTile(0, 2, 1, TileDataType_U64);
    elsif TeplOperationIsColumnReduction(operation) then
        ConfigureTeplTile(0, 1, 2, TileDataType_U64);
    elsif TeplOperationIsRowExpand(operation) then
        ConfigureTeplFilledTile(2, 2, 1, TileDataType_U64, 20);
    elsif TeplOperationIsColumnExpand(operation) then
        ConfigureTeplFilledTile(2, 1, 2, TileDataType_U64, 20);
    elsif operation == TileOperation_TFILLPAD then
        ConfigureTeplTile(0, 3, 3, TileDataType_U64);
        ConfigureTeplFilledTile(1, 2, 2, TileDataType_U64, 10);
    elsif operation == TileOperation_TCVT ||
          operation == TileOperation_TQUANT ||
          operation == TileOperation_TDEQUANT then
        ConfigureTeplTile(0, 2, 2, TileDataType_U32);
        ConfigureTeplFilledTile(1, 2, 2, TileDataType_U64, 10);
    elsif operation == TileOperation_TEXTRACT then
        ConfigureTeplTile(0, 1, 2, TileDataType_U64);
        ConfigureTeplFilledTile(1, 2, 2, TileDataType_U64, 10);
        operands.natural0 = 1;
    elsif operation == TileOperation_TINSERT then
        ConfigureTeplFilledTile(0, 2, 2, TileDataType_U64, 40);
        ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
        operands.natural0 = 1;
    elsif operation == TileOperation_TGATHER then
        ConfigureTeplTile(0, 1, 2, TileDataType_U64);
        ConfigureTeplFilledTile(1, 2, 2, TileDataType_U64, 10);
        ConfigureTeplTile(2, 1, 2, TileDataType_U64);
        WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    elsif operation == TileOperation_TSCATTER then
        ConfigureTeplFilledTile(0, 2, 2, TileDataType_U64, 40);
        ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
        ConfigureTeplTile(2, 1, 2, TileDataType_U64);
        WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    elsif operation == TileOperation_TCONCAT then
        ConfigureTeplTile(0, 2, 2, TileDataType_U64);
        ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
        ConfigureTeplFilledTile(2, 1, 2, TileDataType_U64, 20);
        operands.axis = TileAxis_Row;
    elsif operation == TileOperation_TIMG2COL then
        ConfigureTeplTile(0, 4, 4, TileDataType_U64);
        ConfigureTeplFilledTile(1, 3, 3, TileDataType_U64, 10);
        operands.positive0 = 2;
        operands.positive1 = 2;
    elsif operation == TileOperation_TSORT then
        ConfigureTeplTile(0, 1, 4, TileDataType_U64);
        ConfigureTeplTile(5, 1, 4, TileDataType_U32);
        ConfigureTeplFilledTile(1, 1, 4, TileDataType_U64, 10);
    elsif operation == TileOperation_TMRGSORT then
        ConfigureTeplTile(0, 1, 4, TileDataType_U64);
        ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
        ConfigureTeplFilledTile(2, 1, 2, TileDataType_U64, 20);
    elsif operation == TileOperation_THISTOGRAM then
        ConfigureTeplTile(0, 1, 256, TileDataType_U64);
        ConfigureTeplFilledTile(1, 1, 4, TileDataType_U32, 0);
        ConfigureTeplFilledTile(2, 3, 1, TileDataType_U8, 0);
        operands.selected_byte = 3;
    elsif TeplOperationIsPartial(operation) then
        ConfigureTeplTile(0, 1, 3, TileDataType_U64);
        ConfigureTeplFilledTile(1, 1, 3, TileDataType_U64, 10);
        ConfigureTeplFilledTile(2, 1, 2, TileDataType_U64, 20);
    end;
    return operands;
end;

readonly func TeplTileFingerprint(index: TileIndex) => Word
begin
    var fingerprint = Zeros{PTO_XLEN};
    if _Tiles[[index]].allocated then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 1;
    end;
    if _Tiles[[index]].contents_defined then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 2;
    end;
    let bounded_capacity = if _Tiles[[index]].capacity_bytes > 262144 then
        262144 else _Tiles[[index]].capacity_bytes;
    fingerprint = fingerprint +
        NaturalToWord(bounded_capacity as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].rows * 3) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].columns * 5) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].valid_rows * 7) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].valid_columns * 11) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].defined_valid_elements * 13)
            as integer {0..262144});
    for element = 0 to 15 do
        fingerprint = fingerprint +
            NaturalToWord((element + 17) as integer {0..262144});
        if _Tiles[[index]].defined_elements[element] == '1' then
            fingerprint = fingerprint +
                _Tiles[[index]].payload[[element as ModelTileElementIndex]] +
                NaturalToWord(((element + 1) * 257)
                    as integer {0..262144});
        end;
    end;
    return fingerprint;
end;

readonly func TeplStateFingerprint() => Word
begin
    var fingerprint = Zeros{PTO_XLEN};
    for index = 0 to 7 do
        fingerprint = fingerprint +
            TeplTileFingerprint(index as TileIndex) +
            NaturalToWord((index + 1) as integer {0..262144});
    end;
    return fingerprint;
end;

func ExecuteTeplCaseFingerprint(operation: TileOperation, code: bits(12))
    => (TileExecutionStatus, Word, Word)
begin
    let operands = ConfigureTeplDecodedCase(operation);
    let before = TeplStateFingerprint();
    ClearFault();
    let (status, value) = ExecuteTileInstruction(TileDecode_TEPL, code, operands);
    assert value == Zeros{PTO_XLEN};
    return (status, before, TeplStateFingerprint());
end;

func TestTeplDecodedSelectorMatrix()
begin
    var accepted: integer {0..256} = 0;
    for selector = 0 to 127 do
        let code = Zeros{12} + selector;
        let operation_index = DecodeTileOperation(TileDecode_TEPL, code);
        if operation_index != PTO_TILE_OPERATION_COUNT then
            println selector;
            let operation = TileOperationOfIndex(
                operation_index as integer {0..PTO_TILE_OPERATION_COUNT-1});
            let (status0, before0, after0) =
                ExecuteTeplCaseFingerprint(operation, code);
            assert status0 == TileExecution_Executed;
            assert _LastFault == Fault_None;

            let (status1, before1, after1) =
                ExecuteTeplCaseFingerprint(operation, code);
            assert status1 == TileExecution_Executed;
            assert _LastFault == Fault_None;
            assert before1 == before0;
            assert after1 == after0;
            accepted = (accepted + 1) as integer {0..256};
        end;
    end;
    assert accepted == 87;
end;

func TestTeplReservedSelectorRejection()
begin
    var rejected: integer {0..256} = 0;
    for selector = 0 to 127 do
        let code = Zeros{12} + selector;
        if DecodeTileOperation(TileDecode_TEPL, code) == PTO_TILE_OPERATION_COUNT then
            ResetProfileState();
            let operands = ConfigureTeplDefaultCase();
            let before = TeplStateFingerprint();
            ClearFault();
            let (status, value) = ExecuteTileInstruction(
                TileDecode_TEPL, code, operands);
            assert status == TileExecution_Rejected;
            assert value == Zeros{PTO_XLEN};
            assert _LastFault == Fault_IllegalInstruction;
            assert TeplStateFingerprint() == before;
            rejected = (rejected + 1) as integer {0..256};
        end;
    end;
    assert rejected == 41;
end;

func TestTeplRawCarrierAndLayoutPolicy()
begin
    assert TileTeplRawCarrierTypeSupported(TileDataType_FP64);
    assert TileTeplRawCarrierTypeSupported(TileDataType_FP32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_TF32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_HF32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_FP16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_BF16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_HiF8);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E4M3);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E5M2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E3M2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E2M3);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E2M1X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E1M2X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E8M0);
    assert TileTeplRawCarrierTypeSupported(TileDataType_HiF4X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S64);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S8);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S4X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U64);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U8);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U4X2);

    ResetProfileState();
    ConfigureTeplFilledTile(0, 1, 1, TileDataType_U64, 90);
    ConfigureTeplFilledTile(1, 1, 1, TileDataType_U64, 1);
    ConfigureTeplFilledTile(2, 1, 1, TileDataType_U64, 2);
    _Tiles[[1]].layout = TileLayout_ImplementationDefined;
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    ClearFault();
    let (status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', operands);
    assert status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 91;
end;

func TestTeplAliasAndPreservedRegionPolicy()
begin
    ResetProfileState();
    ConfigureTeplFilledTile(0, 2, 2, TileDataType_U64, 40);
    ConfigureTeplFilledTile(1, 1, 1, TileDataType_U64, 10);
    var insert = DefaultTileInstructionOperands();
    insert.destination0 = 0;
    insert.source0 = 1;
    insert.natural0 = 1;
    insert.natural1 = 1;
    ClearFault();
    let (insert_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001100011', insert);
    assert insert_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 41;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 11;
end;

func TestTeplIndexSortHistogramCorners()
begin
    ResetProfileState();
    ConfigureTeplFilledTile(0, 1, 4, TileDataType_U64, 40);
    ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
    ConfigureTeplTile(2, 1, 2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    var scatter = DefaultTileInstructionOperands();
    scatter.destination0 = 0;
    scatter.source0 = 1;
    scatter.source1 = 2;
    ClearFault();
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001110000', scatter);
    assert scatter_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 42;

    ResetProfileState();
    ConfigureTeplTile(0, 1, 4, TileDataType_U64);
    ConfigureTeplTile(2, 1, 4, TileDataType_U32);
    ConfigureTeplTile(1, 1, 4, TileDataType_U64);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 2);
    var sort = DefaultTileInstructionOperands();
    sort.destination0 = 0;
    sort.destination1 = 2;
    sort.source0 = 1;
    sort.sort_width = 2;
    sort.flag0 = TRUE;
    ClearFault();
    let (sort_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101100', sort);
    assert sort_status == TileExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 2;

end;

func TestTeplInvalidIndexAndOffsetNoEffect()
begin
    ResetProfileState();
    ConfigureTeplFilledTile(0, 1, 2, TileDataType_U64, 90);
    ConfigureTeplFilledTile(1, 2, 2, TileDataType_U64, 10);
    ConfigureTeplTile(2, 1, 2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    var gather = DefaultTileInstructionOperands();
    gather.destination0 = 0;
    gather.source0 = 1;
    gather.source1 = 2;
    ClearFault();
    let (gather_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101111', gather);
    assert gather_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 91;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 92;

    ResetProfileState();
    ConfigureTeplFilledTile(0, 2, 2, TileDataType_U64, 90);
    ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
    ConfigureTeplTile(2, 1, 2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    var scatter = DefaultTileInstructionOperands();
    scatter.destination0 = 0;
    scatter.source0 = 1;
    scatter.source1 = 2;
    ClearFault();
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001110000', scatter);
    assert scatter_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 91;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 94;
end;

func TestTeplMergeDuplicateOrdering()
begin
    ResetProfileState();
    ConfigureTeplTile(0, 1, 5, TileDataType_U64);
    ConfigureTeplTile(1, 1, 3, TileDataType_U64);
    ConfigureTeplTile(2, 1, 2, TileDataType_U64);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 3);
    var merge = DefaultTileInstructionOperands();
    merge.destination0 = 0;
    merge.source0 = 1;
    merge.source1 = 2;
    ClearFault();
    let (ascending_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101101', merge);
    assert ascending_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 4) == Zeros{PTO_XLEN} + 3;

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 1);
    merge.flag0 = TRUE;
    ClearFault();
    let (descending_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101101', merge);
    assert descending_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 4) == Zeros{PTO_XLEN} + 1;
end;

// A missing TFMA dispatch or wrong source ordering changes 5 + 2 * 3 = 11.
func TestTeplTfmaExactResult()
begin
    ResetProfileState();
    ConfigureTeplTile(0, 1, 1, TileDataType_U64);
    ConfigureTeplTile(1, 1, 1, TileDataType_U64);
    ConfigureTeplTile(2, 1, 1, TileDataType_U64);
    ConfigureTeplTile(3, 1, 1, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    TFMA(0, 1, 2, 3);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 11;
end;

// A wrong TSORT direction, comparison, or index permutation changes this
// four-lane ascending result and its original-lane indices.
func TestTeplTsortExactPermutation()
begin
    ResetProfileState();
    ConfigureTeplTile(0, 1, 4, TileDataType_U64);
    ConfigureTeplTile(1, 1, 4, TileDataType_U32);
    ConfigureTeplTile(2, 1, 4, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 3, Zeros{PTO_XLEN} + 2);
    TSORT(0, 1, 2, 32, FALSE);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(1, 0, 2) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(1, 0, 3) == Zeros{PTO_XLEN};
end;

func TestTeplTotality()
begin
    TestTeplDecodedSelectorMatrix();
    TestTeplReservedSelectorRejection();
    TestTeplRawCarrierAndLayoutPolicy();
    TestTeplAliasAndPreservedRegionPolicy();
    TestTeplIndexSortHistogramCorners();
    TestTeplInvalidIndexAndOffsetNoEffect();
    TestTeplMergeDuplicateOrdering();
    TestTeplTfmaExactResult();
    TestTeplTsortExactPermutation();
end;
