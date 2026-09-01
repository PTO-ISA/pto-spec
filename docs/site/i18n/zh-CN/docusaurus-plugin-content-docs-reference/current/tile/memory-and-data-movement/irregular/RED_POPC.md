<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/RED_POPC.asl -->
# RED_POPC

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/RED_POPC.asl`

GM indexed red.popc operation.

## Normative identity {#PTO-INST-TILE-RED-POPC}

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
RED_POPC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| RED_POPC | TLSU |  | 27 |  | GM_RED_POPC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/RED_POPC.asl -->
```asl
readonly func InstructionContractMatches_RED_POPC(operation: TileOperation) => boolean
begin
    return operation == TileOperation_RED_POPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.RED.POPC DataType
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/RED_POPC.asl -->
```asl
readonly func InstructionContractHandler_RED_POPC() => TileSemanticHandler
begin
    return TileHandler_GM_RED_POPC;
end;
readonly func InstructionContractOperation_RED_POPC() => TileOperation
begin
    return TileOperation_RED_POPC;
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

- BSTART.RED.POPC DataType
