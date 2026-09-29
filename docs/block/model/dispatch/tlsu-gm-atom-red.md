<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gm-atom-red.asl -->
# TLSU Gm Atom Red

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gm-atom-red.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for the indexed global-memory atomics and reductions. An atomic (an `MGATHER.<op>` form) updates each addressed element and returns the old values in a new Local Tile. A reduction (an `MSCATTER.<op>` form) updates memory and returns nothing.

`BundleGMAtomRedSelected` recognizes a valid `TileMemory` descriptor whose selector function is in `8..12` or `14..27`. Function `13` is `GMOV` and is excluded. `ExecuteBundleGMAtomRedOperation` validates the bundle and calls one of `GM_ATOM_CAS`, `GM_ATOM_VALUE`, `GM_RED_VALUE`, or `GM_RED_POPC`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-concepts role=concepts-state -->
## Concepts and visible state

The function number fixes the operation and its legal data types.

| Functions | Kind | Operations and data types |
| --- | --- | --- |
| `8` | atomic | CAS: U16, U32, U64 |
| `9`, `10`, `11`, `12` | atomic | EXCH: U32, U64; MAX and MIN: S32, S64, U32, U64; ADD: FP16, BF16, FP32, FP64, S32, U32, U64 |
| `14` to `18` | atomic | INC and DEC: U32; AND, OR, XOR: U32, U64 |
| `19` to `26` | reduction | MAX, MIN, ADD, INC, DEC, AND, OR, XOR, with the same type sets as the atomics |
| `27` | reduction | POPC: U32 |

Every form requires one `B.IOR` record, whose `source0` gives the base address for the current memory agent. The first `B.IOT` carries the index Tile in `source0`. Except for POPC, it carries the value Tile in `source1`, which must have the operation data type. The index Tile and value Tile must have the `B.DIM` valid rows and valid columns and the bundle layout, and the index Tile is S32, U32, S64, or U64.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds. The ASL comment places this before every schema, descriptor, type, or memory check.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Missing or illegal `B.IOR`, Shared bindings, nonuniform PE masks, and dimensions rejected by `BundleMGATHERDimensionsLegal` raise `Fault_TileLegality`.

The expected number of `B.IOT` bindings is 2 for CAS, 1 for POPC, and otherwise 1, or 2 under a predicate-Tile execution mask. A wrong count raises `Fault_BundleControl`. A wrong binding shape, data type, or source shape raises `Fault_TileLegality`.

For a non-CAS atomic without an execution mask, the single binding carries the destination and `last`. Under a predicate-Tile execution mask, the first binding has no destination and no `last`, and a second binding carries one source, the destination, and `last`. Reductions other than POPC follow the same pattern with no destination. POPC always uses one binding with the index Tile in `source0`; this handler does not check its `last` flag, and it checks for no destination only when no execution mask is in force.

For atomics, the handler checks the physical shape, resolves the destination, validates Local generation writers, and checks operand legality. A failure after resolution, or a memory fault, calls `RollBackBundleTileDestinations`. Reductions resolve nothing, so a fault needs no rollback. Success calls `FinalizeBundleTileAttempt`.

Design point: only a wrong `B.IOT` binding count raises `Fault_BundleControl`. A missing `B.IOR`, a Shared binding, and a wrong operand inside a correctly counted schema raise `Fault_TileLegality`. A program can tell a malformed command stream from a bad operand by the fault kind.

Design point: the handler contains a CAS path for function `8`, and its comment describes the two-command CAS schema. However, `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` tests `BundleMGATHERCASSelected` first, so a function `8` bundle that no earlier selector (such as CUBE transport) claims reaches the dedicated CAS handler instead, and the CAS path in this handler is not reached from that dispatcher.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-boundaries role=boundaries -->
## Architectural boundaries

This unit is reached only after the TIMG2COL, weight-load, matrix, CUBE layout-conversion, `GMOV`, and `MGATHER.CAS` selectors did not match. The caller commits or aborts Local generations afterwards.

The arithmetic of each update, such as the INC wrap rule and floating ADD, belongs to the Tile GM atomic and reduction owners.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a bundle selects function `21` (reduction ADD) with data type FP32 and no execution mask, and `B.DIM` sets `LB0` to 16, `LB1` to 1, and `LB2` to 16. One `B.IOT` carries a U32 index Tile and a FP32 value Tile, both 1 by 16, with no destination and with `last`. The handler calls `GM_RED_VALUE`, which adds 16 values into memory, and no Tile is written.

If the same bundle selected function `12` (atomic ADD), the single binding must also carry a destination, which receives the 16 old values.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-related role=related-owners-navigation -->
## Related owners

- [MGATHER.CAS dispatch](tlsu-mgather-cas.md) is the handler that function `8` reaches.
- [GM atomic and reduction types](../../../tile/model/memory/gm-atom-red.md) define the data type sets.
- [GM atomic and reduction execution](../../../tile/model/memory/gm-atom-red-execution.md) defines the memory effects.
- [BSTART.MGATHER.ADD](../../execution/BSTART.MGATHER.ADD.md) and [BSTART.MSCATTER.ADD](../../execution/BSTART.MSCATTER.ADD.md) are example instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gm-atom-red.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED","surface":"block","classification":["model","dispatch","tlsu-gm-atom-red"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION"]}

