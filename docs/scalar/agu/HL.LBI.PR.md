<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.PR.asl -->
# HL.LBI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBI.PR.asl`

HL.LBI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-purpose role=purpose -->
## What `HL.LBI.PR` does

`HL.LBI.PR` is a `48`-bit pre-indexed byte load with a signed `17`-bit immediate displacement. It adds the displacement to the `SrcL` base, reads one byte at the sum, sign-extends the byte to `PTO_XLEN`, publishes the byte to `Dst0`, and publishes the same sum to `Dst1`.

The canonical assembly is `hl.lbi.pr [SrcL, simm], ->Dst0, Dst1`.

Design point: in pre-index mode the sum is both the address of the access and the value published to `Dst1`, and it is computed once. `SrcL` is only read, so no fault can leave the base register half-updated; a retry recomputes the identical sum from the same base and the same immediate.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `17`-bit immediate with a scale of `1`. It is added to the snapshot of `SrcL` modulo `2^PTO_XLEN`, and that sum is used for the access.

`SrcL` itself is never written by this instruction. The updated base reaches the register file, a GPR, or a queue only through `Dst1`.

Once the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, sign-extends the byte, and publishes `Dst0` before `Dst1`.

Design point: the immediate is unscaled, so an immediate that is not a multiple of a wider access size is still expressible. For this `1`-byte form no alignment is required, but it means `Dst1` can be left on any byte address, and a later access of a wider kind that uses that value as a base must satisfy its own alignment rule.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535`, used with a scale of `1`.
- `Dst0` receives the sign-extended byte and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: there is no offset register, so the instruction neither reads nor depends on any register other than `SrcL`. Two instances with the same `SrcL` and the same immediate always form the same address, whatever the rest of the register file contains.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is snapshotted before any memory or destination effect, so an alias between `SrcL` and either destination uses the pre-instruction value.

On success one relaxed `1`-byte load event is recorded, and memory and reservation state are unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: the byte is sign-extended before publication, so a byte of `FF` reaches `Dst0` as `-1` with all `64` bits set. A caller that wants the unsigned reading can use the zero-extending form of the same width, or mask the extended value down to its low `8` bits.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution. No transform or shift field exists in this encoding, so there is no reserved-value rejection beyond the encoding's fixed bits.

The preflight applies the `1`-byte alignment requirement, which every address meets, so no address raises `Fault_DataAlignment` for this form. The permission and bounded-memory test still applies and raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery redoes the sign extension of the immediate, the sum, and the load.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbi.pr [5, 16], ->6, 5` with GPR5 = `0x7002`.
- The immediate is `16`, so the effective address is `0x7002` plus `16`, which is `0x7012`.
- If the byte at `0x7012` is `7F`, GPR6 receives `127`.
- GPR5 receives `0x7012` because `Dst1` names the base register, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbi.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | HL48 | 48 | 0x00000019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_pr_48_b4bdbd29f859 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbi_pr_48_b4bdbd29f859 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBI_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBI_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBI_PR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBI_PR()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.lbi.pr [SrcL, simm], ->Dst0, Dst1
