<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
# TFMA

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl`

Compute a fused elementwise left-times-right plus addend result.

## Normative identity {#PTO-INST-TILE-TFMA}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TFMA <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFMA | TEPL | 0x01C | 28 | 0 | TFMA |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | multiplicand-left |
| source1 | multiplicand-right |
| source2 | addend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TFMA, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;

func InstructionContractElement_TFMA(
    addend: Word, left: Word, right: Word,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType) => Word
begin
    return TileProfileMatrixAccumulate(addend, left, right,
        destination_type, left_type, right_type);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TFMA`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TFMA`
- **Effect contract:** `TFMA`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:multiplicand-left", "operand:source1:multiplicand-right", "operand:source2:addend"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
