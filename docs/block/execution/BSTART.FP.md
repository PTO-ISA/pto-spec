<!-- GENERATED FROM: asl/block/execution/BSTART.FP.asl -->
# BSTART.FP

**Normative ASL source:** `asl/block/execution/BSTART.FP.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-fp-purpose role=purpose -->
## What BSTART.FP contributes

`BSTART.FP` closes the block that is active and opens the next one as a Floating block. It has six encoded spellings: `BSTART.FP FALL`, `BSTART.FP DIRECT, <label>`, `BSTART.FP COND, <label>`, `BSTART.FP CALL, <label>`, `BSTART.FP IND`, and `BSTART.FP RET`. `InstructionContractBundleKind_BSTART_FP` returns `BundleKind_Floating`, so the command selects a block kind and a transfer rule, not a Tile operation.

Only `DIRECT`, `COND`, and `CALL` carry a payload: a signed 17-bit `simm17` label displacement in instruction bits 31 to 15. `FALL` fixes that field to zero, and `IND` and `RET` have no field at all.

Design point: `BSTART.FP` and `BSTART.STD` accept the same six transfers and the same target rules, and they differ in the block kind they install, `BundleKind_Floating` (code `0001`) against `BundleKind_Standard` (code `0000`). The consequence is observable inside the new block body: the packed BARG control word returned by `LSRGET` identifier 2 carries that kind in its low four bits.

<!-- PTO-READER-BLOCK: block-bstart-fp-mechanism role=mechanism -->
## Placement and mechanism

The command is decoded, its descriptor is checked by `BundleOperationDescriptorLegal`, and the transfer is taken from the form or from a descriptor branch type. The candidate target then follows from that transfer: `FALL` continues at the next word, `DIRECT`, `COND`, and `CALL` compute `PC + 2 * simm17`, `IND` reads the retiring block's `BARG.BPCN`, and `RET` reads the architectural return address.

Only after those checks does the start commit an active predecessor through `CompleteBundleAtWithAcceptedApplicabilityRules`. The fetched `BSTART.FP` is installed only when that commit leaves the program counter at this instruction, so a `BSTART.FP` on an unselected path installs nothing.

Design point: `IND` and `RET` consume state that the predecessor still owns, namely `BARG.BPCN` and the return address, and `start.asl` snapshots both into local values before it retires that predecessor. A predecessor whose commit fails therefore cannot corrupt the continuation it selected.

<!-- PTO-READER-BLOCK: block-bstart-fp-inputs role=inputs-outputs -->
## Operands and header roles

- `simm17` is the signed 17-bit bundle target displacement in bits 31 to 15 of `DIRECT`, `COND`, and `CALL`; the byte target is `PC + 2 * simm17`, and encoded zero supplies a zero displacement.
- `FALL` carries the same field fixed to zero, so `FALL` targets the sequential word.
- `IND` and `RET` carry no encoded field; their continuation comes from the retiring block's `BARG.BPCN` and from the return address.

<!-- PTO-READER-BLOCK: block-bstart-fp-effects role=effects -->
## Pending state and completion

A successful start records the `BSTART.FP` address in `BARG.BPC`, sets `BARG.BlockType` to `BundleKind_Floating`, stores the transfer in `BARG.TYPE`, stores the candidate target in `BARG.BPCN`, and sets `BARG.TAKEN` false only for `COND`. Header execution then continues at the sequential word.

The candidate target is not yet the next program counter. `BARG.BPCN` becomes the continuation only when `BSTOP` or the next `BSTART` commits this block and `BARGSelectsBPCN` holds for the recorded transfer.

Design point: `CALL` also publishes a return address, and that address is the sequential word, because this form has no `uimm5` field to displace it; the call target stays in `BARG.BPCN`. Both publications belong to the same start transition, so a `CALL` whose applicability checks fail leaves neither a target nor a return address behind.

<!-- PTO-READER-BLOCK: block-bstart-fp-constraints role=constraints -->
## Legality and fault boundary

- Exactly `FALL`, `DIRECT`, `COND`, `CALL`, `IND`, and `RET` are accepted; a nonzero `FALL` payload, a reserved branch type, and an unsupported form raise `Fault_IllegalInstruction` before the predecessor is retired.
- `IND` without an active retiring Standard or Floating block raises `Fault_BundleControl` at the instruction, before any target or block effect.
- A computed target with the low bit set raises `Fault_InstructionPC`.
- If the predecessor commit fails, the old block and its continuation stay authoritative and no Floating block is installed.

<!-- PTO-READER-BLOCK: block-bstart-fp-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.FP CALL, target
```

`BSTART.FP CALL, target` closes the active block and opens a Floating block whose candidate continuation is `PC + 2 * simm17` and whose return address is `PC + 4`. A `BSTART.FP RET` that later closes the new block records the return address as its own candidate continuation, and `BSTART.FP IND` would take its target from the retiring block's `BARG.BPCN` instead of from an encoded displacement.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.FP RET
BSTART.FP COND, <label>
BSTART.FP IND
BSTART.FP DIRECT, <label>
BSTART.FP FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_0c671a644214 | L32 | 32 | 0x00007101 / 0xffffffff | [] |
| bstart_fp_32_58ad7954fb49 | L32 | 32 | 0x00003101 / 0x00007fff | [] |
| bstart_fp_32_7978795a29a1 | L32 | 32 | 0x00005101 / 0xffffffff | [] |
| bstart_fp_32_d00a708a81f0 | L32 | 32 | 0x00002101 / 0x00007fff | [] |
| bstart_fp_32_face4f238d84 | L32 | 32 | 0x00001101 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |
| bstart_fp_32_dd7bc8dd694c | L32 | 32 | 0x00004101 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_face4f238d84 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_dd7bc8dd694c | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_face4f238d84 | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_dd7bc8dd694c | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_fp_32_face4f238d84.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_fp_32_0c671a644214) ||
           (operation == CommandOperation_bstart_fp_32_58ad7954fb49) ||
           (operation == CommandOperation_bstart_fp_32_7978795a29a1) ||
           (operation == CommandOperation_bstart_fp_32_d00a708a81f0) ||
           (operation == CommandOperation_bstart_fp_32_dd7bc8dd694c) ||
           (operation == CommandOperation_bstart_fp_32_face4f238d84);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.FP retires any active predecessor block, then opens one FP block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_FP()
    => BundleKind
begin
    return BundleKind_Floating;
end;

pure func InstructionContractStartsBundle_BSTART_FP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.FP FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, CALL, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes FP; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no FP block is installed.

## Examples

- BSTART.FP FALL
- BSTART.FP DIRECT, target
- BSTART.FP COND, target
- BSTART.FP IND
- BSTART.FP RET
