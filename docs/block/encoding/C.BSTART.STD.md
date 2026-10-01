<!-- GENERATED FROM: asl/block/encoding/C.BSTART.STD.asl -->
# C.BSTART.STD

**Normative ASL source:** `asl/block/encoding/C.BSTART.STD.asl`

Starts a compressed STD block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-std-purpose role=purpose -->
## What C.BSTART.STD does

`C.BSTART.STD` is the 16-bit start command for a Standard block whose continuation is not a PC-relative label. Its three forms are `C.BSTART.STD FALL`, `C.BSTART.STD IND`, and `C.BSTART.STD RET`. A block (also called a bundle) is a group of header commands and body instructions that commits as one unit at `BSTOP` or at the next block start.

The command records a candidate continuation in `BARG`, the bundle argument register, and does not jump by itself. The model pages [Bundle start dispatch](../model/dispatch/start.md) and [Begin](../model/lifecycle/begin.md) define the shared start sequence.

<!-- PTO-READER-BLOCK: block-c-bstart-std-mechanism role=mechanism -->
## Encoding and start sequence

The command is one halfword with one field, `BrType`, in bits 13:11. The other bits are fixed by the match `0x0000` under mask `0xc7ff`. `BrType` 1 is FALL, 5 is IND, and 7 is RET.

The candidate target depends on `BrType`:

- FALL uses the sequential address `P + 2`, where `P` is the address of the `C.BSTART.STD`.
- IND uses a snapshot of the retiring block's `BARG.BPCN`.
- RET uses a snapshot of the return-address state `_ReturnAddress`. For example, `SETRET`, call starts, and frame loads of `ra` write it together with GPR 10; an ordinary write to GPR 10 does not update it.

The target is checked for alignment before any active predecessor commits. The new Standard block opens only if the predecessor commit selected this address as the next PC. Header execution then continues at `P + 2`.

Design point: IND reads the retiring block's `BPCN` before that block commits, and keeps the value as a snapshot that the commit cannot change. A target that the predecessor left in its `BPCN`, for example through `SETC.TGT`, therefore becomes the candidate target of the new block.

<!-- PTO-READER-BLOCK: block-c-bstart-std-inputs role=inputs-outputs -->
## Fields and BARG values

- `BrType` is always encoded. It has no omitted or default form.
- Every form installs `BARG.BPC = P` and `BlockType = STD`.
- FALL installs `TYPE = FALL` with `BPCN = P + 2`. `BARGSelectsBPCN` is false for FALL, so commit continues at the sequential PC.
- IND installs `TYPE = IND` with the snapshotted retiring `BPCN`. RET installs `TYPE = RET` with the snapshotted return address. Both select `BPCN` at commit.

Design point: FALL, IND, and RET start with `TAKEN = 1`; the start path sets `TAKEN` to false only for a COND transfer. `TAKEN` does not affect continuation selection for these transfer kinds, because `BARGSelectsBPCN` consults it only for COND; `LSRGET` identifier 2 still reports it in bit 7.

<!-- PTO-READER-BLOCK: block-c-bstart-std-effects role=effects -->
## State effects and ordering

A successful start clears the previous header state, marks the new block active in its header phase, writes `BARG` and `BPC`, and takes a fresh execution-domain token. `C.BSTART.STD` performs no memory access and writes no GPR.

The installed candidate stays pending until `BSTOP` or the next block start commits the new block. Because the block is Standard, a body `SETC.TGT` may still replace `BPCN` before commit.

Design point: the predecessor commits before the new `BARG` is installed. If the predecessor commit fails, the predecessor stays authoritative and no Standard `BARG` is installed. If the predecessor transfers elsewhere, this command was on an unselected path and opens nothing.

<!-- PTO-READER-BLOCK: block-c-bstart-std-constraints role=constraints -->
## Legality, faults, and encoding overlap

`BrType` code 0 is not a `C.BSTART.STD` value. The halfword `0x0000` decodes as `C.BSTOP`. Codes 2, 3, 4, and 6 do not decode as standalone `C.BSTART.STD` and raise `Fault_IllegalInstruction` before effects. The fused `BSTART.ICALL` form does not use this field: it is a separate 32-bit form whose indirect-call transfer is fixed by the form itself.

Design point: the reviewed encoding overlap gives `BrType` 0 to `C.BSTOP`, so the all-zero halfword is a block stop, not a start with an unassigned transfer.

IND without an active retiring Standard or Floating block raises `Fault_BundleControl`. A System block has no candidate word, so it cannot supply an indirect target. An odd snapshotted target raises `Fault_InstructionPC`. Both faults occur before the predecessor commits.

<!-- PTO-READER-BLOCK: block-c-bstart-std-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART.STD FALL
```

`C.BSTART.STD FALL` encodes `BrType = 1`, which is the halfword `0x0800`. If it sits at `0x2000`, the new block has `BPC = 0x2000`, `BPCN = 0x2002`, and `TYPE = FALL`. Header execution continues at `0x2002`, and the commit continues at the instruction after the block. Suppose instead that the predecessor is an untaken conditional block whose `BPCN` is `0x3000`, so its commit continues at `0x2000`. A `C.BSTART.STD IND` at `0x2000` then snapshots `0x3000` as its target, and the new block continues at `0x3000` when it commits.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART.STD FALL
C.BSTART.STD IND
C.BSTART.STD RET
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_std_16_8b40f078c14a | C16 | 16 | 0x0000 / 0xc7ff | [{"field":"BrType","operator":"one-of","values":[1,5,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_std_16_8b40f078c14a | BrType | 3 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_std_16_8b40f078c14a | BrType | 3 | 1, 5, 7 | 0 (C.BSTOP) | 2–4, 6 | encoded transfer kind: FALL, IND, or RET | Encoded zero is owned by C.BSTOP, not C.BSTART.STD. |

- `c_bstart_std_16_8b40f078c14a.BrType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| BrType | encoded transfer kind: FALL, IND, or RET |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_std_16_8b40f078c14a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.STD opens one Standard block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
pure func InstructionContractBranchTypeLegal_C_BSTART_STD(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_STD(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_STD(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BrType is always encoded; it has no omitted or default form.

## Legality

- c_bstart_std_16_8b40f078c14a.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET). Code 0 decodes as C.BSTOP, while codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD; code 6 is used only inside fused BSTART.ICALL.

## State effects

- FALL installs a non-selecting sequential Standard BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.
- The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.
- Target alignment is checked before retirement; the new Standard BARG is installed only after successful retirement.

## Exceptions

- BrType code 0 is C.BSTOP. Codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD and raise Fault_IllegalInstruction before effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.
- If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed.

## Examples

- C.BSTART.STD FALL
- C.BSTART.STD IND
- C.BSTART.STD RET
