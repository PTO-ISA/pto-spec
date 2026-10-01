<!-- GENERATED FROM: asl/scalar/agu/LWU.PCR.asl -->
# LWU.PCR

**Normative ASL source:** `asl/scalar/agu/LWU.PCR.asl`

LWU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwu-pcr-purpose role=purpose -->
## What `LWU.PCR` does

`LWU.PCR` loads one `4`-byte little-endian word from a PC-relative address and zero-extends it to `PTO_XLEN`. It has no source-register field: the base comes from the current `TPC`. Its canonical assembly is `lwu.pcr [symbol], ->{t, u, Rd}`.

Design point: the loaded word is zero-extended, so the published value always has bits `63`:`32` set to `0` and lies in `0`..`4294967295`. A `32`-bit pattern that must stay negative needs the sign-extending PC-relative load form instead.

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-mechanism role=mechanism -->
## How `LWU.PCR` forms the address and completes the access

The base is the pre-instruction `TPC` with bits `1`:`0` cleared, which makes it `4`-byte aligned. The `simm17` field is sign-extended to `PTO_XLEN` and shifted left by `2`, and the two values are added modulo `2^PTO_XLEN`.

The sum is used by one little-endian `4`-byte load. There is no base writeback and no second destination. Bits `31`:`0` of the loaded word are zero-extended and written through `RegDst` only if the load reported no fault.

Design point: clearing `TPC[1:0]` gives the displacement one stable base even when a variable-length instruction leaves `TPC` on the second halfword of a word. Instructions at `0x1002` and `0x1006` with the same field therefore address locations `4` bytes apart, and both addresses stay `4`-byte aligned.

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `simm17` is a signed `17`-bit word displacement, so all `131072` encodings are values. The byte displacement it produces is a multiple of `4` in the range `-262144` through `262140`.
- `RegDst` is a `5`-bit destination: codes `1`..`23` write absolute GPRs, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and codes `0` and `24`..`29` discard the loaded value.

Design point: there is no base selector to validate, so this form has no unavailable `T`/`U` rejection path even though its destination can still push a queue entry. The fixed opcode pattern is the only encoded value that can be illegal.

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-effects role=effects -->
## Effects, ordering, and completion

The base is read from `TPC` before the memory and destination effects, and the `TPC` advance is the last step, so the address is never affected by the instruction's own retirement.

Successful execution performs one relaxed `4`-byte load and records one load event. No memory byte changes and reservation state is preserved. `TPC` then advances by `4` bytes.

Design point: a displacement of `0` reads the `4` bytes of the aligned word that contains the instruction itself, so self-referential data access needs no register setup. The base is aligned down, so the accessed word is not necessarily the one the instruction occupies.

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed encoding bits do not match.

The base is `4`-byte aligned and the scaled displacement is a multiple of `4`, so a `4`-byte access is always aligned and `Fault_DataAlignment` is unreachable for this form. An aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address; PTO v0 translation is the identity function, so there is no separate translation fault.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction, so reissue recomputes the same aligned base from the same `TPC`.

Design point: the alignment outcome is fixed by the encoding rather than by the address, so `Fault_DataPage` is the only data fault this form can raise. A handler that catches `Fault_DataAlignment` will never see it from here.

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `lwu.pcr [symbol], ->5` executing at `TPC` = `0x1002`, with the encoded `simm17` equal to `3`.
- Clearing the low `2` bits of `0x1002` gives the base `0x1000`; the displacement is `3` times `4`, which is `12`.
- The effective address is `0x1000` plus `12`, which is `0x100C`.
- `0x100C` is `4`-byte aligned, so the preflight passes; the `4` bytes at `0x100C` through `0x100F` are zero-extended into GPR5, and `TPC` becomes `0x1006`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwu_pcr_32_df27ea51c564 | L32 | 32 | 0x00006039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwu_pcr_32_df27ea51c564 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwu_pcr_32_df27ea51c564 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwu_pcr_32_df27ea51c564 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwu_pcr_32_df27ea51c564 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LWU_PCR() => ScalarOperation
begin
    return ScalarOperation_LWU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LWU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LWU_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LWU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWU_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lwu.pcr [symbol], ->{t, u, Rd}
