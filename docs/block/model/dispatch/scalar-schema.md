<!-- GENERATED FROM: asl/block/model/dispatch/scalar-schema.asl -->
# Scalar Schema

**Normative ASL source:** `asl/block/model/dispatch/scalar-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the rules for `B.IOR`, the bundle command that binds general-purpose registers (GPRs) to a Tile operation. One `B.IOR` carries a destination selector `RegDst` and up to three source selectors `RegSrc0`, `RegSrc1`, and `RegSrc2`. Selector code 0 names the architectural zero register.

The unit works at three points in a bundle's life:

- While header commands decode, it decides where a `B.IOR` may be placed and whether a second one is expected.
- When the bundle is checked for completeness, it checks the selector structure without reading any GPR.
- Before destinations are allocated, it reads the GPR values and checks their ranges.

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-concepts role=concepts-state -->
## Concepts and visible state

`_BundleScalarBindings` has two entries. Index 0 holds the first `B.IOR`. Index 1 is used only when `BundleMultiIORSelected` is true, which happens for `TGPR2T`, `TIMG2COL`, and operations eligible for an ExecutionMask. Each entry records its selectors, a `source_count`, and an `execution_mask_present` flag.

The operation inputs are packed densely into source slots in a fixed order: `address`, `scalar0`, `diagonal`, then `flag0`, followed for a matrix bundle by a quantization parameter and a ReLU parameter when `B.FPATR` selects scalar parameters. `BundleOperationGPRInputCount` counts the present inputs, and `BundleOperationGPRInputSlot` gives the slot of `address`, `scalar0`, `diagonal`, or `flag0`; the value check computes the matrix parameter slots itself.

The unit only reads state. It writes nothing and raises no fault by itself; its callers raise the fault.

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-rules role=rules-interactions -->
## Rules and interactions

Placement rules are evaluated by the command decoder. For `TGPR2T`, `RegDst` is 0 and both `B.IOR` commands precede any participating `B.IOT`. For `TIMG2COL`, `B.IOR` precedes all Tile and Shared bindings, `RegDst` is 0, and the first one has `RegSrc1` and `RegSrc2` zero. For an ExecutionMask stream, the second `B.IOR` has `RegDst` 0 and follows a first one without the mask flag. When `TGPR2T` or `TIMG2COL` has received only its first `B.IOR`, the next command must be the second one. `TGPR2T` also accepts a zero-participation `B.IOT`, and any command once zero participation has been seen. A violation raises `Fault_BundleControl`.

`BundleOperationScalarBindingSchemaLegal` checks structure only:

- In the ordinary case, every source slot beyond the input count must be selector 0, and `RegDst` must be 0.
- `TEXPDIF` without an ExecutionMask accepts no `B.IOR`.
- CUBE `TCI` needs exactly one `B.IOR` with two selectors below `PTO_ABSOLUTE_GPR_COUNT` (24), `RegSrc2` zero, and `RegDst` zero.
- A GPR ExecutionMask defers to `BundleExecutionMaskGPRBindingSchemaLegal`. It requires a `CUBE_M16` or `CUBE_M32` mask layout and allows up to 6 slots, operation inputs first and then 1 or 2 mask words. A second `B.IOR` is used exactly when more than 3 slots are needed, and the mask flag marks the last `B.IOR` used.

`BundleOperationGPRBindingValuesLegal` reads values. `flag0` must be 0 or 1. `diagonal` must be in -65535 to 65535. A matrix scalar parameter must be a legal parameter word. For CUBE `TCI`, each participating PE's Step2D row step and column step must each be -1, 0, or 1. `TGPR2T` without a mask needs two `B.IOR` commands: the first with 3 sources, the second with 1, every selector below 24, and `RegDst` 0. Without an ExecutionMask, an ordinary operation accepts no second `B.IOR` and at most 3 inputs.

Design point: structure and value checks are separate. After the zero-participation exit, the local Tile path first checks completeness (failure raises `Fault_BundleControl`), then checks values (failure raises `Fault_TileLegality`) before destination allocation. The ASL comment states the consequence: invalid values never enter the constrained `TileInstructionOperands` fields or Tile state. On this path a bundle with `PE_MASK` 0000 reads no GPR.

Design point: unused selectors must be 0 rather than ignored. A `B.IOR` source slot has no separate omission encoding; code 0 names the zero register. The ordinary check therefore accepts only code 0 in a slot beyond the input count, and on the local Tile path a surplus nonzero selector fails the completeness check with `Fault_BundleControl`.

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not read scalars for execution. [Tile instruction operands](tile-instruction-operands.md) uses the same slot functions to fill the operands, and the ExecutionMask owners interpret mask words. Comparison and select operations skip the ordinary value checks here; their `B.IOR` layouts are checked by the [comparison schema](comparison-schema.md).

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TADDS <Row=8, Col=64, FP32>, T#1, a2, ->T<2KB>` has one input, `scalar0`, so its `B.IOR` is `a2, zero, zero, ->zero`. A `B.IOR` with a nonzero `RegSrc1` fails the structure check.

