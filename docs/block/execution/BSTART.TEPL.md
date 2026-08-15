<!-- GENERATED FROM: asl/block/execution/BSTART.TEPL.asl -->
# BSTART.TEPL

**Normative ASL source:** `asl/block/execution/BSTART.TEPL.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TEPL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.TEPL Mode, Function, DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

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
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | 0–3 | none | none | execution mode selector | Encoded zero supplies numeric zero for the execution mode selector. |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | 0–31 | none | none | tile operation function selector | Encoded zero supplies numeric zero for the tile operation function selector. |

- `bstart_tepl_32_d022db6dacb3.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |
| Mode | execution mode selector |
| Function | tile operation function selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TEPL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tepl_32_d022db6dacb3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL is the unchanged Mode:Function carrier. It retires any active predecessor, installs one Tile-element block descriptor, and accepts either the VEC or SFU operation assigned to that selector.
BSTART.TEPL remains accepted compatibility input, but canonical assembly and disassembly select BSTART.VEC or BSTART.SFU from the operation's execution engine.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TEPL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractAcceptsEngineAlias_BSTART_TEPL(
    engine: TileExecutionEngine) => boolean
begin
    return TileEngineHasCanonicalBundleStartAlias(engine);
end;

pure func InstructionContractAcceptsTileOperation_BSTART_TEPL(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_TEPL, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No operand field is omitted; every encoded field has the value carried by the selected form.

## Legality

- Mode:Function is a seven-bit selector with Mode in bits 6:5 and Function in bits 4:0.
- Only assigned TEPL-carried operations are legal; unassigned selector holes reject before effects.
- DataType accepts 0..14, 16..20, and 24..28; 15, 21..23, and 29..31 are reserved.
- BSTART.TEPL is compatibility input only; canonical output uses the operation's VEC or SFU alias.

## State effects

- After successful predecessor retirement, installs the selected Tile-element descriptor and a BARG whose BlockType denotes the Tile-element block.
- The selected operation executes only when BSTOP or the next BSTART commits the completed block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Carrier field, selector, operation, engine, and descriptor legality precede predecessor retirement and BARG publication.

## Exceptions

- Reserved DataType codes, unassigned Mode:Function selectors, non-TEPL operations, or invalid descriptors raise before predecessor retirement or new BARG effects.
- An accepted selector whose operation is not assigned to VEC or SFU is illegal for this carrier.

## Examples

- BSTART.TEPL 0, 0, FP32

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
