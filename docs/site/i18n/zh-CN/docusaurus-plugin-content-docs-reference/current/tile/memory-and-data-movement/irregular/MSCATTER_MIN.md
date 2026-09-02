<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl -->
# MSCATTER_MIN

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl`

GM indexed mscatter.min operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-MIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MIN | TLSU |  | 20 |  | GM_RED_VALUE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |
| source1 | value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_MIN(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_MIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MIN DataType
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MIN() => TileSemanticHandler
begin
    return TileHandler_GM_RED_VALUE;
end;
readonly func InstructionContractOperation_MSCATTER_MIN() => TileOperation
begin
    return TileOperation_MSCATTER_MIN;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- GM indexed operation uses byte-displacement addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.

## State effects

- All valid requests take effect; atom forms publish observed old values.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.MSCATTER.MIN DataType
