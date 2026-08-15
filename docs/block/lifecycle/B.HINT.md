<!-- GENERATED FROM: asl/block/lifecycle/B.HINT.asl -->
# B.HINT

**Normative ASL source:** `asl/block/lifecycle/B.HINT.asl`

Records one optional per-block branch, temperature, prefetch-size, or trace-boundary hint without changing functional results.

## Normative identity {#PTO-INST-BLOCK-B-HINT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}
B.HINT TRACE.{begin, end}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_hint_32_69d942ff1583 | L32 | 32 | 0x00000033 / 0x00087fff | [] |
| b_hint_32_f7d01d734925 | L32 | 32 | 0x00001033 / 0xffff7fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_hint_32_69d942ff1583 | L/UL | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_hint_32_69d942ff1583 | V | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |
| b_hint_32_69d942ff1583 | prefetch_size | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| b_hint_32_69d942ff1583 | temp | 2 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":2}] |
| b_hint_32_f7d01d734925 | B/E | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_hint_32_69d942ff1583 | L/UL | 1 | 0–1 | none | none | when V=1, 0 unlikely/fallthrough and 1 likely/taken | unlikely branch / likely fallthrough when V is one |
| b_hint_32_69d942ff1583 | V | 1 | 0–1 | none | none | branch-hint validity: 0 invalid, 1 valid | branch hint invalid; implementation predicts normally |
| b_hint_32_69d942ff1583 | prefetch_size | 12 | 0–4095 | none | none | number of cache lines to prefetch beginning with the cache line containing the current block instruction | no cache-line prefetch |
| b_hint_32_69d942ff1583 | temp | 2 | 0–3 | none | none | temperature: 0 none, 1 cool, 2 warm, 3 hot | none |
| b_hint_32_f7d01d734925 | B/E | 1 | 0–1 | none | none | trace boundary: 0 begin, 1 end | TRACE.begin |

## Operands and results

| Field | Architectural role |
| --- | --- |
| V | branch-hint validity: 0 invalid, 1 valid |
| L/UL | when V=1, 0 unlikely/fallthrough and 1 likely/taken |
| temp | temperature: 0 none, 1 cool, 2 warm, 3 hot |
| prefetch_size | number of cache lines to prefetch beginning with the cache line containing the current block instruction |
| B/E | trace boundary: 0 begin, 1 end |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractMatches_B_HINT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_hint_32_69d942ff1583) ||
           (operation == CommandOperation_b_hint_32_f7d01d734925);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Ordinary form: optional once after BSTART and before the block body.
TRACE form: acts as a block start and must later be terminated by BSTOP or the next BSTART.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractHandler_B_HINT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleHint;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- An ordinary block may omit B.HINT; omission supplies no branch, temperature, or prefetch guidance.
- For the ordinary form V=0 disables branch guidance, L/UL=0 denotes unlikely/fallthrough, temp=0 denotes none, and prefetch_size=0 requests no cache-line prefetch.
- For TRACE, B/E=0 denotes begin and B/E=1 denotes end.

## Legality

- An ordinary B.HINT is legal only after BSTART and before the block body, and at most one B.HINT may belong to that block header.
- A second ordinary B.HINT raises Illegal Block Exception before replacing the first hint.
- B.HINT TRACE is a special block-start operation. It first retires any active predecessor block under the normal next-BSTART rule, then opens a new empty fallthrough block.

## State effects

- Decode and retain the selected hint fields as pending state of the active block and increment the non-functional hint epoch.
- TRACE.begin or TRACE.end opens an empty block and records its boundary kind; it does not complete that block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- An ordinary B.HINT outside an active block header or a duplicate ordinary B.HINT raises Illegal Block Exception before hint state changes.
- If TRACE cannot retire an active predecessor block, the predecessor fault is preserved and the trace block is not opened.

## Examples

- B.HINT {BR.likely, TEMP.hot, 64}
- B.HINT TRACE.begin

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
