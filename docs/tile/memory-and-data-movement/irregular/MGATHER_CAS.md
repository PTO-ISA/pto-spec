<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl`

GM indexed atomic compare-and-swap with observed-old destination.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-cas-purpose role=purpose -->
## Purpose and scope

`MGATHER_CAS` is the stable reader entry point for this accepted operation. The normative `ASL` source and the generated contract sections on this page remain the only owners of architectural behavior.

<!-- PTO-READER-BLOCK: tile-mgather-cas-mechanism role=mechanism -->
## How to read the operation

Read the generated Decode and Operation sections together to locate the selected form and semantic handler. This guide adds no alternate execution algorithm.

<!-- PTO-READER-BLOCK: tile-mgather-cas-inputs role=inputs-outputs -->
## Inputs and outputs

Use the generated Operands and results table and Block composition section as the complete map of encoded and architectural roles. Do not infer an omitted operand or result from this summary.

<!-- PTO-READER-BLOCK: tile-mgather-cas-effects role=effects -->
## Effects and state

Use the generated State effects and Memory effects and ordering sections for the complete effect boundary. Executable points are evidence that the owner is exercised, not another source of meaning.

<!-- PTO-READER-BLOCK: tile-mgather-cas-constraints role=constraints -->
## Boundaries and failures

Defaults, Legality, and Exceptions below define the accepted domain and failure boundary. Reserved values and unsupported combinations remain governed by those generated sections.

<!-- PTO-READER-BLOCK: tile-mgather-cas-example role=example -->
## Non-normative usage example

Treat the generated `MGATHER_CAS` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | GM_ATOM_CAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| scalar0 | GM row stride in elements |
| source0 | indices |
| source1 | expected |
| source2 | replacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractMatches_MGATHER_CAS(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, RowStrideGPR, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_CAS;
end;
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Function 8 preserves the 0x00811181 binary carrier; mgather.cas is legal only for U16, U32, and U64.

## Legality

- mgather.cas uses raw U16/U32/U64 carriers; U128 and all non-U types are rejected.

## State effects

- Returns observed old values in the destination.

## Memory effects and ordering

### Memory effects

- One atomic compare-and-swap per valid request.

### Ordering

- Duplicate addresses serialize in implementation-defined order.

## Exceptions

- Unsupported operation/type tuples raise Fault_TileLegality before effects.

## Examples

- BSTART.MGATHER.CAS DataType; B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, RowStrideGPR, zero, ->zero; BSTOP
