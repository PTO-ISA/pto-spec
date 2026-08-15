<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl -->
# TMATMUL_MX_BIAS

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl`

Multiply scaled matrices and add the bias Tile.

## Normative identity {#PTO-INST-TILE-TMATMUL-MX-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_MX_BIAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_MX_BIAS | CUBE |  | 5 |  | TMATMUL_MX_BIAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left |
| source1 | row-scale |
| source2 | right |
| source3 | column-scale |
| source4 | bias |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX_BIAS()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMULMX.BIAS AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)
B.DIM LB0 M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; executing mask 1111)
B.IOT ordered Local mathematical sources: A matrix, optional A scale, B matrix, optional B scale, 1xN Bias
B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl -->
```asl
readonly func InstructionContractCubeFunction_TMATMUL_MX_BIAS()
    => integer {0..31}
begin
    return 5;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_MX_BIAS()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_MX_BIAS(
    destination: TileIndex,
    left: TileIndex,
    row_scale: TileIndex,
    right: TileIndex,
    column_scale: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_BIAS(
        destination,
        left,
        row_scale,
        right,
        column_scale,
        bias);
end;

readonly func InstructionContractHandler_TMATMUL_MX_BIAS()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.

## Legality

- The carrier selects exactly CUBE Function 5 and TileOperation_TMATMUL_MX_BIAS.
- Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. Bias is one Local row-major 1xN accumulator-type source. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply scaled matrices and add the bias Tile.
- After complete preflight, execute TMATMUL_MX_BIAS with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TMATMULMX.BIAS AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; executing mask 1111); B.IOT ordered Local mathematical sources: A matrix, optional A scale, B matrix, optional B scale, 1xN Bias; B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
