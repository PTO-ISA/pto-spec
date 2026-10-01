<!-- GENERATED FROM: asl/scalar/agu/LD.PCR.asl -->
# LD.PCR

**Normative ASL source:** `asl/scalar/agu/LD.PCR.asl`

LD.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-pcr-purpose role=purpose -->
## What `LD.PCR` does

`LD.PCR` loads one `8`-byte little-endian unit from an address relative to the instruction itself. It reads no base register: the reference point is the aligned current `TPC`.

The canonical assembly is `ld.pcr [symbol], ->{t, u, Rd}`.

Design point: `LD.PCR` is the one member of this PC-relative group whose access size (`8` bytes) is larger than the `4`-byte displacement scale, so alignment is decided by bit `2` of the sum.

<!-- PTO-READER-BLOCK: scalar-ld-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is `TPC` with bits `1:0` cleared, so the reference point is the `4`-byte-aligned address of this instruction. `simm17` is sign-extended, multiplied by `4`, and added modulo `2^PTO_XLEN`.

Preflight tests `8`-byte alignment, then translation, then permission and bounded memory. On success `8` bytes are read little-endian and one relaxed load event is recorded.

All `64` loaded bits are published unchanged through `RegDst`; there is no base register to update and no extension step.

Design point: both the cleared base and the scaled displacement are multiples of `4`, so the sum is always a multiple of `4`. A sum that is `4` modulo `8` raises `Fault_DataAlignment` even though nothing in the encoding is malformed.

<!-- PTO-READER-BLOCK: scalar-ld-pcr-inputs role=inputs-outputs -->
## Encoded fields and roles

- `TPC` is the implicit base. Bits `1:0` are cleared before the displacement is added, and `TPC` still holds the address of the instruction being executed.
- `simm17` is signed and covers `-65536`..`65535` units; each unit is `4` bytes, so the byte displacement covers `-262144`..`262140`.
- `RegDst` is the only selector in the encoding. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: with no register operand the encoding has room for a `17`-bit displacement, which is what gives a `32`-bit instruction a reach of `262144` bytes around its own address.

<!-- PTO-READER-BLOCK: scalar-ld-pcr-effects role=effects -->
## Effects, ordering, and completion

The base is read from `TPC` before the memory operation, so the displacement is always measured from this instruction and never from the following one.

Success records one relaxed load event, changes no memory byte, preserves the reservation, publishes the `8` loaded bytes, and advances `TPC` by `4` bytes.

Design point: because the address is tied to the instruction, the same encoding loads the same relative unit wherever the code is placed; only the faults that depend on the permitted region can differ between placements.

<!-- PTO-READER-BLOCK: scalar-ld-pcr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any memory or destination effect.
- An address that is not a multiple of `8` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no load event, publishes nothing, and keeps `TPC` on the faulting instruction so the attempt can be reissued unchanged.
- Design point: `LD.PCR` can raise `Fault_DataAlignment` precisely because its required alignment is stricter than the multiple-of-`4` sum that the encoding guarantees.

<!-- PTO-READER-BLOCK: scalar-ld-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `TPC` = `0x100` and `simm17` = `3`, the byte displacement is `12` and the address is `0x10C`.
- `0x10C` is `4` modulo `8`, so the preflight raises `Fault_DataAlignment` and no byte is loaded.
- With `simm17` = `2` the address is `0x108`, which is `8`-byte aligned, and the `8` bytes there are published as one `64`-bit value.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_pcr_32_99bc3d2d487b | L32 | 32 | 0x00003039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_pcr_32_99bc3d2d487b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_pcr_32_99bc3d2d487b | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_pcr_32_99bc3d2d487b | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ld_pcr_32_99bc3d2d487b | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_LD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LD_PCR()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- ld.pcr [symbol], ->{t, u, Rd}
