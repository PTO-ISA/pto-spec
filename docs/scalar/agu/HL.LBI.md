<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.asl -->
# HL.LBI

**Normative ASL source:** `asl/scalar/agu/HL.LBI.asl`

HL.LBI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbi-purpose role=purpose -->
## What `HL.LBI` does

`HL.LBI` is a `48`-bit byte load with a signed `22`-bit immediate displacement and no base update. It adds the immediate to the `SrcL` base, reads one byte there, sign-extends the byte to `PTO_XLEN`, and publishes it to the single `RegDst` field.

The canonical assembly is `hl.lbi [SrcL, simm], ->{t, u, Rd}`.

Design point: this form has one destination field, so although the handler computes the base-plus-displacement sum for the access, there is no place to publish it. The address is therefore not available as a result, and a traversal that needs a running pointer must compute it with a separate instruction.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `22`-bit immediate with a scale of `1`, added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The update mode is none, so the effective address is the sum and nothing is written back to any base register.

The base selector is only read; no state records that an address was formed.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, sign-extends bit `7`, and publishes the result to `RegDst`.

Design point: widening the immediate to `22` bits extends the reachable window to `-2097152` through `2097151` bytes, in byte steps. That window is a property of the immediate field alone, which is why this form can address an offset object without spending a register on the displacement.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-inputs role=inputs-outputs -->
## Encoded fields and the result

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm22` is a signed `22`-bit immediate covering `-2097152` to `2097151`, used with a scale of `1`.
- `RegDst` is a `5`-bit selector. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard the value without suppressing the access.

Design point: a discard is a real destination code, so the load and its fault checks still happen. A program can therefore use this form as a checked read whose value it throws away, but it cannot use it to skip the memory reference.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is snapshotted before any memory or destination effect, so a destination that names the base still contributes the pre-instruction value to the address.

A successful execution records one relaxed `1`-byte load event. Memory bytes and reservation state are unchanged, because a load neither writes memory nor disturbs a reservation.

`TPC` advances by `6` bytes after the publication. A rejected or faulting attempt does not retire and leaves `TPC` on the faulting instruction.

Design point: the sign extension happens before publication, so the destination holds a value whose bits `63`:`8` are all copies of bit `7`. A later unsigned comparison on that value is therefore not equivalent to the unsigned reading of the byte.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `48`-bit encoding raises `Fault_IllegalInstruction` before any effect, and a `SrcL` code selecting an unavailable `T` or `U` slot raises the same fault before execution. The encoding carries no transform or shift field, so no other value can be rejected at that stage.

The preflight applies the `1`-byte alignment requirement, which every address satisfies, so this form does not raise `Fault_DataAlignment`. A permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery recomputes the displacement and the sum from the same `SrcL`.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbi [4, -8], ->7` with GPR4 = `0xA000`. The immediate is `-8`, so the effective address is `0xA000` minus `8`, which is `0x9FF8`.
- The instruction reads the byte at `0x9FF8`. If it is `80`, GPR7 receives `-128`, which is `0xFFFFFFFFFFFFFF80`.
- GPR4 still holds `0xA000`, because this form publishes only one result and has no base update.
- `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_48_250803040cc8 | HL48 | 48 | 0x00000019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_48_250803040cc8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_48_250803040cc8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_48_250803040cc8 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbi_48_250803040cc8 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_48_250803040cc8 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbi_48_250803040cc8 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI() => ScalarOperation
begin
    return ScalarOperation_HL_LBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lbi [SrcL, simm], ->{t, u, Rd}
