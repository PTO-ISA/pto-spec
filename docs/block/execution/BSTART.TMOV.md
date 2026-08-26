<!-- GENERATED FROM: asl/block/execution/BSTART.TMOV.asl -->
# BSTART.TMOV

**Normative ASL source:** `asl/block/execution/BSTART.TMOV.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tmov-purpose role=purpose -->
## What BSTART.TMOV does

`BSTART.TMOV` opens an active Block descriptor; the body supplies the attributes and bindings required before completion.

<!-- PTO-READER-BLOCK: block-bstart-tmov-mechanism role=mechanism -->
## Placement and execution mechanism

`BSTART.TMOV` must appear as the starter of its Block. Later attributes, dimensions, and bindings accumulate in the active descriptor until `BSTOP` or the next accepted `BSTART` completion boundary.

The accepted carrier uses the `L32` encoding class and resolves every displayed field before the command reads bindings or changes state.

At completion, the descriptor runs its selected Block operation only after all schema and state preflight succeeds.

<!-- PTO-READER-BLOCK: block-bstart-tmov-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `DataType` — concrete source/destination Tile type or DTYPE_NONE source-descriptor inference; `B.DATR.Layout` — Local or Shared Tile layout selection; `B.DIM.LB0/LB1/LB2` — ValidCol, ValidRow, and physical Col; `B.IOT` — Local source and/or renamed Local destination; `B.IOS` — absolute Shared source or atomic Shared destination.
- Function 2 uses one terminating `B.IOT` for a Local source and renamed Local destination; L2S uses source `B.IOT` plus destination `B.IOS`; S2L uses source `B.IOS` plus destination `B.IOT`, with matching masks.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-bstart-tmov-effects role=effects -->
## State effects and ordering

Starting the Block records the selected carrier and leaves operation execution deferred until the completion boundary.

After complete preflight and computation, every enabled output publishes as the owner-defined atomic group; successful mathematical sources remain available unless the contract explicitly consumes them.

<!-- PTO-READER-BLOCK: block-bstart-tmov-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through the owner-defined fault; no prose on this page creates an additional fault rule.

Complete schema, binding, readiness, alias, capacity, and allocation preflight precedes source snapshots and every destination publication.

<!-- PTO-READER-BLOCK: block-bstart-tmov-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.TMOV U8; B.IOT T#1, mask=1111, ->U<1>, last; BSTOP
```

The starter establishes the descriptor first; the following carriers fill its declared schema, and the final completion boundary triggers validation and operation execution.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | L32 | 32 | 0x00211181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | 0–14, 16–20, 24–28, 31 | none | 15, 21–23, 29–30 | concrete source/destination Tile type or DTYPE_NONE source-descriptor inference | Encoded zero selects FP64. |

- `bstart_tmov_32_211446509efb.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | concrete source/destination Tile type or DTYPE_NONE source-descriptor inference |
| B.DATR.Layout | Local or Shared Tile layout selection |
| B.DIM.LB0/LB1/LB2 | ValidCol, ValidRow, and physical Col |
| B.IOT | Local source and/or renamed Local destination |
| B.IOS | absolute Shared source or atomic Shared destination |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmov_32_211446509efb);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local copy: BSTART.TMOV DataType; optional B.DATR Layout; optional B.DIM shape; one terminating B.IOT binds one Local source and one newly allocated Local destination with one common PE_MASK; BSTOP commits.
Canonical Shared TMOV: Function 2 uses one Local source B.IOT and one Shared destination B.IOS, or one Shared source B.IOS and one Local destination B.IOT; B.SUBVIEW and B.ASSEMBLE provide the explicit source/destination ranges.
Function 13 GMOV remains the distinct peer-Local operation.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMOV.asl -->
```asl
// BSTART.TMOV accepts DTYPE_NONE (encoded 31). When neither B.DATR nor BSTART
// contributes a concrete type, Local/Shared TMOV inherits the bound source
// descriptor type. DTYPE_NONE is never installed in a tile descriptor.
readonly func InstructionContractHandler_BSTART_TMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TMOV()
    => TileOperation
begin
    return TileOperation_TMOV;
end;

pure func InstructionContractStartsTileBundle_BSTART_TMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Concrete DataType codes explicitly select the transfer type. DTYPE_NONE infers the type from the bound source descriptor; failure to resolve a concrete source type rejects before destination effects. Optional B.DATR omission retains NORM layout.
- Omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from an allocated source descriptor. An unallocated Shared EXTRACT source defaults them to 1, 1, and ValidCol.
- PE_MASK=0000 is a strict no-op before source reads, destination allocation, publication checks, faults, or binding consumption.

## Legality

- DataType accepts the 25 concrete TileDataType codes and code 31 DTYPE_NONE for source-descriptor inference; codes 15, 21..23, and 29..30 are reserved.
- Function 2 accepts Local-to-Local and canonical Local/Shared or Shared/Local TMOV schemas. A Shared destination with multiple participating PEs requires B.ASSEMBLE; a single-PE no-assemble writer publishes the whole parent.
- B.SUBVIEW is the source-range modifier and B.ASSEMBLE is the destination-generation modifier. Shared source legality requires hardware-maintained whole-parent readiness and publication.
- Function 13 GMOV remains accepted and unchanged. Other Shared movement function encodings are reserved and raise Fault_IllegalInstruction.
- The source and destination descriptors agree on capacity, DataType, Layout, physical Col, and completed valid shape. Local sources persist; Local destinations are renamed and published only after successful preflight.

## State effects

- Function 2 Local-to-Local copies Local payload and definedness into one renamed Local destination while preserving the Local source.
- A canonical Shared destination performs one whole-parent publication for a single-PE writer or an atomic B.ASSEMBLE generation at LAST. Shared source operations never modify Shared state.
- Shared source operations wait/no-op before payload access when whole-parent readiness or publication is absent.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete role, mask, size, descriptor, shape, data-type, layout, readiness, and allocation preflight precedes every payload, publication, or destination effect.
- Each successful Shared destination update commits its selected payload and metadata atomically; INSERT leaves publication false, while PUBLISH may establish it after completeness. A Shared source read is read-only.

## Exceptions

- Reserved DataType, unsupported Layout, malformed or unterminated binding schema, role/size/mask mismatch, incompatible descriptor, incomplete B.ASSEMBLE.LAST, unpublished Shared source, allocation failure, or shape mismatch rejects before destination effects.
- A Shared source is hardware-waiting/no-effect until the complete parent is ready and published; no undefined Shared payload is consumed.

## Examples

- BSTART.TMOV U8; B.IOT T#1, mask=1111, ->U<1>, last; BSTOP
- BSTART.TMOV U8; B.IOT T#1, mask=0001, last; B.IOS mask=0001, ->S7<9>; BSTOP
- BSTART.TMOV U8; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; B.IOT mask=0011, ->T<7>, last; BSTOP
