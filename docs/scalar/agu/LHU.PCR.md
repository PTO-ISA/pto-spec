<!-- GENERATED FROM: asl/scalar/agu/LHU.PCR.asl -->
# LHU.PCR

**Normative ASL source:** `asl/scalar/agu/LHU.PCR.asl`

LHU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhu-pcr-purpose role=purpose -->
## What `LHU.PCR` does

`LHU.PCR` loads one unsigned `2`-byte halfword from an address relative to the instruction's own aligned address, and publishes the zero-extended value.

The canonical assembly is `lhu.pcr [symbol], ->{t, u, Rd}`.

Design point: neither a base nor an index register is read, so the whole address depends on `TPC` and `simm17`; the encoding has no field that software can leave uninitialized.

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

`TPC` with bits `1:0` cleared supplies the base, and the sign-extended `simm17` multiplied by `4` supplies the displacement. The addition is modulo `2^PTO_XLEN`.

Preflight tests `2`-byte alignment, then translation, then permission and bounded memory. On success `2` bytes are read little-endian and one relaxed load event is recorded.

The halfword is zero-extended to `PTO_XLEN` and published through `RegDst`; `TPC` then advances by `4` bytes.

Design point: base and displacement are multiples of `4`, so the effective address is a multiple of `4` and the `2`-byte alignment rule is satisfied by construction.

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-inputs role=inputs-outputs -->
## Encoded fields and roles

- `TPC` is the implicit base. Bits `1:0` are cleared, so the reference point is a `4`-byte boundary even if the instruction stream is denser.
- `simm17` is signed and covers `-65536`..`65535` units of `4` bytes, that is `-262144`..`262140` bytes.
- `RegDst` is the only selector in the encoding. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: `RegDst` accepts every `5`-bit code, including the queue pushes `30` and `31`, so an unsigned halfword can enter a queue directly.

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-effects role=effects -->
## Effects, ordering, and completion

The base is the pre-advance `TPC`, so the address is fixed by the instruction's position and not by anything the program wrote.

Success records one relaxed load event, leaves memory and the reservation unchanged, publishes the zero-extended halfword, and advances `TPC` by `4` bytes.

Design point: the result holds `0`..`65535`, so no bit above `15` is set by the load and the value can be compared as an unsigned count directly.

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch raises `Fault_IllegalInstruction` before any instruction effect; there is no register operand whose legality could fail.
- A displacement that produced an odd address would raise `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing, and keeps `TPC` on the faulting instruction so the attempt can be reissued.
- Design point: the `4`-byte displacement scale makes the alignment stage unreachable, so `Fault_DataPage` is the only data-side failure `LHU.PCR` can report.

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `TPC` = `0x2000` and `simm17` = `2`, the byte displacement is `8` and the address is `0x2008`.
- Bytes `00 80` at `0x2008` are the halfword `0x8000`, published as `0x8000`.
- If `TPC` were `0x2002`, the base would still be `0x2000` because bits `1:0` are cleared before the addition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhu_pcr_32_9f4a1c04f258 | L32 | 32 | 0x00005039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhu_pcr_32_9f4a1c04f258 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhu_pcr_32_9f4a1c04f258 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhu_pcr_32_9f4a1c04f258 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhu_pcr_32_9f4a1c04f258 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LHU_PCR() => ScalarOperation
begin
    return ScalarOperation_LHU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LHU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LHU_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LHU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHU_PCR()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- lhu.pcr [symbol], ->{t, u, Rd}
