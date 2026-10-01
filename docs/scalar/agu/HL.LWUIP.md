<!-- GENERATED FROM: asl/scalar/agu/HL.LWUIP.asl -->
# HL.LWUIP

**Normative ASL source:** `asl/scalar/agu/HL.LWUIP.asl`

HL.LWUIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LWUIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwuip-purpose role=purpose -->
## What `HL.LWUIP` does

`HL.LWUIP` is a standalone `48`-bit scalar AGU instruction that loads two adjacent 4-byte little-endian values through an immediate displacement and zero-extends each one to `PTO_XLEN`.

The canonical assembly is `hl.lwuip [SrcL, simm], ->Dst0, Dst1`.

Design point: the second address is not encoded. The handler computes it as the first address plus the transfer size, so the pair can only be two adjacent units of the same width. A program that wants two values eight bytes apart must issue two separate loads rather than one pair form.

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `simm17` value left-shifted by `2`, so the encoded field counts 4-byte units and covers `-65536` through `65535` units, which is `-262144` through `262140` bytes. It is added to the `SrcL` snapshot modulo `2^PTO_XLEN`.

That sum is the first address; the second is the sum plus `4`. The update mode is none, so no byte of this form writes a base register back.

Both addresses are probed before either memory read starts. Only after both probes succeed does the handler read the two aligned units, record the events, and publish the two results.

Design point: probing the whole pair first is what makes the form all-or-nothing. An access fault on the second unit is raised before the first unit is read, so no half of the pair can be observed as loaded.

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-inputs role=inputs-outputs -->
## Encoded fields and results

- `SrcL` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm17` is a signed `17`-bit displacement carried in two encoding pieces, bits `36`..`47` and bits `6`..`10`, used with a scale of `4`.
- `RegDst0` and `RegDst1` are `5`-bit selectors. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result.

Design point: `RegDst0` is the first, lower-address unit and `RegDst1` is the second. The two fields are independent, so the first value may be discarded while the second is kept, and the discarded load still happens and still raises its faults.

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-effects role=effects -->
## Effects, ordering, and completion

All scalar sources are snapshotted before any memory or destination effect, so a destination that names `SrcL` still contributes the pre-instruction base to the address.

A successful execution records two relaxed load events, first then second. Memory bytes and reservation state are unchanged, because a load neither writes memory nor disturbs a reservation.

`TPC` advances by `6` bytes after both results are published. A rejected or faulting attempt does not retire.

Design point: the two results are published only in the last step, so a fault anywhere earlier leaves both destinations holding their pre-instruction values.

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect; these checks run before the sources are read.

A misaligned 4-byte address raises `Fault_DataAlignment` before translation or permission. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery recomputes the snapshots, both addresses, both probes, and both loads from the beginning.

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lwuip [5, -2], ->8, 9` with GPR5 = `0x2000`. The immediate is `-2`, so the byte displacement is `-8` and the first address is `0x1FF8`.
- The second address is `0x1FF8` plus `4`, which is `0x1FFC`. Both are `4`-byte aligned, so both probes pass.
- The first unit goes to GPR8 and the second to GPR9; each result is zero-extended to `PTO_XLEN`.
- GPR5 still holds `0x2000`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwuip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwuip_48_2a5d6d8f3b70 | HL48 | 48 | 0x00006019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwuip_48_2a5d6d8f3b70 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwuip_48_2a5d6d8f3b70 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwuip_48_2a5d6d8f3b70 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwuip_48_2a5d6d8f3b70 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUIP() => ScalarOperation
begin
    return ScalarOperation_HL_LWUIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LWUIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LWUIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LWUIP()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWUIP()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LWUIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWUIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWUIP()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- After both 4-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lwuip [SrcL, simm], ->Dst0, Dst1