`TTRI` has `diagonal` in slot 0 and `flag0` in slot 1. If the orientation register holds 2, the value check fails and the bundle raises `Fault_TileLegality` before any destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-related role=related-owners-navigation -->
## Related owners

- [Commands](commands.md) applies the placement and stream rules while decoding `B.IOR`.
- [Descriptor legality](descriptor-legality.md) calls the structure check as part of binding completeness.
- [Tile execution dispatch](tile-execution.md) orders the value check before destination resolution.
- [Execution mask schema](execution-mask-schema.md) interprets GPR mask words.
- [Scalar bindings](../operands/scalar-bindings.md) stores the `B.IOR` records.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/scalar-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
readonly func DecodedBundleCommandKeepsTGPR2TStreamLegal(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1})
    => boolean
begin
    let handler = CommandHandlerOfForm(form);
    let zero_participation = handler == CommandHandler_BindBundleTileIO &&
        PEMaskOfPEMode(DecodeCommandOperandRaw(
            instruction, form, CommandField_PEMode)[2:0]) == Zeros{4};
    return _BundleZeroParticipationSeen ||
           !BundleTGPR2TSelected() ||
           !_BundleScalarBindings[[0]].valid ||
           _BundleScalarBindings[[1]].valid ||
           handler == CommandHandler_BindBundleScalarIO ||
           zero_participation;
end;

