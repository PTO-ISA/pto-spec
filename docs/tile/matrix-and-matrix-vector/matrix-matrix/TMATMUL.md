<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl -->
# TMATMUL

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl`

Multiply A[M x K] by B[K x N] into one private FP32, S32, or U32 CUBE destination.

## Normative identity {#PTO-INST-TILE-TMATMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL | CUBE |  | 0 |  | TMATMUL |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left |
| source1 | right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL()
    => TileOperation
begin
    return TileOperation_TMATMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMUL AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)
B.DIM LB0 M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; executing mask 1111)
B.IOT ordered Local mathematical sources: A matrix, B matrix
B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl -->
```asl
readonly func InstructionContractCubeFunction_TMATMUL()
    => integer {0..31}
begin
    return 0;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL(
    destination: TileIndex,
    left: TileIndex,
    right: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL(
        destination,
        left,
        right);
end;

readonly func InstructionContractHandler_TMATMUL()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.

## Legality

- The carrier selects exactly CUBE Function 0 and TileOperation_TMATMUL.
- AType and BType must be supported ordinary Matrix types from one numeric class. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply A[M x K] by B[K x N] into one private FP32, S32, or U32 CUBE destination.
- After complete preflight, execute TMATMUL with the operand bindings listed above; destination definedness changes only as specified by that handler.

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

- BSTART.TMATMUL AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; executing mask 1111); B.IOT ordered Local mathematical sources: A matrix, B matrix; B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary

<!-- SUPPLEMENTARY-BEGIN -->
The block uses the standard matrix product dimensions `LB0=M`, `LB1=N`, and
`LB2=K`: M is the result row count, N is the result column count, and K is the
equal logical inner dimension of the two source descriptors. M, N, and K must
each be nonzero powers of two before destination allocation or operand effects.
<!-- SUPPLEMENTARY-END -->
