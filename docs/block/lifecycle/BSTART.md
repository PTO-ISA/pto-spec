<!-- GENERATED FROM: asl/block/lifecycle/BSTART.asl -->
# BSTART

**Normative ASL source:** `asl/block/lifecycle/BSTART.asl`

Initializes the single BARG continuation record after any retiring block commits successfully.

## Normative identity {#PTO-INST-BLOCK-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-purpose role=purpose -->
## What BSTART does

`BSTART` opens a standard block. A block (also called a bundle) is a group of header commands and body instructions that commits as one unit at `BSTOP` or at the next block start. `BSTART` has two 32-bit forms: `BSTART DIRECT, <label>` for an unconditional transfer and `BSTART COND, <label>` for a conditional one.

`BSTART` records where the program will go when the block commits. It does not jump. The record is `BARG`, the block argument register, described in [BARG helpers](../model/state/barg.md).

<!-- PTO-READER-BLOCK: block-bstart-mechanism role=mechanism -->
## Encoding and start sequence

Both forms carry one field, `simm25`, a signed 25-bit displacement in bits `31:7`. The low seven bits select the form: `0010001` (`0x11`) is `DIRECT` and `0100001` (`0x21`) is `COND`. The candidate target is `P + (SignExtend(simm25) << 1)`, where `P` is the address of the `BSTART`. The displacement counts 2-byte units.

The [start dispatch](../model/dispatch/start.md) runs these steps in order:

1. It checks the operation descriptor and computes the candidate target. An odd target raises `Fault_InstructionPC`.
2. If a block is already active, it commits that predecessor with `P` as the fall-through continuation.
3. If the predecessor commit faults, or selects a next PC other than `P`, it stops. This `BSTART` was on a path the program did not take and is not installed.
4. It clears header state and opens the new block through [begin](../model/lifecycle/begin.md). `TPC` moves to `P + 4`, the first header command.

Design point: all checks on the new `BSTART` run before the predecessor commits. A rejected `BSTART` therefore leaves the predecessor active and unchanged.

<!-- PTO-READER-BLOCK: block-bstart-inputs role=inputs-outputs -->
## Field and BARG record

- `simm25` is the only encoded operand. It is always present; there is no omitted form.
- `DIRECT` writes `BARG.BPC = P`, `BlockType = STD`, `BPCN = target`, `TYPE = DIRECT`, and `TAKEN = 1`.
- `COND` writes the same `BPC`, `BlockType`, and `BPCN`, with `TYPE = COND` and `TAKEN = 0`.

Design point: an encoded `simm25` of zero is a real zero displacement, so `BPCN` equals `P`. A `DIRECT` block with displacement zero returns to its own `BSTART` when it commits. Zero never means "no target".

<!-- PTO-READER-BLOCK: block-bstart-effects role=effects -->
## What becomes visible, and when

`BSTART` itself performs no memory access. Any memory effects of the retiring predecessor complete before the new `BARG` is installed.

The transfer happens at commit, not at `BSTART`. A body `SETC.*` instruction may set `TAKEN`, but only inside a `COND` block, and [SETC.TGT](../../scalar/sys/SETC.TGT.md) may replace `BPCN` in a `DIRECT` block as well as in a `COND` block. `BSTOP` or the next block start then selects `BPCN` for a `DIRECT` block, and for a `COND` block only when `TAKEN` is set. Otherwise it selects the sequential address.

Design point: because the choice is deferred, a block that faults before it commits has not redirected the program. The final `BPCN` is checked again at commit, so a target changed by `SETC.TGT` is still validated before any block effect.

<!-- PTO-READER-BLOCK: block-bstart-constraints role=constraints -->
## Legality and fault boundary

- The `0x11` form is `DIRECT` only; `CALL` is not an alias. The `0x21` form is `COND` only.
- An odd computed `BPCN` raises `Fault_InstructionPC` before `BARG` changes.
- A failed predecessor commit keeps the predecessor's `BARG` and its fault, and the new `BARG` is not installed.

The generated legality, state-effect, and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-bstart-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART DIRECT, <label>
```

A `BSTART DIRECT, <label>` sits at `0x1000` and the label is at `0x2000`. The encoded `simm25` is `(0x2000 - 0x1000) >> 1 = 0x800`. After the start, `BPC` is `0x1000`, `BPCN` is `0x2000`, `TAKEN` is 1, and `TPC` is `0x1004`. The header runs from `0x1004`; the jump to `0x2000` happens when `BSTOP` commits the block. With `BSTART COND, <label>` instead, `TAKEN` starts at 0, and the block falls through unless a body `SETC.*` sets it.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART DIRECT, <label>
BSTART COND, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | L32 | 32 | 0x00000011 / 0x0000007f | [] |
| bstart_32_e11e678a32ac | L32 | 32 | 0x00000021 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |
| bstart_32_e11e678a32ac | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | 0–33554431 | none | none | 25-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_32_e11e678a32ac | simm25 | 25 | 0–33554431 | none | none | 25-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm25 | 25-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractMatches_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_32_7eb93b649748) ||
           (operation == CommandOperation_bstart_32_e11e678a32ac);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractHandler_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm25 zero is a real zero displacement, so BARG.BPCN equals the BSTART address P.

## Legality

- The low-seven-bit 0010001 form is DIRECT only; CALL is not an alias.
- The low-seven-bit 0100001 form is COND only.

## State effects

- DIRECT installs BARG.BPC=P, BlockType=STD, BPCN=P+(SignExtend(simm25)<<1), TYPE=DIRECT, TAKEN=1.
- COND installs the same BPC/BlockType/BPCN fields with TYPE=COND and TAKEN=0; SETC.* may update TAKEN and SETC.TGT may update BPCN before commit.
- Neither form selects BPCN at decode; BSTOP or the next BSTART is the continuation boundary.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the new BARG is installed; BSTART itself performs no memory access.

### Ordering

- Decode and candidate-target validation precede retiring-block commit; successful commit precedes atomic publication of the new BARG.

## Exceptions

- An odd computed BARG.BPCN raises Fault_InstructionPC before changing BARG.
- A failed retiring-block commit preserves the retiring BARG and does not install the candidate BARG.

## Examples

- BSTART DIRECT, <label>
