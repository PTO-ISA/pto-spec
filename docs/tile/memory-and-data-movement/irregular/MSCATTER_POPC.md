<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
# MSCATTER_POPC

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl`

GM indexed mscatter.popc operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-POPC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-popc-purpose role=purpose -->
## Purpose and scope

`MSCATTER_POPC` is the stable reader entry point for this accepted operation. The normative `ASL` source and the generated contract sections on this page remain the only owners of architectural behavior.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-mechanism role=mechanism -->
## How to read the operation

Read the generated Decode and Operation sections together to locate the selected form and semantic handler. This guide adds no alternate execution algorithm.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-inputs role=inputs-outputs -->
## Inputs and outputs

Use the generated Operands and results table and Block composition section as the complete map of encoded and architectural roles. Do not infer an omitted operand or result from this summary.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-effects role=effects -->
## Effects and state

Use the generated State effects and Memory effects and ordering sections for the complete effect boundary. Executable points are evidence that the owner is exercised, not another source of meaning.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-constraints role=constraints -->
## Boundaries and failures

Defaults, Legality, and Exceptions below define the accepted domain and failure boundary. Reserved values and unsupported combinations remain governed by those generated sections.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-example role=example -->
## Non-normative usage example

Treat the generated `MSCATTER_POPC` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_POPC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_POPC | TLSU |  | 27 |  | GM_RED_POPC |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_POPC(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_POPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.POPC DataType
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_POPC() => TileSemanticHandler
begin
    return TileHandler_GM_RED_POPC;
end;
readonly func InstructionContractOperation_MSCATTER_POPC() => TileOperation
begin
    return TileOperation_MSCATTER_POPC;
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

- BSTART.MSCATTER.POPC DataType