readonly func BundleTIMG2COLIORSecondExpected() => boolean
begin
    return BundleDescriptorSelectsTIMG2COL(_BundleOperation) &&
           _BundleScalarBindings[[0]].valid &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func DecodedBundleCommandKeepsTIMG2COLStreamLegal(
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return !BundleTIMG2COLIORSecondExpected() ||
           CommandHandlerOfForm(form) == CommandHandler_BindBundleScalarIO;
end;

readonly func BundleTIMG2COLScalarCommandCanBePlaced(
    binding_index: integer {0..1}, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    if !BundleDescriptorSelectsTIMG2COL(_BundleOperation) then return TRUE; end;
    if BundleTileBindingCount() != 0 || BundleSharedBindingCount() != 0 ||
       CommandDecodedReg5(instruction, form, CommandField_RegDst) != 0 then
        return FALSE;
    end;
    if binding_index == 0 then
        return CommandDecodedReg5(instruction, form, CommandField_RegSrc1) == 0 &&
               CommandDecodedReg5(instruction, form, CommandField_RegSrc2) == 0;
    end;
    return TRUE;
end;

readonly func BundleTGPR2TScalarCommandCanBePlaced(
    binding_index: integer {0..1}, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return !BundleTGPR2TSelected() ||
           ((binding_index != 0 || BundleTileBindingCount() == 0) &&
            CommandDecodedReg5(instruction, form, CommandField_RegDst) == 0);
end;

readonly func BundleTGPR2TScalarBindingsComplete() => boolean
begin
    return _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[1]].valid;
end;

readonly func BundleTGPR2TSelected() => boolean
begin
    if !_BundleOperation.valid ||
       (_BundleOperation.operation_class != BundleOperation_TileElement &&
        _BundleOperation.operation_class != BundleOperation_TileMemory &&
        _BundleOperation.operation_class != BundleOperation_TileMatrix) then
        return FALSE;
    end;
    let decoded = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    return decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationOfIndex(
               decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
               TileOperation_TGPR2T;
end;


readonly func BundleExecutionMaskGPRStreamSelected() => boolean
begin
    if !_BundleOperation.valid ||
       (_BundleOperation.operation_class != BundleOperation_TileElement &&
        _BundleOperation.operation_class != BundleOperation_TileMemory &&
        _BundleOperation.operation_class != BundleOperation_TileMatrix) then
        return FALSE;
    end;
    let decoded = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    return decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationExecutionMaskEligible(
               decoded as integer {0..PTO_TILE_OPERATION_COUNT-1});
end;

readonly func BundleMultiIORSelected() => boolean
begin
    return BundleTGPR2TSelected() ||
           BundleDescriptorSelectsTIMG2COL(_BundleOperation) ||
           BundleExecutionMaskGPRStreamSelected();
end;

readonly func BundleMultiIORBindingIndex() => integer {0..1}
begin
    if BundleMultiIORSelected() && _BundleScalarBindings[[0]].valid then
        return 1;
    end;
    return 0;
end;

readonly func BundleMultiIORScalarCommandCanBePlaced(
    binding_index: integer {0..1}, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    if !BundleTGPR2TScalarCommandCanBePlaced(
           binding_index, instruction, form) ||
       !BundleTIMG2COLScalarCommandCanBePlaced(
           binding_index, instruction, form) then
        return FALSE;
    end;
    if BundleExecutionMaskGPRStreamSelected() && binding_index == 1 then
        return CommandDecodedReg5(instruction, form, CommandField_RegDst) == 0 &&
               !_BundleScalarBindings[[0]].execution_mask_present;
    end;
    return TRUE;
end;

pure func BundleOperationConsumesScalarSource0(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperandPresent(operation, TileOperand_address) ||
           TileOperandPresent(operation, TileOperand_scalar0);
end;

pure func BundleOperationConsumesScalarSource1(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperandPresent(operation, TileOperand_address) &&
           TileOperandPresent(operation, TileOperand_scalar0);
end;

// Complete-bundle GPR inputs pack present address, scalar0, diagonal, and flag0 operands densely.
readonly func BundleOperationGPRInputCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..7}
begin
    var count: integer {0..7} = 0;
    if TileOperandPresent(operation, TileOperand_address) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        count = (count + 1) as integer {0..7};
    end;
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid then
        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            count = (count + 1) as integer {0..7};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            count = (count + 1) as integer {0..7};
        end;
    end;
    return count;
end;

readonly func BundleExecutionMaskGPRWordCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {1..2}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TPACK ||
       decoded == TileOperation_TUNPACK then
        let binding = _BundleTileBindings[[0]];
        let tile_index = if binding.source0_subview.materialized then binding.source0_subview.materialized_index else binding.source0;
        let tile = _Tiles[[tile_index]];
        let bytes_per_element = (TileElementBits(tile.data_type) DIVRM 8) as integer {0..4};
        let valid_bytes = (tile.valid_columns * bytes_per_element) as integer {0..262140};
        let words_per_row = ((valid_bytes + 3) DIVRM 4) as integer {0..65535};
        if tile.valid_rows == 0 || words_per_row == 0 then return 1; end;
        let row_bits = if tile.layout == TileLayout_CUBE_M32 then 32 else 16;
        let final_bit = ((words_per_row - 1) * row_bits + tile.valid_rows) as integer {0..2097120};
        return if final_bit <= 64 then 1 else 2;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return if TileOperationExecutionMaskEligible(operation) &&
        TileElementBits(data_type) == 8 then 2 else 1;
end;

readonly func BundleExecutionMaskOperationGPRSourceCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..5}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCMP then return 0; end;
    if decoded == TileOperation_TCMPS then return 1; end;
    if decoded == TileOperation_TSEL then
        return if BundleTileBindingCount() == 1 then
            BundleExecutionMaskGPRWordCount(operation) else 0;
    end;
    if decoded == TileOperation_TSELS then
        // Scalar-false precedes the GPR mask; PredicateCell form has no GPR select mask.
        return (1 + (if _BundleTileBindings[[0]].source1_valid then 0
                    else BundleExecutionMaskGPRWordCount(operation)))
            as integer {0..5};
    end;
    if decoded == TileOperation_TGPR2T then return 4; end;
    return BundleOperationGPRInputCount(operation) as integer {0..5};
end;

readonly func BundleExecutionMaskGPRSourceSelector(
    slot: integer {0..5}) => Reg5Selector
begin
    if slot < 3 then
        case slot of
            when 0 => return _BundleScalarBindings[[0]].source0;
            when 1 => return _BundleScalarBindings[[0]].source1;
            when 2 => return _BundleScalarBindings[[0]].source2;
        end;
    end;
    case slot - 3 of
        when 0 => return _BundleScalarBindings[[1]].source0;
        when 1 => return _BundleScalarBindings[[1]].source1;
        when 2 => return _BundleScalarBindings[[1]].source2;
    end;
    unreachable;
end;

readonly func BundleExecutionMaskGPRBindingSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    let source_layout_owns_domain = BundleCubeTransportSelected() || decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS || decoded == TileOperation_TCVT || decoded == TileOperation_TSEL || decoded == TileOperation_TSELS;
    let execution_mask_layout = if source_layout_owns_domain then BundleExecutionMaskCoordinateLayout(operation) else CurrentBundleTileLayout();
    if !TileOperationExecutionMaskEligible(operation) || (execution_mask_layout != TileLayout_CUBE_M16 && execution_mask_layout != TileLayout_CUBE_M32) then return FALSE; end;
    let operation_sources = BundleExecutionMaskOperationGPRSourceCount(operation);
    let mask_words = BundleExecutionMaskGPRWordCount(operation);
    let total_sources = operation_sources + mask_words;
    if total_sources > 6 || !_BundleScalarBindings[[0]].valid then
        return FALSE;
    end;
    let uses_second = total_sources > 3;
    if _BundleScalarBindings[[1]].valid != uses_second ||
       _BundleScalarBindings[[0]].execution_mask_present == uses_second ||
       (uses_second &&
        !_BundleScalarBindings[[1]].execution_mask_present) then
        return FALSE;
    end;
    if (TileOperationOfIndex(operation) == TileOperation_TCMP ||
        TileOperationOfIndex(operation) == TileOperation_TCMPS) then
        if _BundleScalarBindings[[0]].destination >= PTO_ABSOLUTE_GPR_COUNT ||
           (uses_second && _BundleScalarBindings[[1]].destination != 0) then
            return FALSE;
        end;
    elsif _BundleScalarBindings[[0]].destination != 0 ||
          (uses_second && _BundleScalarBindings[[1]].destination != 0) then
        return FALSE;
    end;
    for slot = 0 to 5 looplimit 6 do
        let selector = BundleExecutionMaskGPRSourceSelector(slot);
        if slot < total_sources then
            if selector >= PTO_ABSOLUTE_GPR_COUNT then return FALSE; end;
        elsif selector != 0 then
            return FALSE;
        end;
    end;
    return TRUE;
end;

pure func BundleOperationGPRInputSlot(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    field: TileOperandField) => integer {0..5}
begin
    var slot: integer {0..5} = 0;
    if TileOperandPresent(operation, TileOperand_address) then
        if field == TileOperand_address then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        if field == TileOperand_scalar0 then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        if field == TileOperand_diagonal then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        if field == TileOperand_flag0 then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    return 3;
end;

readonly func BundleOperationGPRInputSelector(
    slot: integer {0..2}) => Reg5Selector
begin
    if !_BundleScalarBindings[[0]].valid then return 0; end;
    case slot of
        when 0 => return _BundleScalarBindings[[0]].source0;
        when 1 => return _BundleScalarBindings[[0]].source1;
        when 2 => return _BundleScalarBindings[[0]].source2;
    end;
    unreachable;
end;

readonly func BundleOperationGPRBindingValuesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) then
            return FALSE;
        end;
    end;
    if decoded == TileOperation_TCMP ||
       decoded == TileOperation_TCMPS ||
       decoded == TileOperation_TSEL ||
       decoded == TileOperation_TSELS then
        return TRUE;
    end;
    if decoded == TileOperation_TGPR2T then
        if _BundleScalarBindings[[0]].execution_mask_present ||
           _BundleScalarBindings[[1]].execution_mask_present then
            return TRUE;
        end;
        if !_BundleScalarBindings[[0]].valid ||
           !_BundleScalarBindings[[1]].valid ||
           _BundleScalarBindings[[0]].destination != 0 ||
           _BundleScalarBindings[[1]].destination != 0 ||
           _BundleScalarBindings[[0]].source_count != 3 ||
           _BundleScalarBindings[[1]].source_count != 1 ||
           _BundleScalarBindings[[1]].source1 != 0 ||
           _BundleScalarBindings[[1]].source2 != 0 ||
           _BundleScalarBindings[[0]].source0 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[0]].source1 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[0]].source2 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[1]].source0 >= PTO_ABSOLUTE_GPR_COUNT then
            return FALSE;
        end;
        return TRUE;
    end;
    if decoded == TileOperation_TCI &&
       (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
        CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
        // CUBE TCI uses source1 as packed raw Step2D, not RowMajor direction.
        if !_BundleScalarBindings[[0]].valid ||
           _BundleScalarBindings[[0]].source0 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[0]].source1 >= PTO_ABSOLUTE_GPR_COUNT then
            return FALSE;
        end;
        let participation_mask = _BundleTileBindings[[0]].pe_mask;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            if participation_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                let step2d = ReadPEAbsoluteGPROperand(
                    pe as MemoryAgentId, _BundleScalarBindings[[0]].source1);
                let row_step = SInt(step2d[63:32]);
                let column_step = SInt(step2d[31:0]);
                if (row_step != -1 && row_step != 0 && row_step != 1) ||
                   (column_step != -1 && column_step != 0 && column_step != 1) then
                    return FALSE;
                end;
            end;
        end;
        return TRUE;
    end;
    if TileOperationExecutionMaskEligible(operation) &&
       (_BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present) then
        if TileOperandPresent(operation, TileOperand_flag0) then
            let slot = BundleOperationGPRInputSlot(
                operation, TileOperand_flag0);
            let raw = ReadScalarRegisterOperand(
                BundleExecutionMaskGPRSourceSelector(
                    slot as integer {0..5}));
            let value = UInt(raw);
            if value != 0 && value != 1 then return FALSE; end;
        end;
        if TileOperandPresent(operation, TileOperand_diagonal) then
            let slot = BundleOperationGPRInputSlot(
                operation, TileOperand_diagonal);
            let raw = ReadScalarRegisterOperand(
                BundleExecutionMaskGPRSourceSelector(
                    slot as integer {0..5}));
            let value = SInt(raw);
            if value < -65535 || value > 65535 then return FALSE; end;
        end;
        return TRUE;
    end;
    if _BundleScalarBindings[[1]].valid then return FALSE; end;
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    let input_count = BundleOperationGPRInputCount(operation);
    if input_count > 3 then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        let slot = BundleOperationGPRInputSlot(operation, TileOperand_flag0);
        let raw = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(slot as integer {0..2}));
        let value = UInt(raw);
        if value != 0 && value != 1 then return FALSE; end;
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        let slot = BundleOperationGPRInputSlot(operation, TileOperand_diagonal);
        let raw = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(slot as integer {0..2}));
        let value = SInt(raw);
        if value < -65535 || value > 65535 then return FALSE; end;
    end;
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid then
        var post_slot: integer {0..5} = 0;
        if TileOperandPresent(operation, TileOperand_address) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_scalar0) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_diagonal) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_flag0) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;

        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    post_slot as integer {0..2}));
            if !BundleFPATRQuantParameterWordLegal(
                   _BundleFixedPointAttributes.pre_quant_mode, raw) then
                return FALSE;
            end;
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    post_slot as integer {0..2}));
            if !BundleFPATRReluParameterWordLegal(raw) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func BundleOperationScalarBindingSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TEXPDIF &&
       !_BundleScalarBindings[[0]].execution_mask_present &&
       !_BundleScalarBindings[[1]].execution_mask_present then
        return !_BundleScalarBindings[[0]].valid &&
               !_BundleScalarBindings[[1]].valid;
    end;
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        return BundleExecutionMaskGPRBindingSchemaLegal(operation);
    end;
    if decoded == TileOperation_TCI &&
       (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
        CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
        // CUBE TCI has two absolute selectors and explicit zero source2/destination.
        return _BundleScalarBindings[[0]].valid &&
               !_BundleScalarBindings[[1]].valid &&
               _BundleScalarBindings[[0]].source_count == 3 &&
               _BundleScalarBindings[[0]].destination == 0 &&
               _BundleScalarBindings[[0]].source0 < PTO_ABSOLUTE_GPR_COUNT &&
               _BundleScalarBindings[[0]].source1 < PTO_ABSOLUTE_GPR_COUNT &&
               _BundleScalarBindings[[0]].source2 == 0;
    end;
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    if BundleWeightTLOADSelected() then
        return !_BundleScalarBindings[[1]].valid &&
               _BundleScalarBindings[[0]].source_count == 3 &&
               _BundleScalarBindings[[0]].destination == 0;
    end;
    let input_count = BundleOperationGPRInputCount(operation);
    if input_count < 3 && _BundleScalarBindings[[0]].source2 != 0 then
        return FALSE;
    end;
    if input_count < 2 && _BundleScalarBindings[[0]].source1 != 0 then
        return FALSE;
    end;
    if input_count < 1 && _BundleScalarBindings[[0]].source0 != 0 then
        return FALSE;
    end;
    return _BundleScalarBindings[[0]].destination == 0;
end;
```
<!-- GENERATED-ASL-END: unit -->
