<!-- GENERATED FROM: asl/block/execution/BSTART.STD.asl -->
# BSTART.STD

**Normative ASL source:** `asl/block/execution/BSTART.STD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-std-purpose role=purpose -->
## What BSTART.STD contributes

`BSTART.STD` opens a Standard block. A block (also called a bundle) is a run of header commands and scalar body instructions that ends at a commit boundary: `BSTOP` or the next `BSTART`. A Standard block runs no Tile operation. Its job is control flow: it records where the program continues when the block commits.

The mnemonic has six accepted 32-bit forms: `FALL`, `DIRECT`, `COND`, `CALL`, `IND`, and `RET`. Bits `14:12` of the match value select the form (`1`, `2`, `3`, `4`, `5`, and `7`), and `FALL`, `DIRECT`, `COND`, and `CALL` carry a signed 17-bit `simm17` in bits `31:15`.

<!-- PTO-READER-BLOCK: block-bstart-std-mechanism role=mechanism -->
## Placement and mechanism

The dispatcher runs [bundle start dispatch](../model/dispatch/start.md) for every form. It computes the candidate target first:

- `FALL` uses the fallthrough address, the `BSTART` address plus 4.
- `DIRECT`, `COND`, and `CALL` use the `BSTART` address plus `simm17` shifted left by 1.
- `IND` uses the `BARG.BPCN` of the block that is about to retire.
- `RET` uses `_ReturnAddress`.

Only then does it commit an active predecessor, and it opens the new block only if that commit selected this `BSTART` address as the next `TPC`. [Begin](../model/lifecycle/begin.md) then writes `BARG` with block kind Standard, the transfer type, the target in `BPCN`, and `taken`, and moves `TPC` to the next instruction.

Design point: `BSTART.STD` never jumps when it executes. The target waits in `BARG.BPCN` until commit, where `BARGCommitPC` selects it. A body `SETC.TGT` may still replace `BPCN`, and a body `SETC` condition sets `taken` for `COND`, so the final decision is made once, after the whole block has run.

Design point: `IND` and `RET` read their target before the predecessor commits. `IND` keeps a snapshot of the retiring `BPCN`, because that commit resets `BARG`; `RET` reads `_ReturnAddress` at the same point.

<!-- PTO-READER-BLOCK: block-bstart-std-inputs role=inputs-outputs -->
## Operands and header roles

- `simm17` is a signed halfword displacement. The byte offset is `simm17` times 2, so the reach is from -131072 to +131070 bytes relative to the `BSTART`.
- `FALL` must encode `simm17=0`. Nonzero values are extension-reserved.
- `IND` and `RET` have no operand field; their targets come from architectural state.
- `CALL` also records a return target, the fallthrough address, in `_ReturnAddress` and GPR 10.

Standard blocks install no Tile descriptor, so no Tile operation consumes a `B.DIM`, `B.DATR`, or Tile binding in their header.

<!-- PTO-READER-BLOCK: block-bstart-std-effects role=effects -->
## Pending state and completion

A successful `BSTART.STD` sets `BPC` to its own address, sets `BARG` block type Standard, records the transfer type and the candidate `BPCN`, and sets `taken` to false only for `COND`. Header and body instructions then execute at the sequential PC.

At commit, `BARG` selects `BPCN` for `DIRECT`, `CALL`, `IND`, and `RET`, and for `COND` only when `taken` is set. `FALL`, and `COND` with `taken` false, continue at the sequential continuation. The form has no memory effect.

<!-- PTO-READER-BLOCK: block-bstart-std-constraints role=constraints -->
## Legality and fault boundary

These checks run before the predecessor commits, so a rejected `BSTART.STD` leaves the active predecessor and its continuation in place:

- A nonzero `FALL` payload is not a legal operand value and raises `Fault_IllegalInstruction`.
- `IND` with no active Standard or Floating block to retire raises `Fault_BundleControl`, because only those kinds carry a candidate `BPCN`.
- A target with bit 0 set raises `Fault_InstructionPC`.

Design point: a PC-relative target is always even, because it is an even `BSTART` address plus a displacement shifted left by 1. The odd-target check therefore matters in practice for `IND` and `RET`, whose targets come from state.

If the predecessor commit fails, or selects a different next PC, no Standard block is installed and the predecessor's outcome stays authoritative.

<!-- PTO-READER-BLOCK: block-bstart-std-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.STD COND, <label>
```

Suppose this `BSTART.STD COND` sits at `0x1000` and `<label>` is `0x1040`. The assembler encodes `simm17 = 0x20`, and the instruction word is `0x00103001`. After begin, `BPC` is `0x1000`, `BPCN` is `0x1040`, `taken` is false, and `TPC` is `0x1004`. If a body `SETC` sets `taken` and a 4-byte `BSTOP` at `0x1010` commits, `TPC` becomes `0x1040`. If `taken` stays false, `TPC` becomes `0x1014`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.STD COND, <label>
BSTART.STD FALL
BSTART.STD RET
BSTART.STD IND
BSTART.STD DIRECT, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | L32 | 32 | 0x00003001 / 0x00007fff | [] |
| bstart_std_32_441ad677fffe | L32 | 32 | 0x00001001 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |
| bstart_std_32_816dfa76cc4a | L32 | 32 | 0x00007001 / 0xffffffff | [] |
| bstart_std_32_986b7ee2cf6a | L32 | 32 | 0x00005001 / 0xffffffff | [] |
| bstart_std_32_c1de85e06878 | L32 | 32 | 0x00002001 / 0x00007fff | [] |
| bstart_std_32_b05390d367cf | L32 | 32 | 0x00004001 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_441ad677fffe | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_c1de85e06878 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_b05390d367cf | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_441ad677fffe | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_c1de85e06878 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_b05390d367cf | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_std_32_441ad677fffe.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_std_32_1ef99c4cedcb) ||
           (operation == CommandOperation_bstart_std_32_441ad677fffe) ||
           (operation == CommandOperation_bstart_std_32_816dfa76cc4a) ||
           (operation == CommandOperation_bstart_std_32_986b7ee2cf6a) ||
           (operation == CommandOperation_bstart_std_32_b05390d367cf) ||
           (operation == CommandOperation_bstart_std_32_c1de85e06878);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.STD retires any active predecessor block, then opens one standard block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_STD()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART_STD()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.STD FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, CALL, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes STD; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no standard block is installed.

## Examples

- BSTART.STD FALL
- BSTART.STD DIRECT, target
- BSTART.STD COND, target
- BSTART.STD IND
- BSTART.STD RET
