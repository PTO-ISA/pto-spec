<!-- GENERATED FROM: asl/scalar/agu/LHI.asl -->
# LHI

**Normative ASL source:** `asl/scalar/agu/LHI.asl`

LHI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhi-purpose role=purpose -->
## What `LHI` does

`LHI` loads one signed `2`-byte halfword at an immediate distance from a base register. The immediate is scaled by `2`, so each encoded unit names a halfword slot.

The canonical assembly is `lhi [SrcL, simm], ->{t, u, Rd}`.

Design point: the scale is fixed by the instruction, so `simm12` covers `-4096`..`4094` bytes. The `.u` form of this instruction drops that scale and covers `-2048`..`2047` bytes instead.

<!-- PTO-READER-BLOCK: scalar-lhi-mechanism role=mechanism -->
## How the address and the transfer are formed

`LHI` sign-extends `simm12` and shifts it left by `1`, which is the multiplication by `2` recorded in the address kind, then adds it to the `SrcL` snapshot modulo `2^PTO_XLEN`.

Preflight checks `2`-byte alignment, then translation, then permission and bounded memory. On success `2` bytes are read little-endian and one relaxed load event is recorded.

The halfword is sign-extended to `PTO_XLEN` and published through `RegDst`; the base register is not written back.

Design point: scaling by `2` leaves the low bit of the byte displacement at `0`, so the effective address is even exactly when the base is even. `LHI` cannot align an odd base and reports the sum as `Fault_DataAlignment`.

<!-- PTO-READER-BLOCK: scalar-lhi-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm12` is signed, covers `-2048`..`2047` units, and is scaled by `2`, so `0x800` decodes to `-2048` units, that is `-4096` bytes.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: the byte window reaches `4096` bytes below the base and `4094` bytes above it, and every displacement is an even number of bytes, so a halfword array can be walked with one base register and no index register.

<!-- PTO-READER-BLOCK: scalar-lhi-effects role=effects -->
## Effects, ordering, and completion

The base is snapshotted before the memory operation, so nothing this instruction writes can affect the address it reads.

Success records one relaxed load event, leaves memory and the reservation unchanged, publishes the sign-extended halfword, and advances `TPC` by `4` bytes.

Design point: the load is signed, so a halfword `0xFFFF` read through `LHI` publishes `0xFFFFFFFFFFFFFFFF` rather than `65535`.

<!-- PTO-READER-BLOCK: scalar-lhi-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a `SrcL` selector naming an unavailable `T`/`U` queue entry, raises `Fault_IllegalInstruction` before the base is read.
- An odd sum raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes no destination value, and keeps `TPC` on the faulting instruction for a complete reissue.
- Design point: an immediate that is a multiple of `2` bytes can never repair the low bit of the base, so an aligned base is a precondition this form cannot substitute for.

<!-- PTO-READER-BLOCK: scalar-lhi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x1000` and `simm12` = `3`, the byte displacement is `6` and the address is `0x1006`.
- Bytes `FF FF` there are the halfword `0xFFFF`, which publishes as `0xFFFFFFFFFFFFFFFF`.
- The same instruction with `SrcL` = `0x1001` produces `0x1007`, an odd address, so `Fault_DataAlignment` is raised and no destination is written.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhi_32_46a45ec7074d | L32 | 32 | 0x00001019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhi_32_46a45ec7074d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhi_32_46a45ec7074d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhi_32_46a45ec7074d | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhi_32_46a45ec7074d | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhi_32_46a45ec7074d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhi_32_46a45ec7074d | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHI.asl -->
```asl
readonly func InstructionContractOperation_LHI() => ScalarOperation
begin
    return ScalarOperation_LHI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHI.asl -->
```asl
readonly func InstructionContractHandler_LHI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHI()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHI()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_LHI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lhi [SrcL, simm], ->{t, u, Rd}
