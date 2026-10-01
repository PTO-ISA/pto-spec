<!-- GENERATED FROM: asl/scalar/agu/LBU.PCR.asl -->
# LBU.PCR

**Normative ASL source:** `asl/scalar/agu/LBU.PCR.asl`

LBU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbu-pcr-purpose role=purpose -->
## What `LBU.PCR` does

`LBU.PCR` loads one unsigned `1`-byte unit from an address relative to the instruction, and publishes the byte as a value in `0`..`255`.

The canonical assembly is `lbu.pcr [symbol], ->{t, u, Rd}`.

Design point: `LBU.PCR` is the unsigned twin of `LB.PCR`. The two forms share the addressing fields, so they always access the same address and differ only in the extension of the loaded byte.

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

`TPC` with bits `1:0` cleared supplies the base. The sign-extended `simm17` is multiplied by `4` and added to it modulo `2^PTO_XLEN`.

Preflight tests `1`-byte alignment, then translation, then permission and bounded memory. On success `1` byte is read little-endian and one relaxed load event is recorded.

The byte is zero-extended to `PTO_XLEN` and published through `RegDst`; no base register exists to write back.

Design point: the cleared base and the `4`-byte-scaled displacement are both multiples of `4`, so the sum is a multiple of `4` and the `1`-byte access is aligned for every encoding.

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-inputs role=inputs-outputs -->
## Encoded fields and roles

- `TPC` is the implicit base. Clearing bits `1:0` makes the reference point a `4`-byte boundary.
- `simm17` is signed and covers `-65536`..`65535` units of `4` bytes, so `-262144`..`262140` bytes.
- `RegDst` is the only selector in the encoding. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: destination codes `30` and `31` push the byte onto the `U` or `T` queue, so a constant byte can be loaded straight into a queue entry.

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-effects role=effects -->
## Effects, ordering, and completion

The base is read before the memory operation, so the access is fixed by the instruction's own position and nothing else.

Success records one relaxed load event, leaves memory and the reservation unchanged, publishes the zero-extended byte, and advances `TPC` by `4` bytes.

Design point: the result is exactly `0`..`255`, because the zero-extension clears every bit above `7`.

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch raises `Fault_IllegalInstruction` before any instruction effect.
- The address must satisfy `1`-byte alignment before translation is consulted; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes no byte, and keeps `TPC` on the faulting instruction for a full reissue.
- Design point: `Fault_DataAlignment` is unreachable, so the only data-side rejection left after the legality stage is `Fault_DataPage` from the permission check.

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `TPC` = `0x2000` and `simm17` = `1`, the byte displacement is `4` and the address is `0x2004`.
- A byte `0xFF` at that address publishes `0xFF`, while the same access through `LB.PCR` would publish `0xFFFFFFFFFFFFFFFF`.
- With `simm17` = `-1` the address is `0x1FFC`, still a multiple of `4`, so the negative displacement is reached without any alignment failure.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | L32 | 32 | 0x00004039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbu_pcr_32_5b571b0c8dc2 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbu_pcr_32_5b571b0c8dc2 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_LBU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LBU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LBU_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LBU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBU_PCR()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- lbu.pcr [symbol], ->{t, u, Rd}
