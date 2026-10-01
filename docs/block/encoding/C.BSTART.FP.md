<!-- GENERATED FROM: asl/block/encoding/C.BSTART.FP.asl -->
# C.BSTART.FP

**Normative ASL source:** `asl/block/encoding/C.BSTART.FP.asl`

Starts a compressed FP block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-fp-purpose role=purpose -->
## What C.BSTART.FP does

`C.BSTART.FP` is the 16-bit start command for a Floating block whose continuation is not a PC-relative label. Its three forms are `C.BSTART.FP FALL`, `C.BSTART.FP IND`, and `C.BSTART.FP RET`. A block (also called a bundle) is a group of header commands and body instructions that commits as one unit at `BSTOP` or at the next block start.

The command records a candidate continuation in `BARG`, the bundle argument register, and does not jump by itself. The model pages [Bundle start dispatch](../model/dispatch/start.md) and [Begin](../model/lifecycle/begin.md) define the shared start sequence.

<!-- PTO-READER-BLOCK: block-c-bstart-fp-mechanism role=mechanism -->
## Encoding and start sequence

The command is one halfword with one field, `BrType`, in bits 13:11. The other bits are fixed by the match `0x0080` under mask `0xc7ff`. The only difference from `C.BSTART.STD` is bit 7, which selects the Floating block kind. `BrType` 1 is FALL, 5 is IND, and 7 is RET.

The candidate target depends on `BrType`:

- FALL uses the sequential address `P + 2`, where `P` is the address of the `C.BSTART.FP`.
- IND uses a snapshot of the retiring block's `BARG.BPCN`.
- RET uses a snapshot of the return-address state `_ReturnAddress`. For example, `SETRET`, call starts, and frame loads of `ra` write it together with GPR 10; an ordinary write to GPR 10 does not update it.

The target is checked for alignment before any active predecessor commits. The new Floating block opens only if the predecessor commit selected this address as the next PC. Header execution then continues at `P + 2`.

Design point: IND reads the retiring block's `BPCN` before that block commits, and keeps the value as a snapshot that the commit cannot change. A target that the predecessor left in its `BPCN`, for example through `SETC.TGT`, therefore becomes the candidate target of the new block.

<!-- PTO-READER-BLOCK: block-c-bstart-fp-inputs role=inputs-outputs -->
## Fields and BARG values

- `BrType` is always encoded. It has no omitted or default form.
- Every form installs `BARG.BPC = P` and sets `BlockType` to the Floating kind.
- FALL installs `TYPE = FALL` with `BPCN = P + 2`. `BARGSelectsBPCN` is false for FALL, so commit continues at the sequential PC.
- IND installs `TYPE = IND` with the snapshotted retiring `BPCN`. RET installs `TYPE = RET` with the snapshotted return address. Both select `BPCN` at commit.

Design point: FALL, IND, and RET start with `TAKEN = 1`; the start path sets `TAKEN` to false only for a COND transfer. `TAKEN` does not affect continuation selection for these transfer kinds, because `BARGSelectsBPCN` consults it only for COND; `LSRGET` identifier 2 still reports it in bit 7.

<!-- PTO-READER-BLOCK: block-c-bstart-fp-effects role=effects -->
## State effects and ordering

A successful start clears the previous header state, marks the new block active in its header phase, writes `BARG` and `BPC`, and takes a fresh execution-domain token. `C.BSTART.FP` performs no memory access and writes no GPR.

The installed candidate stays pending until `BSTOP` or the next block start commits the new block. A Floating block, like a Standard block, carries a candidate word: a body `SETC.TGT` may still replace `BPCN` before commit, and `LSRGET` identifier 1 can read it.

Design point: the predecessor commits before the new `BARG` is installed. If the predecessor commit fails, the predecessor stays authoritative and no Floating `BARG` is installed. If the predecessor transfers elsewhere, this command was on an unselected path and opens nothing.

<!-- PTO-READER-BLOCK: block-c-bstart-fp-constraints role=constraints -->
## Legality and fault boundary

`BrType` accepts exactly 1, 5, and 7. Codes 0, 2, 3, 4, and 6 do not decode as standalone `C.BSTART.FP` and raise `Fault_IllegalInstruction` before effects. The fused `BSTART.ICALL` form does not use this field: it is a separate 32-bit form whose indirect-call transfer is fixed by the form itself.

Design point: unlike `C.BSTART.STD`, encoded zero here has no other owner. `C.BSTOP` owns only the all-zero halfword, and bit 7 is set in every `C.BSTART.FP` pattern, so `BrType` 0 is simply reserved and rejected.

IND without an active retiring Standard or Floating block raises `Fault_BundleControl`. A System block has no candidate word, so it cannot supply an indirect target. An odd snapshotted target raises `Fault_InstructionPC`. Both faults occur before the predecessor commits.

<!-- PTO-READER-BLOCK: block-c-bstart-fp-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART.FP RET
```

`C.BSTART.FP RET` encodes `BrType = 7`, which is the halfword `0x3880`. Suppose it sits at `0x4000` and `_ReturnAddress` holds `0x5200`, for example after a `SETRET` wrote that value. The new Floating block has `BPC = 0x4000`, `BPCN = 0x5200`, and `TYPE = RET`. Header execution continues at `0x4002`, and the commit of this block continues at `0x5200`. If `_ReturnAddress` held an odd value, the command would raise `Fault_InstructionPC` before the predecessor commits.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART.FP FALL
C.BSTART.FP IND
C.BSTART.FP RET
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_fp_16_9dcef7e3a85b | C16 | 16 | 0x0080 / 0xc7ff | [{"field":"BrType","operator":"one-of","values":[1,5,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_fp_16_9dcef7e3a85b | BrType | 3 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_fp_16_9dcef7e3a85b | BrType | 3 | 1, 5, 7 | none | 0, 2–4, 6 | encoded transfer kind: FALL, IND, or RET | Encoded zero is reserved and rejected. |

- `c_bstart_fp_16_9dcef7e3a85b.BrType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| BrType | encoded transfer kind: FALL, IND, or RET |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_fp_16_9dcef7e3a85b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.FP opens one Floating block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.FP.asl -->
```asl
pure func InstructionContractBranchTypeLegal_C_BSTART_FP(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_FP(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_FP(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BrType is always encoded; it has no omitted or default form.

## Legality

- c_bstart_fp_16_9dcef7e3a85b.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET); code 6 is only the embedded low halfword of fused BSTART.ICALL and is illegal as a standalone 16-bit instruction.

## State effects

- FALL installs a non-selecting sequential Floating BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.
- The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.
- Target alignment is checked before retirement; the new Floating BARG is installed only after successful retirement.

## Exceptions

- BrType codes 0, 2, 3, 4, and 6 do not decode as standalone C.BSTART.FP and raise Fault_IllegalInstruction before effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.
- If predecessor commit fails, the retiring block remains authoritative and no Floating BARG is installed.

## Examples

- C.BSTART.FP FALL
- C.BSTART.FP IND
- C.BSTART.FP RET
