<!-- GENERATED FROM: asl/scalar/agu/HL.LBUIP.asl -->
# HL.LBUIP

**Normative ASL source:** `asl/scalar/agu/HL.LBUIP.asl`

HL.LBUIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBUIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbuip-purpose role=purpose -->
## What `HL.LBUIP` does

`HL.LBUIP` is a `48`-bit load of a pair of adjacent bytes with zero-extended results. It adds a signed `17`-bit immediate to the `SrcL` base, reads the byte at that address and the byte at that address plus `1`, clears everything above bit `7` in each result, and publishes the lower byte to `Dst0` and the higher byte to `Dst1`.

The canonical assembly is `hl.lbuip [SrcL, simm], ->Dst0, Dst1`.

Design point: both results are unsigned, so a pair of bytes `FF FF` becomes `255` in `Dst0` and `255` in `Dst1`. The two destinations are filled by the same rule; the form has no way to publish one byte signed and the other unsigned.

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-mechanism role=mechanism -->
## How the two addresses and the transfer are formed

The immediate is sign-extended with a scale of `1` and added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The second address is the first plus `1`, because the access size is one byte.

Both addresses are probed, in ascending order, before either byte is read. The handler returns on the first fault. When both probes succeed, it reads the two bytes, records two relaxed load events in address order, zero-extends both values, and publishes `Dst0` then `Dst1`.

Design point: the two destination fields can name the same register or the same queue. The write order then decides the outcome: the second byte replaces the first, so the surviving value is the byte at the higher address. There is no encoding that reverses the order.

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`; a queue source is read without being consumed.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535` with a scale of `1`.
- `Dst0` receives the lower byte and `Dst1` the higher byte. Codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: a queue push destination is available for each result independently, and each push moves the older queue entries one slot along. A pair load that pushes both results therefore advances the `T` queue twice, and the second push becomes the newest entry.

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is snapshotted before any memory or destination effect, so aliases between the base and either destination use pre-instruction values.

A successful execution records two relaxed `1`-byte load events in address order and leaves memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: no base writeback exists for this form, so the two destinations are the only architectural effects on registers or queues, and a fault leaves even those untouched.

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement to both addresses, so neither can raise `Fault_DataAlignment`. The permission and bounded-memory test applies to each address in ascending order, and the first failure raises `Fault_DataPage` at that original address.

A fault records no load event, publishes neither byte, and leaves `TPC` on the faulting instruction. Recovery recomputes both addresses and both probes from the same `SrcL`.

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbuip [4, 6], ->9, 0` with GPR4 = `0xD000`. The immediate is `6`, so the first address is `0xD006` and the second is `0xD007`.
- `Dst0` names GPR9 and `Dst1` is the discard code `0`, so only the first byte is published.
- If the byte at `0xD006` is `FF`, GPR9 receives `255` with bits `63`:`8` all zero.
- The byte at `0xD007` is still read and its load event is still recorded; only its publication is discarded.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbuip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbuip_48_ad419fc474c0 | HL48 | 48 | 0x00004019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbuip_48_ad419fc474c0 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbuip_48_ad419fc474c0 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbuip_48_ad419fc474c0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbuip_48_ad419fc474c0 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbuip_48_ad419fc474c0 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbuip_48_ad419fc474c0 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbuip_48_ad419fc474c0 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbuip_48_ad419fc474c0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUIP() => ScalarOperation
begin
    return ScalarOperation_HL_LBUIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBUIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBUIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUIP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUIP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUIP()
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
- After both 1-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
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

- hl.lbuip [SrcL, simm], ->Dst0, Dst1
