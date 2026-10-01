<!-- GENERATED FROM: asl/block/execution/BSTART.SYS.asl -->
# BSTART.SYS

**Normative ASL source:** `asl/block/execution/BSTART.SYS.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-sys-purpose role=purpose -->
## What BSTART.SYS contributes

`BSTART.SYS` opens a System block. A block (also called a bundle) is a run of header commands and scalar body instructions that ends at a commit boundary: `BSTOP` or the next `BSTART`. A System block is the block kind in which system scalar operations are applicable, for example `SSRSET`, `FENCE.I`, `TLB.IALL`, and `ACRC`.

The mnemonic has one 32-bit form, `BSTART.SYS FALL`, with match value `0x00001081`. It has no transfer target and runs no Tile operation.

<!-- PTO-READER-BLOCK: block-bstart-sys-mechanism role=mechanism -->
## Placement and mechanism

[Bundle start dispatch](../model/dispatch/start.md) handles the form. Its transfer is `Fallthrough`, so the candidate target is the `BSTART` address plus 4. Dispatch commits an active predecessor first, and opens the System block only if that commit selected this `BSTART` address as the next `TPC`.

[Begin](../model/lifecycle/begin.md) then sets `BPC` to the `BSTART` address and `BARG` block type to System. For a System block it ignores the supplied transfer: it writes `BARG` transfer `Fallthrough`, `taken` false, and `BPCN` zero.

Design point: a System block has no candidate continuation, so `BARG` holds a fixed non-selecting value. At commit, `BARGCommitPC` therefore always returns the sequential continuation, and no leftover target can redirect the program.

<!-- PTO-READER-BLOCK: block-bstart-sys-inputs role=inputs-outputs -->
## Operands and header roles

- `simm17` occupies bits `31:15` and must be zero. Nonzero values are extension-reserved.
- The form has no `DataType`, selector, or target operand.

Inside the body, `SETC.TGT` cannot write a target: `BundleCommitTargetWritable` is true only for Standard and Floating blocks, so it raises `Fault_BundleControl` in a System block.

<!-- PTO-READER-BLOCK: block-bstart-sys-effects role=effects -->
## Pending state and completion

A successful `BSTART.SYS` clears the per-bundle flags, including `_SystemBlockTerminalPending`, records `BPC`, sets the System block type, and moves `TPC` to the next instruction. The form has no memory effect.

While the block body is active, the scalar dispatcher accepts system scalar operations; outside a System block body they raise `Fault_BundleControl`. After `ACRC` sets `_SystemBlockTerminalPending`, the [top-level dispatch](../model/dispatch/top-level.md) accepts only `BSTOP` or a `BSTART` as the next block command.

At commit, the block continues at the sequential continuation.

<!-- PTO-READER-BLOCK: block-bstart-sys-constraints role=constraints -->
## Legality and fault boundary

- A nonzero `simm17` fails operand legality and raises `Fault_IllegalInstruction` before the predecessor commits.
- If the predecessor commit fails, or selects a next PC other than this `BSTART`, no System block is installed and the predecessor's outcome stays authoritative.
- A begin while a block is still active raises `Fault_BundleControl`; dispatch avoids this by committing the predecessor first.

Design point: the fixed-zero payload keeps the only encoding unambiguous. Every nonzero value stays reserved and is rejected, so a later extension can assign it without changing the meaning of existing code.

<!-- PTO-READER-BLOCK: block-bstart-sys-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.SYS FALL
```

Suppose `BSTART.SYS FALL` sits at `0x2000` and the body holds `FENCE.I` followed by a 4-byte `BSTOP` at `0x2008`. After begin, `BPC` is `0x2000`, `BARG.BPCN` is zero, and `TPC` is `0x2004`. `FENCE.I` is applicable because the body is in a System block. `BSTOP` commits with continuation `0x200C`, and because System `BARG` never selects `BPCN`, `TPC` becomes `0x200C`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | L32 | 32 | 0x00001081 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | 0 | none | 1–131071 | fixed-zero fallthrough payload; nonzero values are extension-reserved | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_sys_32_762d9d84a6d8.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | fixed-zero fallthrough payload; nonzero values are extension-reserved |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SYS retires any active predecessor block, then opens one system block whose header commands execute sequentially until BSTOP or the next BSTART.
SYS has no candidate transfer: BPCN, TYPE, and TAKEN are inapplicable and cannot select the next PC.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_SYS()
    => BundleKind
begin
    return BundleKind_System;
end;

pure func InstructionContractStartsBundle_BSTART_SYS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The encoded simm17 field is fixed to zero; nonzero values are extension-reserved.

## Legality

- Only simm17=0 is accepted; every nonzero payload is extension-reserved.

## State effects

- On success BPC records the BSTART address and BARG.BlockType becomes SYS. BPCN, TYPE, and TAKEN are inapplicable and are canonicalized to non-selecting values.
- Header execution and the eventual block continuation are sequential.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The fixed-zero payload and form legality are checked before predecessor retirement. New SYS BARG state is installed only after successful retirement.

## Exceptions

- Any nonzero simm17 in the SYS FALL family is extension-reserved and raises before predecessor retirement or new BARG effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no system block is installed.

## Examples

- BSTART.SYS FALL
