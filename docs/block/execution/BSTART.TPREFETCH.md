<!-- GENERATED FROM: asl/block/execution/BSTART.TPREFETCH.asl -->
# BSTART.TPREFETCH

**Normative ASL source:** `asl/block/execution/BSTART.TPREFETCH.asl`

Prefetches one typed, strided GM rectangle for each of the four PEs without a Tile destination.

## Normative identity {#PTO-INST-BLOCK-BSTART-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tprefetch-purpose role=purpose -->
## What BSTART.TPREFETCH does

`BSTART.TPREFETCH` opens an active Block descriptor; the body supplies the attributes and bindings required before completion.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-mechanism role=mechanism -->
## Placement and execution mechanism

`BSTART.TPREFETCH` must appear as the starter of its Block. Later attributes, dimensions, and bindings accumulate in the active descriptor until `BSTOP` or the next accepted `BSTART` completion boundary.

The accepted carrier uses the `L32` encoding class and resolves every displayed field before the command reads bindings or changes state.

At completion, the descriptor runs its selected Block operation only after all schema and state preflight succeeds.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `DataType` — prefetched element data type; `B.IOR.RegSrc0` — each PE's private-GPR GM base; `B.IOR.RegSrc1` — each PE's private-GPR logical row stride in elements; `B.DIM.LB0` — ValidCol; `B.DIM.LB1` — ValidRow; `B.DIM.LB2` — physical Col.
- The header may contain `B.DATR`, `B.DIM`, and `B.IOR`; `B.IOT` and `B.IOS` are forbidden because TPREFETCH has no Tile or Shared binding or destination.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-effects role=effects -->
## State effects and ordering

Starting the Block records the selected carrier and leaves operation execution deferred until the completion boundary.

After complete preflight and computation, every enabled output publishes as the owner-defined atomic group; successful mathematical sources remain available unless the contract explicitly consumes them.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through the owner-defined fault; no prose on this page creates an additional fault rule.

Complete schema, binding, readiness, alias, capacity, and allocation preflight precedes source snapshots and every destination publication.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.TPREFETCH FP16; B.DIM zero, 64, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 64, ->LB2; B.IOR zero, a0; BSTOP
```

The starter establishes the descriptor first; the following carriers fill its declared schema, and the final completion boundary triggers validation and operation execution.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TPREFETCH DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | L32 | 32 | 0x00311181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | prefetched element data type | Encoded zero selects FP64. |

- `bstart_tprefetch_32_d5f83e5aadf6.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | prefetched element data type |
| B.IOR.RegSrc0 | each PE's private-GPR GM base |
| B.IOR.RegSrc1 | each PE's private-GPR logical row stride in elements |
| B.DIM.LB0 | ValidCol |
| B.DIM.LB1 | ValidRow |
| B.DIM.LB2 | physical Col |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TPREFETCH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tprefetch_32_d5f83e5aadf6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TPREFETCH DataType; optional B.DATR Layout; optional B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col; optional B.IOR base,row_stride; BSTOP
B.IOT and B.IOS are not members of a TPREFETCH block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TPREFETCH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TPREFETCH()
    => TileOperation
begin
    return TileOperation_TPREFETCH;
end;

pure func InstructionContractStartsTileBundle_BSTART_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit and B.DATR omission selects NORM layout.
- Omitted LB0 and LB1 each default to one; omitted LB2 defaults to resolved ValidCol.
- Omitted B.IOR supplies base zero and row stride equal to resolved Col independently for every PE. Explicit zero selectors read the architectural zero GPR and therefore supply actual zero values.

## Legality

- bstart_tprefetch_32_d5f83e5aadf6.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile binding.
- ValidCol and ValidRow are positive, Col is a nonzero power of two, and ValidCol does not exceed Col.

## State effects

- Starts a destination-free TLSU block whose successful architectural effects are limited to its defined typed memory accesses and ordering events.
- No Tile or Shared descriptor, allocation, payload, definedness, publication, or lifetime state changes.

## Memory effects and ordering

### Memory effects

- For every PE and every element in ValidRow x ValidCol, access GM at base + ((row * row_stride_elements + column) * element_size), with packed four-bit types using the same logical-element byte addressing as TLOAD.
- The operation produces the same typed-element load-event decomposition as TLOAD but allocates and writes no destination Tile. Cache level, placement, and retention are not architectural results.

### Ordering

- The four PE footprints are one combined preflighted block attempt; no request or event becomes effective until every address, translation, permission, and access check succeeds.
- All successful accesses participate in PTO-TSO using the block aq/rl attributes exactly as TLOAD.

## Exceptions

- Reserved DataType, unsupported Layout, explicit zero or out-of-range dimensions, non-power-of-two Col, malformed B.IOR, any B.IOT/B.IOS, or any participating-PE memory fault rejects before the first request or memory event.
- A memory fault is precise for the complete four-PE block and recovery reissues the complete combined footprint.

## Examples

- BSTART.TPREFETCH FP16; B.DIM zero, 64, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 64, ->LB2; B.IOR zero, a0; BSTOP
