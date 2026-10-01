<!-- GENERATED FROM: asl/scalar/agu/HL.LBIP.asl -->
# HL.LBIP

**Normative ASL source:** `asl/scalar/agu/HL.LBIP.asl`

HL.LBIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbip-purpose role=purpose -->
## What `HL.LBIP` does

`HL.LBIP` is a `48`-bit load of a pair of adjacent bytes. It adds a signed `17`-bit immediate to the `SrcL` base, reads the bytes at that address and at that address plus `1`, sign-extends each of them to `PTO_XLEN`, and publishes the lower byte to `Dst0` and the higher byte to `Dst1`.

The canonical assembly is `hl.lbip [SrcL, simm], ->Dst0, Dst1`.

Design point: the pair is a single instruction with a single fault boundary. Both address probes complete before either byte is read, so a fault on the second address leaves the first byte unread and no load event is recorded for it. There is no state in which one byte of the pair has been observed and the other has not.

<!-- PTO-READER-BLOCK: scalar-hl-lbip-mechanism role=mechanism -->
## How the two addresses and the transfer are formed

The immediate is sign-extended with a scale of `1` and added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The second address is the first plus the access size, which is `1` byte, so the pair always covers two consecutive bytes.

The probes are performed in ascending address order, and the handler returns on the first one that faults. Only when both probes succeed are the two bytes read, the two relaxed load events recorded in address order, and the results published with `Dst0` first and `Dst1` second.

Design point: the pair stride is the access size, not a fixed offset, so a pair of wider elements would be separated by that width. For this `1`-byte form the two elements are adjacent, which is what makes the form usable for reading a two-byte field in one instruction without a second encoding.

<!-- PTO-READER-BLOCK: scalar-hl-lbip-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535`, scaled by `1`; it locates the first address of the pair.
- `Dst0` receives the byte at the first address and `Dst1` the byte at the second. Codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that single result.

Design point: the two destinations are independent, and a discard suppresses only the publication of that one byte. The instruction still probes and reads both addresses, so a discarded result does not remove half of the memory work.

<!-- PTO-READER-BLOCK: scalar-hl-lbip-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so a destination naming the base still contributes the pre-instruction value to both addresses.

On success two relaxed `1`-byte load events are recorded in address order, and memory bytes and reservation state are unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: both events are recorded before either destination is written, so an observer of the event stream sees the complete pair of memory effects before any register effect of the instruction.

<!-- PTO-READER-BLOCK: scalar-hl-lbip-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement to each address, which both satisfy, so this form does not raise `Fault_DataAlignment`. The permission and bounded-memory test can still fail: the first failing address, tested in ascending order, raises `Fault_DataPage` at that original address.

A fault records no load event, publishes neither byte, and leaves `TPC` on the faulting instruction. Recovery re-derives both addresses and repeats both probes from the snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-lbip-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbip [4, 6], ->9, 10` with GPR4 = `0xD000`. The immediate is `6`, so the first address is `0xD006` and the second is `0xD007`.
- The instruction probes `0xD006` and then `0xD007`. Only if both probes succeed does it read the two bytes.
- If the byte at `0xD006` is `7F` and the byte at `0xD007` is `80`, GPR9 receives `127` and GPR10 receives `-128`.
- GPR4 still holds `0xD000`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbip_48_70a5767aff16 | HL48 | 48 | 0x00000019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbip_48_70a5767aff16 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbip_48_70a5767aff16 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbip_48_70a5767aff16 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbip_48_70a5767aff16 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbip_48_70a5767aff16 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbip_48_70a5767aff16 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbip_48_70a5767aff16 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbip_48_70a5767aff16 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBIP() => ScalarOperation
begin
    return ScalarOperation_HL_LBIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBIP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBIP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBIP()
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
- The pair addresses are address and address plus 1; the instruction performs no base writeback.
- After both 1-byte probes succeed, sign-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 1-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lbip [SrcL, simm], ->Dst0, Dst1
