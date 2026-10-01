<!-- GENERATED FROM: asl/scalar/agu/LBI.asl -->
# LBI

**Normative ASL source:** `asl/scalar/agu/LBI.asl`

LBI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbi-purpose role=purpose -->
## What `LBI` does

`LBI` loads one signed `1`-byte unit at a signed immediate distance from a base register. It is the immediate form of the byte read: the displacement is encoded, so no index register is read at all.

The canonical assembly is `lbi [SrcL, simm], ->{t, u, Rd}`.

Design point: `simm12` counts bytes, so this form reaches `2048` bytes below the base and `2047` bytes above it, a window `4096` bytes wide, with no register consumed for the offset.

<!-- PTO-READER-BLOCK: scalar-lbi-mechanism role=mechanism -->
## How the address and the transfer are formed

`LBI` sign-extends the `12`-bit `simm12` field to `PTO_XLEN` and adds it, unscaled, to the `SrcL` snapshot modulo `2^PTO_XLEN`. Each encoded unit is worth `1` byte of address.

The effective address passes the `1`-byte alignment stage and then the permission and bounded-memory check. On success one little-endian byte is read and one relaxed load event is recorded.

The byte is sign-extended to `PTO_XLEN` and published through `RegDst`; the base register is never modified.

Design point: sign extension happens on the field before the addition, so an encoding of `0x800` means `-2048` bytes and not `2048`. Negative and positive half-windows are therefore asymmetric: `2048` below the base, `2047` above.

<!-- PTO-READER-BLOCK: scalar-lbi-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the only register source. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm12` is a signed `12`-bit displacement covering `-2048`..`2047`; encoded zero is a zero displacement and not an omitted operand.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: `SrcL` code `0` reads the architectural zero GPR, so a zero base with a non-negative `simm12` reads the low `2048` bytes of the address space directly; a negative displacement wraps modulo `2^PTO_XLEN` to the top of the space instead.

<!-- PTO-READER-BLOCK: scalar-lbi-effects role=effects -->
## Effects, ordering, and completion

The base snapshot is taken before the memory access, so nothing that happens later in the instruction can move the address.

A successful attempt records one relaxed load event, writes no memory, changes no reservation, publishes the sign-extended byte, and advances `TPC` by `4` bytes.

Design point: a negative displacement that wraps below zero wraps modulo `2^PTO_XLEN` and is then judged by the permission check, so the wrap itself is silent and the resulting address decides the outcome.

<!-- PTO-READER-BLOCK: scalar-lbi-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch or a `SrcL` code naming an unavailable `T` or `U` entry raises `Fault_IllegalInstruction` at the instruction address before the base is read.
- The address must satisfy `1`-byte alignment before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no load event, publishes nothing, and keeps `TPC` on the faulting instruction for full reissue.
- Design point: `Fault_DataAlignment` cannot fire for a `1`-byte access, so the only data-side rejection `LBI` can produce is `Fault_DataPage` from the permission stage.

<!-- PTO-READER-BLOCK: scalar-lbi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With GPR `6` = `0x1000` and an encoded `simm12` of `-1`, the effective address is `0xFFF` and one byte is read from there.
- With the same base and `simm12` = `2047`, the address is `0x17FF`, which shows the `2047` byte positive edge of the window.
- A byte `0xFF` read at either address publishes `0xFFFFFFFFFFFFFFFF`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbi_32_9af2cdbeb38f | L32 | 32 | 0x00000019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbi_32_9af2cdbeb38f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbi_32_9af2cdbeb38f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lbi_32_9af2cdbeb38f | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbi_32_9af2cdbeb38f | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbi_32_9af2cdbeb38f | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lbi_32_9af2cdbeb38f | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBI.asl -->
```asl
readonly func InstructionContractOperation_LBI() => ScalarOperation
begin
    return ScalarOperation_LBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBI.asl -->
```asl
readonly func InstructionContractHandler_LBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- lbi [SrcL, simm], ->{t, u, Rd}
