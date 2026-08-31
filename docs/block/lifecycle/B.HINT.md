<!-- GENERATED FROM: asl/block/lifecycle/B.HINT.asl -->
# B.HINT

**Normative ASL source:** `asl/block/lifecycle/B.HINT.asl`

Records one optional per-block branch, temperature, prefetch-size, or trace-boundary hint without changing functional results.

## Normative identity {#PTO-INST-BLOCK-B-HINT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-hint-purpose role=purpose -->
## What B.HINT contributes

`B.HINT` is a 32-bit block header command that records optional branch, temperature, prefetch-size, or trace-boundary hints. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-hint-mechanism role=mechanism -->
## Placement and mechanism

The ordinary hint form is optional at most once in an already active block header, after `BSTART` and before the first body instruction.

Ordinary hint fields are retained as non-functional pending metadata. The TRACE form instead behaves as a block start: it first retires an active predecessor when retirement succeeds, then opens an empty trace block and records whether the boundary is begin or end. TRACE does not complete the newly opened block by itself.

<!-- PTO-READER-BLOCK: block-b-hint-inputs role=inputs-outputs -->
## Operands and header roles

- `V` marks the branch hint valid; its exact assigned domain remains in the generated contract below.
- `L/UL` selects likely or unlikely when the hint is valid; its exact assigned domain remains in the generated contract below.
- `temp` selects the temperature hint; its exact assigned domain remains in the generated contract below.
- `prefetch_size` selects the cache-line prefetch count; its exact assigned domain remains in the generated contract below.
- `B/E` selects the trace begin or end boundary; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-hint-effects role=effects -->
## Pending state and completion

An accepted ordinary hint updates the pending hint record and hint epoch without changing body-visible data. An accepted TRACE form installs the empty trace block only after predecessor retirement; a predecessor retirement failure leaves the predecessor authoritative and opens no trace block.

<!-- PTO-READER-BLOCK: block-b-hint-constraints role=constraints -->
## Legality and fault boundary

Reserved encodings are rejected before reads or pending-state changes. Placement, duplicate, role, or completed-schema mismatches fail before body effects.

<!-- PTO-READER-BLOCK: block-b-hint-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}
```

Assume an active compatible header with no earlier conflicting `B.HINT` command. Placing `B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}` at the next header slot records this command's pending fields; it does not by itself execute the eventual body operation.
<!-- SUPPLEMENTARY-END -->

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
TRACE form: acts as a block start only when predecessor commit selects the fetched TRACE PC, and an installed trace block must later be terminated by BSTOP or the next block start.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractHandler_B_HINT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleHint;
end;

pure func InstructionContractIsBundleHint_B_HINT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTraceFormMayTerminate_B_HINT()
    => boolean
begin
    return TRUE;
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
- B.HINT TRACE is a special block-start operation. It first retires any active predecessor block and opens a new empty fallthrough block only when the committed TPC equals the fetched TRACE PC.

## State effects

- Decode and retain the selected hint fields as pending state of the active block and increment the non-functional hint epoch.
- TRACE.begin or TRACE.end opens an empty block and records its boundary kind only at a predecessor-selected boundary; skipped TRACE changes no hint state. An installed TRACE does not complete its new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Ordinary hints update the active header in place. TRACE first commits any active predecessor, verifies that its selected TPC is the fetched TRACE PC, and only then installs and records the empty trace block.

## Exceptions

- An ordinary B.HINT outside an active block header or a duplicate ordinary B.HINT raises Illegal Block Exception before hint state changes.
- If TRACE cannot retire an active predecessor block, the predecessor fault is preserved and the trace block is not opened. If predecessor commit selects another PC, TRACE changes no hint or trace state.

## Examples

- B.HINT {BR.likely, TEMP.hot, 64}
- B.HINT TRACE.begin
