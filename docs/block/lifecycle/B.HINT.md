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
## What B.HINT does

`B.HINT` attaches advisory information to a block. A block (also called a bundle) opens with a block-start command, collects configuration from header commands, runs its body, and commits as one unit. `B.HINT` has two 32-bit forms:

- The ordinary form carries branch, temperature, and prefetch hints for the active block.
- The `TRACE` form marks a trace boundary. It is itself a block start: it opens a new, empty fall-through block.

<!-- PTO-READER-BLOCK: block-b-hint-mechanism role=mechanism -->
## Placement and mechanism

The ordinary form is a header command. It is legal while a block is active and still in its header phase, before the first body instruction. At most one hint may belong to a block.

The `TRACE` form follows the block-start rules in [start dispatch](../model/dispatch/start.md). If a block is active, it first commits that block with the `TRACE` address as the fall-through continuation. If that commit faults, the fault stands and no trace block opens. If the commit selects a different PC, the `TRACE` was on a path the program did not take, and it changes no hint or trace state. Otherwise, and also when no block was active, it opens a standard block whose transfer is fall-through and records the boundary kind.

Design point: an installed `TRACE` does not complete its new block. That block ends like any other, at `BSTOP` or the next block start.

<!-- PTO-READER-BLOCK: block-b-hint-inputs role=inputs-outputs -->
## Encoded fields

Ordinary form (bits `14:0` are `0x033`, bit 19 is zero):

- `V`, bit 15: branch-hint validity. 0 means no branch hint.
- `L/UL`, bit 16: when `V` is 1, 0 means unlikely (fall-through) and 1 means likely (taken).
- `temp`, bits `18:17`: temperature. 0 is none, 1 is cool, 2 is warm, 3 is hot.
- `prefetch_size`, bits `31:20`: the number of cache lines to prefetch, starting with the line that holds the current block instruction. 0 requests no prefetch.

`TRACE` form: bits `14:0` are `0x1033`, and bit 15 is `B/E`. 0 means `TRACE.begin` and 1 means `TRACE.end`. All other bits are zero.

Design point: omitting `B.HINT` and encoding an all-zero ordinary hint both give no guidance. They still differ: an explicit hint occupies the block's single hint slot, so a later ordinary `B.HINT` in the same block is rejected.

<!-- PTO-READER-BLOCK: block-b-hint-effects role=effects -->
## State effects

A successful `B.HINT` records its fields as pending state of the active block, saves the raw instruction in `_LastBundleHintPayload`, and increments the non-functional hint epoch. The hint is cleared with the rest of the header state when the block commits.

Design point: the hint never changes a functional result. In the current ASL, the recorded hint is cleared, reset, and saved and restored with the trap context. Apart from the one-hint check, no execution or commit rule reads the branch, temperature, prefetch, or trace fields. A program therefore behaves the same with or without the hint.

`B.HINT` has no memory effect. The ordinary form advances `TPC` to the next instruction. An installed `TRACE` moves `TPC` to the instruction after itself through the new block's start.

<!-- PTO-READER-BLOCK: block-b-hint-constraints role=constraints -->
## Legality and fault boundary

An ordinary `B.HINT` with no active block, after the body has begun, or when the block already has a hint raises `Fault_BundleControl` before any hint state changes. The first hint stays in place.

A `TRACE` hint also sets the hint slot of the block it opens. An ordinary `B.HINT` inside a trace block is therefore rejected as a duplicate.

Design point: rejecting the second hint, rather than replacing the first, keeps the recorded hint equal to the one the header first stated. The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-b-hint-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.HINT {BR.likely, TEMP.hot, 64}
```

In the header of an active block, this hint sets `V` to 1, `L/UL` to 1, `temp` to 3, and `prefetch_size` to 64. The encoded word is `0x00000033 | 1<<15 | 1<<16 | 3<<17 | 64<<20 = 0x04078033`. A second `B.HINT` in the same header raises `Fault_BundleControl`. By contrast, `B.HINT TRACE.begin` (`0x00001033`) placed after a fall-through block commits that block and opens a new empty block at its own address.
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
