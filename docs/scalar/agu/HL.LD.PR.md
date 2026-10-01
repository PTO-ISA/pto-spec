<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PR.asl -->
# HL.LD.PR

**Normative ASL source:** `asl/scalar/agu/HL.LD.PR.asl`

HL.LD.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-purpose role=purpose -->
## What `HL.LD.PR` does

`HL.LD.PR` is a `48`-bit pre-indexed load of one `8`-byte little-endian value. It builds an offset from `SrcR` and `shamt`, adds it to the `SrcL` base, reads eight bytes at the sum, publishes the `64`-bit pattern to `Dst0`, and publishes the same sum to `Dst1`.

The canonical assembly is `hl.ld.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: the effective address includes the offset, so the alignment of the sum decides whether the access is legal. An `8`-byte-aligned base with a stride that is a multiple of `8` keeps every access aligned; a stride of `4` produces an alternating pattern in which half of the iterations raise `Fault_DataAlignment` before translation.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-mechanism role=mechanism -->
## How the offset and the address are formed

`SrcR` is transformed by `SrcRType` and shifted left by the encoded `shamt`. The sum `SrcL + offset` is taken modulo `2^PTO_XLEN` and serves as both the access address and the value for `Dst1`.

`SrcL` is never written, so a published base change reaches the register file only through `Dst1`.

After the encoding checks and the address preflight pass, the handler performs one `8`-byte little-endian load and publishes the bytes unchanged to `Dst0`, then the updated base to `Dst1`.

Design point: an aligned base register can be repaired by the offset, because the sum is what the preflight tests. A base of `0x5004` with an offset of `4` produces the `8`-byte-aligned address `0x5008` and is accepted, while the same base with an offset of `2` produces `0x5006` and raises the alignment fault.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` the offset source, both `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` is `0` unchanged, `1` for `.sw` on `SrcR[31:0]`, or `2` for `.uw` on `SrcR[31:0]`; `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform. With an unchanged `SrcR` of `1`, a `shamt` of `3` gives a stride of `8`, which preserves `8`-byte alignment for any `8`-byte-aligned base.
- `Dst0` receives the loaded pattern and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: `Dst1` is an ordinary destination, so the updated base can be pushed to the `T` or `U` queue instead of written to a register. That push moves the older queue entries along, exactly as any other queue-push destination does.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-effects role=effects -->
## Effects, ordering, and completion

Both sources are read before any memory or destination effect, so aliases between `SrcR`, `SrcL`, and the destinations observe pre-instruction values. `Dst0` is published before `Dst1`.

On success one relaxed `8`-byte load event is recorded and memory bytes and reservation state are unchanged. `TPC` advances by `6` bytes after both publications, and a rejected or faulting attempt does not retire.

Design point: the written order matters when both destinations name one register: the loaded bytes are replaced by the updated base inside the same instruction. The instruction therefore cannot be used to obtain both results in one register.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, a `SrcRType` of `3` is rejected by the form constraint before any source is read, and an unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight tests the low `3` bits of the effective address, which here is the sum, and raises `Fault_DataAlignment` before translation and before the permission check. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither destination, and leaves `TPC` on the faulting instruction. Recovery recomputes the transform, the shift, the sum, and the load; because `SrcL` was never modified, the retry starts from the same base.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.ld.pr [9, 10<<<2], ->11, 9` with `SrcRType` selecting the unchanged transform, GPR9 = `0x5004`, and GPR10 = `1`.
- The offset is `1` shifted left by `2`, which is `4`. The effective address is `0x5004` plus `4`, which is `0x5008` and is `8`-byte aligned.
- GPR11 receives the `8` bytes at `0x5008` through `0x500F`, and GPR9 receives `0x5008` because `Dst1` names the base register.
- With a shift amount of `1` the address would be `0x5006`, and the instruction would raise `Fault_DataAlignment` before translation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_pr_48_7ec4111b123b | HL48 | 48 | 0x00003009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_pr_48_7ec4111b123b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_ld_pr_48_7ec4111b123b | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_pr_48_7ec4111b123b | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pr_48_7ec4111b123b | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pr_48_7ec4111b123b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ld_pr_48_7ec4111b123b | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_ld_pr_48_7ec4111b123b | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_ld_pr_48_7ec4111b123b | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_ld_pr_48_7ec4111b123b.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ld.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