readonly func BundleGMAtomRedSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return (function >= 8 && function <= 12) ||
           (function >= 14 && function <= 27);
end;

readonly func BundleGMAtomRedDataTypeLegal(function: integer {0..31},
                                           data_type: TileDataType) => boolean
begin
    if function <= 18 then
        return GMAtomicOperationDataTypeLegal(
            GMAtomicOperationFromFunction(function), data_type);
    end;
    return GMReductionOperationDataTypeLegal(
        GMReductionOperationFromFunction(function), data_type);
end;

func ExecuteBundleGMAtomRedOperation() => boolean
begin
    // PE_MASK=0000 exits before every schema, descriptor, type, or memory check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let function = UInt(_BundleOperation.selector[4:0]) as integer {0..31};
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let atom = function <= 18;
    let cas = function == 8;
    let popc = function == 27;
    var expected_binding_count: integer {1..2} = 1;
    if cas then expected_binding_count = 2; end;
    if execution_mask_tile && !popc && !cas then
        expected_binding_count = 2;
    end;
    if atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // mgather.cas and the legacy MGATHER.CAS alias use the two-command schema:
    // the first B.IOT carries indices and expected values, while the second
    // carries replacement and the destination.  Other atom forms carry all
    // operands in one destination-bearing B.IOT.
    if !binding.valid || !binding.source0_valid ||
       ((!cas && !popc &&
         (binding.last == execution_mask_tile)) || (cas && binding.last)) ||
       (cas && (binding.destination_valid || !binding.source1_valid)) ||
       (cas && execution_mask_tile &&
        (_BundleTileBindings[[1]].source1_valid == FALSE)) ||
       (!cas && !execution_mask_tile &&
        binding.destination_valid != atom) ||
       (execution_mask_tile && atom && !cas &&
        binding.destination_valid) ||
       (!popc && !cas && !binding.source1_valid) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if execution_mask_tile && !cas && !popc then
        let final_binding = _BundleTileBindings[[1]];
        if !final_binding.valid || !final_binding.source0_valid ||
           final_binding.source1_valid || !final_binding.last ||
           (final_binding.destination_valid != atom) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !BundleGMAtomRedDataTypeLegal(function, data_type) ||
       !IndexedTLSUExecutionMaskContentsDefined(binding.source0) ||
       (!popc && (!IndexedTLSUExecutionMaskContentsDefined(binding.source1) ||
           _Tiles[[binding.source1]].data_type != data_type)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if _Tiles[[binding.source0]].valid_rows != valid_rows ||
       _Tiles[[binding.source0]].valid_columns != valid_columns ||
       _Tiles[[binding.source0]].layout != CurrentBundleTileLayout() ||
       !IndexedTLSUMemoryIndexDataTypeLegal(
           _Tiles[[binding.source0]].data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !popc && (_Tiles[[binding.source1]].valid_rows != valid_rows ||
       _Tiles[[binding.source1]].valid_columns != valid_columns ||
       _Tiles[[binding.source1]].layout != CurrentBundleTileLayout()) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if atom then
        var destination: TileIndex = if execution_mask_tile && !cas then
            _BundleTileBindings[[1]].destination else binding.destination;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !second.destination_valid || !second.source0_valid ||
               (second.source1_valid != execution_mask_tile) || !second.last ||
               !IndexedTLSUExecutionMaskContentsDefined(second.source0) ||
               _Tiles[[second.source0]].layout !=
                   CurrentBundleTileLayout() then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            destination = second.destination;
        end;
        if !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
               valid_rows, valid_columns, columns) ||
           !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
               valid_columns, columns, TRUE, data_type) then return FALSE; end;
        if !ValidateBundleLocalGenerationWriters() then
            RollBackBundleTileDestinations(); return FALSE;
        end;
        destination = if cas || execution_mask_tile then
            _BundleTileBindings[[1]].destination
            else _BundleTileBindings[[0]].destination;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !TileOperandsLegal_GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                   binding.source0, binding.source1, second.source0,
                   CurrentBundlePadValue()) then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                binding.source0, binding.source1, second.source0,
                CurrentBundlePadValue());
        else
            if !TileOperandsLegal_GM_ATOM_VALUE(
                   GMAtomicOperationFromFunction(function), destination,
                   base_address, binding.source0, binding.source1,
                   CurrentBundlePadValue()) then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            GM_ATOM_VALUE(GMAtomicOperationFromFunction(function), destination,
                base_address, binding.source0, binding.source1,
                CurrentBundlePadValue());
        end;
    elsif popc then
        if !TileOperandsLegal_GM_RED_POPC(GMReduction_POPC, base_address,
               binding.source0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        GM_RED_POPC(GMReduction_POPC, base_address, binding.source0);
    else
        if !TileOperandsLegal_GM_RED_VALUE(
               GMReductionOperationFromFunction(function), base_address,
               binding.source0, binding.source1, CurrentBundlePadValue()) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        GM_RED_VALUE(GMReductionOperationFromFunction(function), base_address,
            binding.source0, binding.source1, CurrentBundlePadValue());
    end;
    if _LastFault != Fault_None then
        if atom then RollBackBundleTileDestinations(); end;
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
