<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl -->
# TMATMUL

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl`

Multiply the left and right matrices into the destination.

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

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL | CUBE |  | 0 |  | TMATMUL |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left |
| source1 | right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL() => TileOperation
begin
    return TileOperation_TMATMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TMATMUL AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 N
B.DIM LB1 M
B.DIM LB2 Col
B.IOS Shared operand binder (optional)
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TMATMUL_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL() => TileSemanticHandler
begin
    return TileHandler_TMATMUL;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TMATMUL`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TMATMUL`
- **Effect contract:** `TMATMUL`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:left", "operand:source1:right"]`

<!-- SUPPLEMENTARY-BEGIN -->
The block uses `LB0=N`, `LB1=M`, and `LB2=Col`, where Col is the physical
power-of-two column count of the result Tile. K is the equal logical inner
dimension of the two source descriptors. M, N, and K must each be nonzero
powers of two before any destination allocation or operand effect.
<!-- SUPPLEMENTARY-END -->
